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

import AppKit

/// A simple view that displays an image that fills the view.
///
/// The view itself has no implicit size, it is up to the caller to specify a size.
@MainActor
public class AUIImage: NSView {
	/// Create an image view
	public convenience init() {
		self.init(frame: .zero)
		self.translatesAutoresizingMaskIntoConstraints = false
		self.wantsLayer = true
	}

	/// Create a image view
	/// - Parameter image: The image to display
	public convenience init(image: NSImage) {
		self.init()
		self.build(image)
	}

	/// Create an image vew from a CGImage
	/// - Parameter cgImage: The image to display
	public convenience init(cgImage: CGImage) {
		self.init()
		self.build(NSImage(cgImage: cgImage, size: .zero))
	}

	/// Create an image view
	/// - Parameter name: The name for the image
	public convenience init(named name: String) {
		self.init()
		let image = NSImage(named: name) ?? AUIImage.cautionImage__
		self.build(image)
	}

	/// Create an image view
	/// - Parameter systemSymbolName: The symbol name
	@available(macOS 11.0, *)
	public convenience init(systemSymbolName: String) {
		self.init()
		let image = NSImage(systemSymbolName: systemSymbolName, accessibilityDescription: nil) ?? AUIImage.cautionImage__
		self.build(image)
	}
}

// MARK: - Bindings

@MainActor
public extension AUIImage {
	/// Create an image view
	/// - Parameter image: The image binding
	convenience init(image: Bind<NSImage?>) {
		self.init()
		self.image(image)
	}

	/// Set the image for the view
	/// - Parameter value: The image binding
	/// - Returns: self
	@discardableResult
	func image(_ value: Bind<NSImage?>) -> Self {
		value.register(self) { @MainActor [weak self] image in
			self?.build(image)
		}
		self.build(value.wrappedValue)
		return self
	}
}

// MARK: - Private

@MainActor
private extension AUIImage {
	static private let cautionImage__ = NSImage(named: NSImage.cautionName)!
	private func build(_ image: NSImage?) {
		guard let image = image?.makeCopy() else {
			self.rootLayer.contents = nil
			return
		}

		image.resizingMode = .stretch
		self.rootLayer.contents = image
	}
}

// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("default") {

	let image1 = NSImage(named: NSImage.bonjourName)!
	let image2 = NSImage(named: NSImage.computerName)!

	let selected = Bind(1)
	let image = Bind<NSImage?>(image1)

	VStack {
		NSBox(title: "scaling") {
			HStack {
				AUIImage(named: NSImage.colorPanelName)
					.frame(dimension: 120)
				AUIImage(named: NSImage.colorPanelName)
					.frame(dimension: 80)
				AUIImage(named: NSImage.colorPanelName)
					.frame(dimension: 40)
				AUIImage(named: NSImage.colorPanelName)
					.frame(dimension: 20)
					.toolTip("This is the smallest image")

				HDivider()

				AUIImage(named: NSImage.colorPanelName)
					.frame(width: 80, height: 30)
				AUIImage(named: NSImage.colorPanelName)
					.frame(width: 30, height: 80)
			}
		}
		.huggingPriority(.init(10), for: .horizontal)

		NSBox(title: "invalid named image") {
			HStack {
				AUIImage(named: "fish")
					.frame(dimension: 60)
			}
			.hugging(.init(10), for: .horizontal)
		}
		.huggingPriority(.init(10), for: .horizontal)

		NSBox(title: "image bind") {

			HStack {
				AUIImage(image: image)
					.frame(dimension: 48)
					.padding(8)
					.debugFrame()
				NSSegmentedControl()
					.segments(["none", "bonjour", "computer"])
					.selectedIndex(selected)
					.onSelectionChange { newSelection in
						switch newSelection {
						case 0:
							image.wrappedValue = nil
						case 1:
							image.wrappedValue = image1
						case 2:
							image.wrappedValue = image2
						default:
							fatalError()
						}
					}
			}
			.hugging(.init(10), for: .horizontal)
		}
		.huggingPriority(.init(10), for: .horizontal)
	}
	//.debugFrames()
}

#endif
