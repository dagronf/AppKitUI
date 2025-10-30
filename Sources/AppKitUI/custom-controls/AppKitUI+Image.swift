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
	/// The image aspect ratio
	public enum AspectRatio {
		/// The content is resized to fit the entire bounds rectangle.
		case none
		/// The content is resized to fit the bounds rectangle, preserving the aspect of the content. If the content does not completely fill the bounds rectangle, the content is centered in the partial axis.
		case fit
		/// The content is resized to completely fill the bounds rectangle, while still preserving the aspect of the content. The content is centered in the axis it exceeds.
		case fill

		// Map aspect ratio onto CALayerContentsGravity
		internal var gravity: CALayerContentsGravity {
			switch self {
			case .fill: return .resizeAspectFill
			case .fit:  return .resizeAspect
			case .none: return .resize
			}
		}
	}

	public override var wantsUpdateLayer: Bool { true }

	private var scale: Double = 1.0

	/// The layer that displays the image
	private lazy var imageLayer: CALayer = {
		let l = CALayer()
		self.rootLayer.addSublayer(l)
		return l
	}()

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

	public override func updateLayer() {
		super.updateLayer()

		// Scale the image layer within the bounds
		let nw = self.bounds.width - (self.bounds.width * self.scale)
		let nh = self.bounds.height - (self.bounds.height * self.scale)
		self.imageLayer.frame = self.bounds.insetBy(dx: nw / 2, dy: nh / 2)
	}
}

// MARK: - Modifiers

@MainActor
public extension AUIImage {
	/// Set the scale mode aspect ratio for the image
	/// - Parameter aspectRatio: The aspect ratio
	/// - Returns: self
	@discardableResult
	public func aspectRatio(_ aspectRatio: AUIImage.AspectRatio) -> Self {
		self.imageLayer.contentsGravity = aspectRatio.gravity
		return self
	}

	/// Set the scale for the image
	/// - Parameter scale: The scale
	/// - Returns: self
	@discardableResult
	public func scale(_ scale: Double) -> Self {
		self.scale = scale
		self.needsDisplay = true
		return self
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

	/// Set the image scale
	/// - Parameter value: The scale
	/// - Returns: self
	@discardableResult
	func scale(_ value: Bind<Double>) -> Self {
		value.register(self) { @MainActor [weak self] newScale in
			self?.scale(newScale)
		}
		self.scale(value.wrappedValue)
		return self
	}
}

// MARK: - Private

@MainActor
private extension AUIImage {
	static private let cautionImage__ = NSImage(named: NSImage.cautionName)!
	private func build(_ image: NSImage?) {
		guard let image = image?.makeCopy() else {
			self.imageLayer.contents = nil
			return
		}

		image.resizingMode = .stretch
		self.imageLayer.contents = image
	}
}

// MARK: - Previews

#if DEBUG

private let image1 = NSImage(named: NSImage.bonjourName)!
private let image2 = NSImage(named: NSImage.computerName)!

@available(macOS 14, *)
#Preview("default") {
	VStack {
		HStack {
			for sc in [120, 100, 80, 60, 40, 20] {
				AUIImage(named: NSImage.colorPanelName)
					.toolTip("image with frame size \(sc)")
					.frame(dimension: sc)
					.debugFrame()
			}
		}
	}
}

@available(macOS 14, *)
#Preview("aspect ratio") {
	HStack(spacing: 20) {
		VStack {
			HStack {
				AUIImage(named: NSImage.colorPanelName)
					.frame(width: 80, height: 30)
					.debugFrame(.systemOrange)
				AUIImage(named: NSImage.colorPanelName)
					.frame(width: 30, height: 80)
					.debugFrame(.systemOrange)
			}
			NSTextField(label: "none")
		}

		VDivider()

		VStack {
			HStack {
				AUIImage(named: NSImage.colorPanelName)
					.aspectRatio(.fill)
					.frame(width: 80, height: 30)
					.debugFrame(.systemCyan)
				AUIImage(named: NSImage.colorPanelName)
					.aspectRatio(.fill)
					.frame(width: 30, height: 80)
					.debugFrame(.systemCyan)
			}
			NSTextField(label: "fill")
		}

		VDivider()

		VStack {
			HStack {
				AUIImage(named: NSImage.colorPanelName)
					.aspectRatio(.fit)
					.frame(width: 80, height: 30)
					.debugFrame(.systemGreen)
				AUIImage(named: NSImage.colorPanelName)
					.aspectRatio(.fit)
					.frame(width: 30, height: 80)
					.debugFrame(.systemGreen)
			}
			NSTextField(label: "fit")
		}
	}
}

@available(macOS 14, *)
#Preview("image scaling") {
	HStack {
		for sc in [1.8, 1.6, 1.4, 1.2, 1.0, 0.8, 0.6, 0.4, 0.2, 0.0] {
			VStack {
				AUIImage(named: NSImage.colorPanelName)
					.aspectRatio(.fit)
					.scale(sc)
					.frame(width: 40, height: 40)
					.debugFrame(.systemPink)
				NSTextField(label: "\(sc)")
					.font(.monospaced.size(10))
			}
		}
	}
}

@available(macOS 14, *)
#Preview("invalid image") {
	AUIImage(named: "fish")
		.frame(dimension: 60)
}

@available(macOS 14, *)
#Preview("image binding") {
	let selected = Bind(1)
	let image = Bind<NSImage?>(image1)
	HStack {
		AUIImage(image: image)
			.frame(dimension: 48)
			.padding(8)
			.debugFrame()
		AUIImage(image: image)
			.aspectRatio(.fill)
			.scale(0.8)
			.frame(dimension: 128)
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
}

@available(macOS 14, *)
#Preview("scale binding") {
	let scale = Bind(1.0)
	VStack {
		HStack {
			AUIImage(named: NSImage.colorPanelName)
				.scale(scale)
				.aspectRatio(.none)
				.frame(dimension: 60)
				.debugFrame(.systemPink)
			AUIImage(named: NSImage.colorPanelName)
				.scale(scale)
				.aspectRatio(.none)
				.frame(width: 30, height: 60)
				.debugFrame(.systemPink)
			AUIImage(named: NSImage.colorPanelName)
				.scale(scale)
				.aspectRatio(.none)
				.frame(width: 80, height: 30)
				.debugFrame(.systemPink)
		}

		HStack {
			AUIImage(named: NSImage.colorPanelName)
				.scale(scale)
				.aspectRatio(.fill)
				.frame(dimension: 60)
				.debugFrame(.systemYellow)
			AUIImage(named: NSImage.colorPanelName)
				.scale(scale)
				.aspectRatio(.fill)
				.frame(width: 30, height: 60)
				.debugFrame(.systemYellow)
			AUIImage(named: NSImage.colorPanelName)
				.scale(scale)
				.aspectRatio(.fill)
				.frame(width: 80, height: 30)
				.debugFrame(.systemYellow)
		}

		HStack {
			AUIImage(named: NSImage.colorPanelName)
				.scale(scale)
				.aspectRatio(.fit)
				.frame(dimension: 60)
				.debugFrame(.systemCyan)
			AUIImage(named: NSImage.colorPanelName)
				.scale(scale)
				.aspectRatio(.fit)
				.frame(width: 30, height: 60)
				.debugFrame(.systemCyan)
			AUIImage(named: NSImage.colorPanelName)
				.scale(scale)
				.aspectRatio(.fit)
				.frame(width: 80, height: 30)
				.debugFrame(.systemCyan)
		}
		NSSlider(scale, range: 0.0 ... 2.0)
			.width(200)
	}
}

#endif
