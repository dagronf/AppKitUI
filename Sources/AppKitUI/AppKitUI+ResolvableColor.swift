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

/// A color that can be resolved for the current appearance
public protocol AUIResolvableColor {
	/// The resolved color
	var effectiveColor: NSColor { get }
}

public extension AUIResolvableColor {
	/// Return the effective CGColor for this color based on the application's appearance
	var effectiveCGColor: CGColor { self.effectiveColor.effectiveCGColor }
}

// MARK: - NSColor

extension NSColor: AUIResolvableColor {
	/// The resolved color
	public var effectiveColor: NSColor { self }
}

public extension AUIResolvableColor where Self == NSColor {
	@inlinable
	static func color(_ color: NSColor?) -> AUIResolvableColor {
		return color ?? NSColor.clear
	}
}

// MARK: - DynamicColor

/// A dynamic color that can adapt to the current application appearance
public struct DynamicColor: Equatable, AUIResolvableColor {
	/// The dark mode color
	public let dark: NSColor
	/// The light mode color
	public let light: NSColor
	/// Create a DynamicColor
	public init(dark: NSColor, light: NSColor) {
		self.dark = dark.copy() as! NSColor
		self.light = light.copy() as! NSColor
	}

	/// The effective color, based on the application's current appearance setting
	public var effectiveColor: NSColor {
		if #available(macOS 10.14, *) {
			if NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua {
				return self.dark
			}
		}
		return self.light
	}

	/// The effective CGColor for the current appearance
	public var effectiveCGColor: CGColor {
		self.effectiveColor.effectiveCGColor
	}
}

public extension AUIResolvableColor where Self == DynamicColor {
	/// Create a solid color fill
	/// - Parameters:
	///   - dark: The color to use in dark mode
	///   - light: The color to use in light mode
	/// - Returns: A new fill style
	@inlinable
	static func dynamicColor(dark: NSColor, light: NSColor) -> AUIResolvableColor {
		return DynamicColor(dark: dark, light: light)
	}
}
