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

import AppKit.NSImageView
import os.log

@MainActor
public extension NSImageView {
	/// Create an NSImageView containing an image with the specified image name
	/// - Parameter name: The image name
	///
	/// If the image cannot be found, displays a placeholder caution image instead
	convenience init(imageNamed name: String) {
		let image = NSImage(named: name) ?? NSImage(named: NSImage.cautionName)!
		self.init(image: image)
	}

	/// Create a new imageview containing a system symbol (macOS 11 and later)
	/// - Parameter systemSymbolName: The symbol name
	@available(macOS 11.0, *)
	convenience init(systemSymbolName: String) {
		let image = NSImage(systemSymbolName: systemSymbolName, accessibilityDescription: nil) ?? NSImage(named: NSImage.cautionName)!
		self.init(image: image)
	}

	/// Set the frame style for the image view
	/// - Parameter frameStyle: The frame style
	/// - Returns: self
	@discardableResult @inlinable
	func frameStyle(_ frameStyle: NSImageView.FrameStyle) -> Self {
		self.imageFrameStyle = frameStyle
		return self
	}

	/// Does the image view allow changing the image by dropping a new image
	/// - Parameter value: Is the view editable?
	/// - Returns: self
	@discardableResult @inlinable
	func isEditable(_ value: Bool) -> Self {
		self.isEditable = value
		return self
	}

	/// Indicates whether the image view automatically plays animated images.
	/// - Parameter value: The animates state
	/// - Returns: self
	@discardableResult @inlinable
	func animates(_ value: Bool) -> Self {
		self.animates = value
		return self
	}

	/// Set the image view alignment
	/// - Parameter alignment: The alignment
	/// - Returns: self
	@discardableResult @inlinable
	func imageAlignment(_ alignment: NSImageAlignment) -> Self {
		self.imageAlignment = alignment
		return self
	}

	/// Set the image view scaling
	/// - Parameter scaling: The image scaling
	/// - Returns: self
	@discardableResult @inlinable
	func imageScaling(_ scaling: NSImageScaling) -> Self {
		self.imageScaling = scaling
		return self
	}

	/// Set the image view content tint color
	/// - Parameter color: The tint color
	/// - Returns: self
	@available(macOS 10.14, *)
	@discardableResult @inlinable
	func contentTintColor(_ color: NSColor?) -> Self {
		self.contentTintColor = color
		return self
	}
}

// MARK: - Bindings

@MainActor
public extension NSImageView {
	/// Set the image for the image view
	/// - Parameter image: The image
	/// - Returns: self
	func image(_ image: Bind<NSImage?>) -> Self {
		image.register(self) { @MainActor [weak self] newImage in
			if let self = self, self.image != newImage {
				self.image = newImage
			}
		}
		self.usingImageViewStorage { $0.imageBond = image }
		self.image = image.wrappedValue
		return self
	}
}

// MARK: - Storage

@MainActor
private extension NSImageView {
	@MainActor
	func usingImageViewStorage(_ block: @escaping (Storage) -> Void) {
		self.usingAssociatedValue(key: "__nsimageview_bond", initialValue: { Storage(self) }, block)
	}

	@MainActor
	class Storage: @unchecked Sendable {
		fileprivate var imageBond: Bind<NSImage?>?
		private var imageObserver: NSKeyValueObservation?

		struct ImageWrapper: @unchecked Sendable {
			let image: NSImage?
			init(image: NSImage?) {
				self.image = image?.copy() as? NSImage
			}
		}

		@MainActor
		init(_ imageView: NSImageView) {
			self.imageObserver = imageView.observe(\.image, options: [.old, .new]) { [weak self] view, change in
				guard let newValue = change.newValue else { return }
				let w = ImageWrapper(image: newValue)
				DispatchQueue.main.async { [weak self] in
					self?.imageDidChange(w)
				}
			}
		}

		deinit {
			os_log("deinit: NSImageView.Storage", log: logger, type: .debug)
		}

		@MainActor
		private func imageDidChange(_ newValue: ImageWrapper) {
			DispatchQueue.main.async { [weak self] in
				guard let `self` = self, let bond = self.imageBond else { return }
				if bond.wrappedValue != newValue.image {
					bond.wrappedValue = newValue.image
				}
			}
		}
	}
}

// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("default") {
	let image = Bind<NSImage?>(nil)
	VStack {
		NSImageView(systemSymbolName: "1.circle")
		NSImageView()
			.frameStyle(.grayBezel)
			.image(image)
			.isEditable(true)
			.frame(width: 100, height: 100)
			.onChange(image) { _ in
				Swift.print("Image did change...")
			}
	}
}

#endif

