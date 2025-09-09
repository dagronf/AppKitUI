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

public extension AUIShapeFillable where Self == AUIFillStyle.Gradient {
	/// Create a gradient with a slightly shaded single color
	static func gradient(color: NSColor) -> AUIShapeFillable {
		AUIFillStyle.Gradient(color: color)
	}

	/// Create a gradient evenly spaced between the colors
	static func gradient(colors: [NSColor], startPoint: CGPoint, endPoint: CGPoint) -> AUIShapeFillable {
		AUIFillStyle.Gradient(colors: colors, startPoint: startPoint, endPoint: endPoint)
	}

	/// Create a gradient
	static func gradient(stops: [AUIFillStyle.Gradient.Stop], startPoint: CGPoint, endPoint: CGPoint) -> AUIShapeFillable {
		AUIFillStyle.Gradient(stops: stops, startPoint: startPoint, endPoint: endPoint)
	}
}

public extension AUIFillStyle {
	/// A fill gradient
	class Gradient: AUIShapeFillable {
		/// A stop in a gradient
		public struct Stop {
			public let color: NSColor
			public let location: Double
		}

		/// Create a gradient with equally spaced colors
		/// - Parameters:
		///   - colors: The colors
		///   - startPoint: The start point of the gradient when drawn in the layer’s coordinate space
		///   - endPoint: The end point of the gradient when drawn in the layer’s coordinate space
		public init(colors: [NSColor], startPoint: CGPoint, endPoint: CGPoint) {
			self.colors = colors
			self.startPoint = startPoint
			self.endPoint = endPoint
			self.appearanceDidChange()
		}

		/// Create a gradient
		/// - Parameters:
		///   - stops: The gradient stops
		///   - startPoint: The start point of the gradient when drawn in the layer’s coordinate space
		///   - endPoint: The end point of the gradient when drawn in the layer’s coordinate space
		public init(stops: [Stop], startPoint: CGPoint, endPoint: CGPoint) {
			self.colors = stops.map { $0.color }
			self.locations = stops.map { $0.location }
			self.startPoint = startPoint
			self.endPoint = endPoint
			self.appearanceDidChange()
		}

		/// Create a gradient from a single color
		/// - Parameters:
		///   - color: The color
		///   - startPoint: The start point of the gradient when drawn in the layer’s coordinate space
		///   - endPoint: The end point of the gradient when drawn in the layer’s coordinate space
		public init(color: NSColor, startPoint: CGPoint = CGPoint(x: 0, y: 0), endPoint: CGPoint = CGPoint(x: 0, y: 1)) {
			let lighter = color.highlight(withLevel: 0.25) ?? color
			let darker = color.shadow(withLevel: 0.25) ?? color
			self.colors = [darker, lighter]
			self.startPoint = startPoint
			self.endPoint = endPoint
			self.appearanceDidChange()
		}

		/// The gradient stop colors
		public var colors: [NSColor] = [.black, .white] {
			didSet {
				self.appearanceDidChange()
			}
		}

		/// The gradient stop location colors
		public var locations: [Double]? = nil {
			didSet {
				self.appearanceDidChange()
			}
		}

		/// The start point of the gradient when drawn in the layer’s coordinate space
		public var startPoint: CGPoint = .init(x: 0, y: 0) {
			didSet {
				self.appearanceDidChange()
			}
		}

		/// The end point of the gradient when drawn in the layer’s coordinate space
		public var endPoint: CGPoint = .init(x: 1, y: 0) {
			didSet {
				self.appearanceDidChange()
			}
		}

		/// Generate a layer that draws the gradient
		public func backgroundLayer() -> CALayer {
			self.gradientLayer
		}

		public func appearanceDidChange() {
			self.gradientLayer.colors = self.colors.map { $0.cgColor }
			self.gradientLayer.locations = self.locations?.map { NSNumber(value: $0) }
			self.gradientLayer.startPoint = self.startPoint
			self.gradientLayer.endPoint = self.endPoint		}

		private let gradientLayer = CAGradientLayer()
	}
}
