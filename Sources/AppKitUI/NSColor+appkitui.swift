//
//  Copyright © 2026 Darren Ford. All rights reserved.
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

import AppKit.NSColor

extension NSColor {
	/// Returns the user's current accent color.
	///
	/// Note that before 10.14, there is no concept of an 'accent' color and older macOS seems to be
	/// oddly inconsistent in its use.
	@inlinable
	public static var standardAccentColor: NSColor {
		if #available(macOS 10.14, *) {
			// macOS 10.14 and above have a dedicated static NSColor
			return NSColor.controlAccentColor
		}
		else {
			// Just use the menu highlight color - there's no concept of 'accent' color pre 10.14
			return NSColor.selectedMenuItemColor
		}
	}

	/// Return a lighter representation of this color
	@discardableResult @inlinable
	public func lighter(withLevel value: Double) -> NSColor {
		self.highlight(withLevel: value) ?? self
	}

	/// Return a darker representation of this color
	@discardableResult @inlinable
	public func darker(withLevel value: Double) -> NSColor {
		self.shadow(withLevel: value) ?? self
	}

	/// Return a representation of this color with a modified alpha value
	@discardableResult @inlinable
	public func alpha(_ alphaValue: Double) -> NSColor {
		let a = max(0, min(1, alphaValue))
		return self.withAlphaComponent(a)
	}
}


// MARK: - Appearance handling

// https://christiantietze.de/posts/2021/10/nscolor-performAsCurrentDrawingAppearance-resolve-current-appearance/

extension NSAppearanceCustomization {
	@discardableResult
	func performWithEffectiveAppearanceAsDrawingAppearance<T>(_ block: () -> T) -> T {
		// Similar to `NSAppearance.performAsCurrentDrawingAppearance`, but
		// works below macOS 11 and assigns to `result` properly
		// (capturing `result` inside a block doesn't work the way we need).
		if #available(macOS 10.14, *) {
			let old = NSAppearance.current
			NSAppearance.current = self.effectiveAppearance
			defer { NSAppearance.current = old }
			return block()
		}
		else {
			return block()
		}
	}

	/// Return the CGColor for this color that matches the effective appearance for this item
	/// - Parameter color: The color
	/// - Returns: self
	func effectiveCGColor(color: NSColor) -> CGColor {
		if #available(macOS 10.14, *) {
			return self.performWithEffectiveAppearanceAsDrawingAppearance { color.cgColor }
		}
		else {
			return color.cgColor
		}
	}

}

extension NSColor {
	/// Uses the `NSApplication.effectiveAppearance`.
	/// If you need per-view accurate appearance, prefer this instead:
	///
	///     let cgColor = aView.performWithEffectiveAppearanceAsDrawingAppearance { aColor.cgColor }
	func effectiveCGColor(for view: NSView) -> CGColor {
		if #available(macOS 10.14, *) {
			return view.performWithEffectiveAppearanceAsDrawingAppearance { self.cgColor }
		}
		else {
			return self.cgColor
		}
	}
}
