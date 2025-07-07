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

import AppKit.NSComboButton

@available(macOS 13, *)
@MainActor
public extension NSComboButton {
	
	/// Create a combo button
	/// - Parameters:
	///   - title: The button title
	///   - image: The image
	///   - style: The combo button style
	///   - menu: The associated menu
	///   - onAction: A block to call when the action is called for the button
	convenience init(
		title: String,
		image: NSImage? = nil,
		style: NSComboButton.Style = .split,
		menu: NSMenu? = nil,
		onAction: ((NSComboButton) -> Void)? = nil
	) {
		self.init()

		self.title = title
		self.image = image
		self.style = style

		if let onAction {
			self.usingComboButtonStorage { $0.onAction = onAction }
		}
	}
}

// MARK: Modifiers

@available(macOS 13, *)
@MainActor
public extension NSComboButton {
	/// Set the title
	/// - Parameter value: The title
	/// - Returns: self
	@discardableResult @inlinable
	func title(_ value: String) -> Self {
		self.title = value
		return self
	}

	/// Set the combo button style
	/// - Parameter value: The style
	/// - Returns: self
	@discardableResult @inlinable
	func style(_ value: NSComboButton.Style) -> Self {
		self.style = value
		return self
	}

	/// Set the image and image scaling
	/// - Parameters:
	///   - value: The image
	///   - imageScaling: The image scaling
	/// - Returns: self
	@discardableResult @inlinable
	func image(_ value: NSImage, imageScaling: NSImageScaling = .scaleProportionallyDown) -> Self {
		self.image = value
		self.imageScaling = imageScaling
		return self
	}

	/// Set the menu
	/// - Parameter value: the menu
	/// - Returns: self
	func menu(_ value: NSMenu) -> Self {
		self.menu = value
		return self
	}

	/// Create a menu using menu items
	/// - Parameter builder: The function for building
	/// - Returns: self
	@discardableResult
	func menu(@NSMenuItemsBuilder builder: () -> [NSMenuItem]) -> Self {
		let menu = NSMenu(title: self.title, items: builder())
		return self.menu(menu)
	}
}

// MARK: Actions

@available(macOS 13, *)
@MainActor
public extension NSComboButton {
	@discardableResult
	func onAction(_ action: @escaping (NSComboButton) -> Void) -> Self {
		self.usingComboButtonStorage { $0.onAction = action }
		return self
	}
}

// MARK: Binding

@available(macOS 13, *)
@MainActor
public extension NSComboButton {
	/// Bind the button's titlte
	/// - Parameter title: The title binder
	/// - Returns: self
	func title(_ title: Bind<String>) -> Self {
		title.register(self) { @MainActor [weak self] newTitle in
			if self?.title != newTitle {
				self?.title = newTitle
			}
		}
		self.title = title.wrappedValue
		return self
	}
}

// MARK: - Control storage

@available(macOS 13, *)
private extension NSComboButton {
	class Storage: @unchecked Sendable {
		weak var parent: NSComboButton?
		var onAction: ((NSComboButton) -> Void)?

		@MainActor init(_ control: NSComboButton) {
			self.parent = control
			control.target = self
			control.action = #selector(performAction(_:))
		}

		@MainActor
		@objc private func performAction(_ sender: NSComboButton) {
			self.onAction?(sender)
		}
	}

	func usingComboButtonStorage(_ block: @escaping (Storage) -> Void) {
		self.usingAssociatedValue(key: "__nscombobutton_bond", initialValue: { Storage(self) }, block)
	}
}

// MARK: - Previews

#if DEBUG

@MainActor let _debugImage = NSImage(named: NSImage.colorPanelName)!

@available(macOS 14, *)
#Preview("default") {
	let title = Bind("Title")
	VStack {
		HStack {
			NSComboButton(title: "Wheeee!") { _ in
				Swift.print("activated!")
			}
			.menu(
				NSMenu(title: "title") {
					NSMenuItem(title: "first")
						.image(systemSymbolName: "0.circle")
						.onAction { _ in Swift.print("zero") }
					NSMenuItem(title: "second")
						.image(systemSymbolName: "1.circle")
						.onAction { _ in Swift.print("zero") }
				}
			)

			NSComboButton(title: "Wheeee!") { _ in
				Swift.print("activated!")
			}
			.isEnabled(false)
		}

		HStack {
			NSComboButton(title: "No menu", style: .unified) { _ in
				Swift.print("No menu activated!")
			}

			NSComboButton(title: "Has a menu", style: .unified) { _ in
				Swift.print("activated!")
			}
			.menu {
				NSMenuItem(title: "first")
					.image(systemSymbolName: "0.circle")
					.onAction { _ in Swift.print("zero") }
				NSMenuItem(title: "second")
					.image(systemSymbolName: "1.circle")
					.onAction { _ in Swift.print("zero") }
			}

			NSComboButton(title: "Disabled") { _ in
				Swift.print("activated!")
			}
			.style(.unified)
			.isEnabled(false)
		}

		HStack {
			NSComboButton(title: "Image!")
				.controlSize(.large)
				.image(_debugImage)
				.onAction { _ in
					Swift.print("large activated!")
				}
			NSComboButton(title: "Image!")
				.image(_debugImage)
				.onAction { _ in
					Swift.print("regular activated!")
				}
			NSComboButton(title: "Image!")
				.controlSize(.small)
				.font(.systemSmall)
				.image(_debugImage)
				.onAction { _ in
					Swift.print("small activated!")
				}
			NSComboButton(title: "Image!")
				.controlSize(.mini)
				.font(.systemMini)
				.image(_debugImage)
				.onAction { _ in
					Swift.print("mini activated!")
				}
		}

		HStack {
			NSTextField(label: title)
				.isEditable(true)
				.isBezeled(true)
				.width(100)
			NSComboButton(title: "")
				.title(title)
				.width(100)
		}

	}
}

#endif
