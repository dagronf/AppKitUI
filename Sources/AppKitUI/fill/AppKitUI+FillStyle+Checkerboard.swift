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

// A checkerboard fill style

import AppKit

public extension AUIShapeFillable where Self == AUIFillStyle.Checkerboard {
	/// Create a solid color fill
	/// - Parameters:
	///   - color1: The first fill color
	///   - color2: The second fill color
	///   - dimension: The width and height for each check
	/// - Returns: A new fill style
	static func checkerboard(color1: NSColor = .white, color2: NSColor = .black, dimension: Double = 8) -> AUIShapeFillable {
		AUIFillStyle.Checkerboard(color1: color1, color2: color2, dimension: dimension)
	}

	/// Create a solid color fill
	/// - Parameters:
	///   - color1: The first fill color
	///   - color2: The second fill color
	///   - dimension: The width and height for each check
	/// - Returns: A new fill style
	static func checkerboard(color1: DynamicColor, color2: DynamicColor, dimension: Double = 8) -> AUIShapeFillable {
		AUIFillStyle.Checkerboard(color1: color1, color2: color2, dimension: dimension)
	}
}

public extension AUIFillStyle {
	/// A solid color fill style
	class Checkerboard: AUIShapeFillable {
		/// Create a checkerboard fill style
		/// - Parameters:
		///   - color1: The first fill color
		///   - color2: The second fill color
		///   - dimension: The width and height for each check
		public init(color1: NSColor = .white, color2: NSColor = .black, dimension: Double = 8) {
			self.color1 = color1
			self.color2 = color2
			self.dimension = dimension
			self.appearanceDidChange()
		}

		/// Create a checkerboard fill style
		/// - Parameters:
		///   - color1: The first fill color
		///   - color2: The second fill color
		///   - dimension: The width and height for each check
		public init(color1: DynamicColor, color2: DynamicColor, dimension: Double = 8) {
			self.color1 = color1
			self.color2 = color2
			self.dimension = dimension
			self.appearanceDidChange()
		}

		/// Returns a layer that contains the fill color
		public func backgroundLayer() -> CALayer { self.layer }

		/// Called when the colors need updating
		public func appearanceDidChange() {
			let width = NSNumber(value: Float(dimension))
			let center = CIVector(cgPoint: CGPoint(x: 0, y: 0))
			let darkColor = CIColor(cgColor: color1.effectiveColor.cgColor)
			let lightColor = CIColor(cgColor: color2.effectiveColor.cgColor)
			let sharpness = NSNumber(value: 1.0)

			self.filter.setDefaults()
			self.filter.setValue(width, forKey: "inputWidth")
			self.filter.setValue(center, forKey: "inputCenter")
			self.filter.setValue(darkColor, forKey: "inputColor0")
			self.filter.setValue(lightColor, forKey: "inputColor1")
			self.filter.setValue(sharpness, forKey: "inputSharpness")

			self.layer.backgroundFilters = [filter]
		}

		// MARK: - Private

		private let color1: AUIResolvableColor
		private let color2: AUIResolvableColor
		private let dimension: Double

		private let layer = CALayer()
		private let filter = CIFilter(name: "CICheckerboardGenerator")!
	}
}

// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("checkerboard") {
	VStack {
		HStack(spacing: 20) {
			NSView()
				.identifier("1")
				.onClickGesture {
					Swift.print("User clicked 1")
				}
				.background(
					Rectangle()
						.fill(.checkerboard(color1: .textColor.alpha(0.2), color2: .textBackgroundColor.alpha(0.2), dimension: 8))
						.stroke(.tertiaryLabelColor, lineWidth: 1)
				)
			NSView()
				.identifier("2")
				.onClickGesture {
					Swift.print("User clicked 2")
				}
				.background(
					Rectangle(cornerRadius: 20)
						.fill(.checkerboard(color1: .blue.alpha(0.1), color2: .red.alpha(0.1), dimension: 8))
						.stroke(.tertiaryLabelColor, lineWidth: 1)
				)
		}

		NSView()
			.background(
				Capsule()
					.alphaValue(0.2)
					.fill(.checkerboard(color1: .quaternaryLabelColor, color2: .tertiaryLabelColor, dimension: 16))
					.height(50)
			)
	}
	.equalSizes(["1", "2"])
	.padding(30)
}

#endif
