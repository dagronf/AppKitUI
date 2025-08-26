//
//  NSColor+appkitui.swift
//  AppKitUI
//
//  Created by Darren Ford on 18/7/2025.
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
}

extension NSColor {
	/// Uses the `NSApplication.effectiveAppearance`.
	/// If you need per-view accurate appearance, prefer this instead:
	///
	///     let cgColor = aView.performWithEffectiveAppearanceAsDrawingAppearance { aColor.cgColor }
	var effectiveCGColor: CGColor {
		if #available(macOS 10.14, *) {
			return NSApp.performWithEffectiveAppearanceAsDrawingAppearance { self.cgColor }
		}
		else {
			return self.cgColor
		}
	}
}
