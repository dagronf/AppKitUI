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
}
