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

/// A wrapper for the NSGlassEffectView. Supported on macOS 26.0+ and Xcode 26.0+
///
/// If you want a glass effect view that degrades nicely back to 10.13, take a look at the `GlassEffect` function.
///
/// Usage example :-
///
/// ```swift
/// NSGlassEffectView {
///    NSTextField(label: "Hello!")
///       .padding()
/// }
/// ```

import AppKit

#if canImport(AppKit.NSGlassEffectView)

/// Is `NSGlassEffectView` available?
public let AppKitUI_supportsNSGlassEffectView: Bool = true

@available(macOS 26.0, *)
@MainActor
public extension NSGlassEffectView {
	/// Create a glass effect view containing a view
	/// - Parameters:
	///   - style: The glass style
	///   - cornerRadius: The amount of curvature for all corners of the glass
	///   - tintColor: The color the glass effect view uses to tint the background and glass effect toward
	///   - viewBuilder: The content for the glass effect view
	convenience init(
		style: NSGlassEffectView.Style = .regular,
		cornerRadius: CGFloat? = nil,
		tintColor: NSColor? = nil,
		_ viewBuilder: () -> NSView
	) {
		self.init()
		self
			.translatesAutoresizingMaskIntoConstraints(false)
			.style(style)
			.tintColor(tintColor)
		if let cornerRadius {
			self.cornerRadius(cornerRadius)
		}

		let content = viewBuilder()
		content.translatesAutoresizingMaskIntoConstraints = false
		self.contentView = content
	}
}

// MARK: - Modifiers

@available(macOS 26.0, *)
@MainActor
extension NSGlassEffectView: AUIGlassEffectViewPresenting {
	/// The amount of curvature for all corners of the glass.
	/// - Parameter value: The curvature
	/// - Returns: self
	@discardableResult @inlinable
	public func cornerRadius(_ value: CGFloat) -> Self {
		self.cornerRadius = value
		return self
	}

	/// The style of glass this view uses.
	/// - Parameter style: The glass style
	/// - Returns: self
	@discardableResult @inlinable
	public func style(_ style: NSGlassEffectView.Style) -> Self {
		self.style = style
		return self
	}

	/// The color the glass effect view uses to tint the background and glass effect toward
	/// - Parameter color: The tint color
	/// - Returns: self
	@discardableResult @inlinable
	public func tintColor(_ color: NSColor?) -> Self {
		self.tintColor = color
		return self
	}
}

#else

/// Is `NSGlassEffectView` available?
public let AppKitUI_supportsNSGlassEffectView: Bool = false

#endif

