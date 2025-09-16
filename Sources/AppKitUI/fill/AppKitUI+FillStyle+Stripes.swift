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

// A stripes fill style

import AppKit

public extension AUIShapeFillable where Self == AUIFillStyle.Stripes {
	/// Create a solid color fill
	/// - Parameters:
	///   - color1: The first fill color
	///   - color2: The second fill color
	///   - width: The stripe width
	///   - rotateDegrees: The rotation angle to apply to the stripes
	///   - center: The x and y position to use as the center of the stripe pattern.
	/// - Returns: A new fill style
	static func stripes(color1: NSColor = .white, color2: NSColor = .black, width: Double = 8, rotateDegrees: Double = -45, center: CGPoint = .zero) -> AUIShapeFillable {
		AUIFillStyle.Stripes(color1: color1, color2: color2, width: width, rotateDegrees: rotateDegrees, center: center)
	}

	/// Create a solid color fill
	/// - Parameters:
	///   - color1: The first fill color
	///   - color2: The second fill color
	///   - width: The stripe width
	///   - rotateDegrees: The rotation angle to apply to the stripes
	///   - center: The x and y position to use as the center of the stripe pattern.
	/// - Returns: A new fill style
	static func stripes(color1: DynamicColor, color2: DynamicColor, width: Double = 8, rotateDegrees: Double = -45, center: CGPoint = .zero) -> AUIShapeFillable {
		AUIFillStyle.Stripes(color1: color1, color2: color2, width: width, rotateDegrees: rotateDegrees, center: center)
	}
}

public extension AUIFillStyle {
	/// A stripes fill style
	class Stripes: AUIShapeFillable {
		/// Create a stripes fill style
		/// - Parameters:
		///   - color1: The first fill color
		///   - color2: The second fill color
		///   - width: The stripe width
		///   - rotateDegrees: The rotation angle to apply to the stripes
		///   - center: The x and y position to use as the center of the stripe pattern.
		public init(
			color1: NSColor = .white,
			color2: NSColor = .black,
			width: Double = 8,
			rotateDegrees: Double = -45,
			center: CGPoint = .zero
		) {
			self.color1 = color1
			self.color2 = color2
			self.width = width
			self.rotateDegrees = rotateDegrees
			self.center = center
			self.appearanceDidChange(for: nil)
		}

		/// Create a checkerboard fill style
		/// - Parameters:
		///   - color1: The first fill color
		///   - color2: The second fill color
		///   - width: The stripe width
		///   - rotateDegrees: The rotation angle to apply to the stripes
		///   - center: The x and y position to use as the center of the stripe pattern.
		public init(
			color1: DynamicColor,
			color2: DynamicColor,
			width: Double = 8,
			rotateDegrees: Double = -45,
			center: CGPoint = .zero
		) {
			self.color1 = color1
			self.color2 = color2
			self.width = width
			self.rotateDegrees = rotateDegrees
			self.center = center
			self.appearanceDidChange(for: nil)
		}

		/// Returns a layer that contains the fill color
		public func backgroundLayer() -> CALayer { self.layer }

		/// Called when the colors need updating
		public func appearanceDidChange(for view: NSView?) {
			let width = NSNumber(value: Float(self.width))
			let center = CIVector(cgPoint: self.center)
			let darkColor = CIColor(cgColor: color1.effectiveCGColor(for: view))
			let lightColor = CIColor(cgColor: color2.effectiveCGColor(for: view))

			self.stripesFilter.setDefaults()
			self.stripesFilter.setValue(width, forKey: "inputWidth")
			self.stripesFilter.setValue(center, forKey: "inputCenter")
			self.stripesFilter.setValue(darkColor, forKey: "inputColor0")
			self.stripesFilter.setValue(lightColor, forKey: "inputColor1")

			self.rotateFilter.setDefaults()
			let inputTransformTransform = AffineTransform(rotationByDegrees: self.rotateDegrees)
			self.rotateFilter.setValue(inputTransformTransform, forKey: kCIInputTransformKey)

			self.layer.backgroundFilters = [stripesFilter, rotateFilter]
		}

		// MARK: - Private

		private let color1: AUIResolvableColor
		private let color2: AUIResolvableColor
		private let width: Double
		private let center: CGPoint
		private let rotateDegrees: Double

		private let layer = CALayer()
		private let stripesFilter = CIFilter(name: "CIStripesGenerator")!
		private let rotateFilter = CIFilter(name: "CIAffineTransform")!
	}
}

// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("stripes") {
	NSView(layoutStyle: .centered) {

		HStack {
			Rectangle()
				.fill(.stripes(color1: .textColor.alpha(0.2), color2: .textBackgroundColor.alpha(0.2), width: 8))
				.stroke(.tertiaryLabelColor, lineWidth: 1)
				.frame(width: 100, height: 80)

			Rectangle(cornerRadius: 20)
				.fill(.stripes(color1: .blue.alpha(0.1), color2: .red.alpha(0.1), width: 8, rotateDegrees: 45))
				.stroke(.tertiaryLabelColor, lineWidth: 1)
				.frame(width: 100, height: 80)

			Capsule()
				.fill(.stripes(color1: .quaternaryLabelColor, color2: .tertiaryLabelColor, width: 16))
				.stroke(.tertiaryLabelColor, lineWidth: 1)
				.frame(width: 100, height: 80)

			Capsule()
				.fill(.stripes(color1: .underPageBackgroundColor, color2: .windowBackgroundColor, width: 24, rotateDegrees: 0))
				.stroke(.tertiaryLabelColor, lineWidth: 1)
				.frame(width: 100, height: 80)
		}
	}
}

#endif
