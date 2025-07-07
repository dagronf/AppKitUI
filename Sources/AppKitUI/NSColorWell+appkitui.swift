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

import AppKit.NSColorWell
import AppKit.NSColor

@MainActor
public extension NSColorWell {

	/// The colorwell style.  Ignored for macOS < 13
	enum ColorWellStyle {
		case minimal
		case expanded
	}

	/// Create a colorwell with a style
	/// - Parameter colorWellStyle: The colorwell style
	///
	/// Backwards compatible initializer. Style parameter is ignored for macOS < 13
	convenience init(colorWellStyle: NSColorWell.ColorWellStyle) {
		self.init()
		if #available(macOS 13, *) {
			switch colorWellStyle {
			case .minimal: self.colorWellStyle = .minimal
			case .expanded: self.colorWellStyle = .expanded
			}
		}
	}

	/// Set the initial color for the well
	/// - Parameter color: The color
	/// - Returns: self
	@discardableResult @inlinable
	func color(_ color: NSColor) -> Self {
		self.color = color
		return self
	}

	/// Set the initial color for the well
	/// - Parameter color: The color
	/// - Returns: self
	@discardableResult @inlinable
	func color(_ color: CGColor) -> Self {
		self.color = NSColor(cgColor: color) ?? .black
		return self
	}

	/// Display a border
	/// - Parameter value: Whether to display a border
	/// - Returns: self
	@discardableResult @inlinable
	func isBordered(_ value: Bool) -> Self {
		self.isBordered = value
		return self
	}

	/// Set whether this color well supports alpha
	/// - Parameter value: If true, supports alpha
	/// - Returns: self
	///
	/// For os versions earlier than 14, set the `ignoresAlpha` flag
	/// https://developer.apple.com/documentation/appkit/nscolor/ignoresalpha
	@available(macOS 14.0, *)
	@discardableResult @inlinable
	func supportsAlpha(_ value: Bool) -> Self {
		self.supportsAlpha = value
		return self
	}

	/// Set the style for the color well
	/// - Parameter style: The style
	/// - Returns: self
	@available(macOS 13.0, *)
	@discardableResult @inlinable
	func style(_ style: NSColorWell.Style) -> Self {
		self.colorWellStyle = style
		return self
	}
}

// MARK: Actions

@MainActor
public extension NSColorWell {
	/// A block to call when the selected menu item changes
	/// - Parameter change: The block to call
	/// - Returns: self
	@discardableResult
	func onColorChange(_ change: @escaping (NSColor) -> Void) -> Self {
		self.usingColorWellStorage { $0.onColorChange = change }
		return self
	}
}

// MARK: Binding

@MainActor
public extension NSColorWell {
	/// A block to call when the selected menu item changes
	/// - Parameter color: The color binding
	/// - Returns: self
	@discardableResult
	func color(_ color: Bind<NSColor>) -> Self {
		color.register(self) { @MainActor [weak self] newSelection in
			guard let `self` = self else { return }
			if self.color != newSelection {
				self.color = newSelection
			}
		}
		self.color = color.wrappedValue
		self.usingColorWellStorage { $0.color = color }
		return self
	}
}

// MARK: - Control storage

private extension NSColorWell {
	class Storage: @unchecked Sendable {
		var onColorChange: ((NSColor) -> Void)?
		var color: Bind<NSColor>?

		@MainActor init(_ control: NSColorWell) {
			control.target = self
			control.action = #selector(colorChanged(_:))
		}

		@MainActor @objc func colorChanged(_ sender: NSColorWell) {
			self.color?.wrappedValue = sender.color
			self.onColorChange?(sender.color)
		}
	}

	func usingColorWellStorage(_ block: @escaping (Storage) -> Void) {
		self.usingAssociatedValue(key: "__nscolorwell_bond", initialValue: { Storage(self) }, block)
	}
}

// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("default") {
	let color = Bind(NSColor.systemBlue)

	VStack {
		HStack {
			NSColorWell()
				.supportsAlpha(false)
				.color(color)
			NSColorWell()
				.supportsAlpha(false)
				.color(color)
		}

		NSColorWell(colorWellStyle: .expanded)
			.supportsAlpha(true)
			.color(.systemBrown)
			.onColorChange { newColor in
				Swift.print("new color is \(newColor)")
			}
			.frame(width: 80)
	}
}
#endif
