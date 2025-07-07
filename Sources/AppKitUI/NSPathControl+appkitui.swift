//
//  Copyright © 2025 Darren Ford. All rights reserved.
//
//  MIT license
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
//  documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial
//  portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
//  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
//  OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
//  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import AppKit.NSPathControl

@MainActor
public extension NSPathControl {
	/// Create a path control
	/// - Parameter url: The url
	convenience init(fileURL url: URL) {
		assert(url.isFileURL)
		self.init()
		self.url = url
	}

	/// Create a path control
	/// - Parameter url: The url
	convenience init(fileURL url: Bind<URL>) {
		self.init()
		self.fileURL(url)
	}
}

// MARK: - Modifiers

@MainActor
public extension NSPathControl {
	/// Set the URL
	/// - Parameter url: The URL
	/// - Returns: self
	@discardableResult @inlinable
	func fileURL(_ url: URL) -> Self {
		assert(url.isFileURL)
		self.url = url
		return self
	}

	/// Set the path style
	/// - Parameter style: the path style
	/// - Returns: self
	@discardableResult @inlinable
	func pathStyle(_ style: NSPathControl.Style) -> Self {
		self.pathStyle = style
		return self
	}
}

// MARK: - Actions

@MainActor
public extension NSPathControl {
	/// Set the action to call when the user clicks on the control
	/// - Parameter actionBlock: The block to call
	/// - Returns: self
	@discardableResult
	func onAction(_ actionBlock: @escaping (URL?) -> Void) -> Self {
		self.usingPathControlStorage { $0.onAction = actionBlock }
		return self
	}

	/// Set the action to call when the user clicks on a path cell
	/// - Parameter block: The block to call, passing the cell clicked
	/// - Returns: self
	@discardableResult
	func onPathItemAction(_ block: @escaping (NSPathControlItem?) -> Void) -> Self {
		self.usingPathControlStorage { $0.onPathItemAction = block }
		return self
	}
}

// MARK: - Bindings

@MainActor
public extension NSPathControl {
	/// Bind the URL
	/// - Parameter url: The url binding
	/// - Returns: self
	@discardableResult
	func fileURL(_ url: Bind<URL>) -> Self {
		assert(url.wrappedValue.isFileURL)
		url.register(self) { @MainActor [weak self] newURL in
			if self?.url != newURL {
				self?.url = newURL
			}
		}
		self.usingPathControlStorage { $0.url = url }
		self.url = url.wrappedValue
		return self
	}
}

// MARK: - Control storage

@MainActor
private extension NSPathControl {
	@MainActor
	class Storage: NSObject, NSPathControlDelegate, @unchecked Sendable {
		var url: Bind<URL>?
		var onAction: ((URL?) -> Void)?
		var onPathItemAction: ((NSPathControlItem?) -> Void)?
		weak var parent: NSPathControl?

		@MainActor
		init(_ control: NSPathControl) {
			self.parent = control
			super.init()
			control.target = self
			control.action = #selector(doAction(_:))
		}

		// Callback when the user single-clicks the path control
		@MainActor
		@objc private func doAction(_ sender: NSPathControl) {
			self.onAction?(sender.url)
			if let which = self.parent?.clickedPathItem {
				self.onPathItemAction?(which)
			}
		}
	}

	func usingPathControlStorage(_ block: @escaping (Storage) -> Void) {
		self.usingAssociatedValue(key: "__nspathcontrol_bond", initialValue: { Storage(self) }, block)
	}
}

// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("default") {
	let path1 = FileManager.default.temporaryDirectory
	let path2 = Bind(FileManager.default.temporaryDirectory)

	NSGridView {
		NSGridView.Row(rowAlignment: .firstBaseline) {
			NSTextField(labelWithString: ".standard")
				.font(.monospaced)
			NSPathControl(fileURL: path1)
				.compressionResistancePriority(.defaultLow, for: .horizontal)
				.onAction {
					Swift.print("Clicked path '\($0?.path ?? "")")
				}
				.onPathItemAction {
					Swift.print("Clicked cell '\($0?.title ?? "")'")
				}
		}

		NSGridView.Row(rowAlignment: .firstBaseline) {
			NSTextField(labelWithString: ".popup")
				.font(.monospaced)
			NSPathControl(fileURL: path2)
				.pathStyle(.popUp)
				.onAction {
					Swift.print("Clicked path '\($0?.path ?? "")")
				}
				.onPathItemAction {
					Swift.print("Clicked cell '\($0?.title ?? "")'")
					path2.wrappedValue = $0!.url!
				}
		}
	}
	.columnAlignment(.trailing, forColumn: 0)
	.padding()
}
#endif
