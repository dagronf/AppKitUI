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

public extension AUIShapeFillable where Self == AUIFillStyle.Color {
	/// Create a solid color fill
	/// - Parameter color: The fill color
	/// - Returns: A new fill style
	static func color(_ color: NSColor?) -> AUIShapeFillable {
		if let color {
			return AUIFillStyle.Color(color: color)
		}
		return AUIFillStyle.Color(color: NSColor.clear)
	}

	/// Create a solid color fill
	/// - Parameter color: The fill color
	/// - Returns: A new fill style
	static func color(_ color: DynamicColor) -> AUIShapeFillable {
		AUIFillStyle.Color(color: color)
	}

	/// Create a solid color fill
	/// - Parameters:
	///   - darkColor: The fill color for dark mode
	///   - lightColor: The fill color for light mode
	/// - Returns: A new fill style
	static func color(darkColor: NSColor, lightColor: NSColor) -> AUIShapeFillable {
		AUIFillStyle.Color(darkColor: darkColor, lightColor: lightColor)
	}
}


public extension AUIFillStyle {
	/// A solid color fill style
	class Color: AUIShapeFillable {
		/// Create a solid color
		/// - Parameter color: The color
		public init(color: AUIResolvableColor?) {
			if let color {
				self.color = color
			}
			else {
				self.color = NSColor.clear
			}
			self.appearanceDidChange()
		}

		/// Create a solid color
		/// - Parameters:
		///   - darkColor: The fill color for dark mode
		///   - lightColor: The fill color for light mode
		public convenience init(darkColor: NSColor, lightColor: NSColor) {
			self.init(color: DynamicColor(dark: darkColor, light: lightColor))
		}

		/// Set the color
		public var color: AUIResolvableColor = NSColor.white {
			didSet {
				self.appearanceDidChange()
			}
		}

		/// Returns a layer that contains the fill color
		public func backgroundLayer() -> CALayer { self.layer }

		/// Called when the colors need updating
		public func appearanceDidChange() {
			self.layer.backgroundColor = self.color.effectiveColor.cgColor
		}

		// MARK: - Private

		private let layer = CALayer()
	}
}


// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("basic") {
	HStack {
		NSBox(title: "Static Colors") {
			HStack {
				Capsule()
					.fill(color: .white)
					.stroke(.purple, lineWidth: 2)
					.frame(width: 100, height: 50)
				Capsule()
					.fill(color: .black)
					.stroke(.orange, lineWidth: 2)
					.frame(width: 100, height: 50)
			}
			.padding(8)
		}
		NSBox(title: "Dynamic Colors") {
			HStack {
				Capsule()
					.fill(color: .textColor)
					.stroke(.systemPink, lineWidth: 2)
					.frame(width: 100, height: 50)

				Capsule()
					.fill(color: DynamicColor(dark: .red.alpha(0.6), light: .blue.alpha(0.6)))
					.stroke(DynamicColor(dark: .green, light: .yellow), lineWidth: 2)
					.frame(width: 100, height: 50)
			}
			.padding(8)
		}
	}
}

#endif
