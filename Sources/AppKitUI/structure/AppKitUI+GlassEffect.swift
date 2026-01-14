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

/// A GlassEffect view is an `NSGlassEffectView` that degrades back to 10.13 by
/// dropping glass effects for macOS < 26.0
///
/// Usage example :-
///
/// ```swift
/// GlassEffect {
///    VStack {
///       NSTextField(label: "Message 1")
///       NSTextField(label: "Message 2")
///    }
///    .padding(8)
/// }
/// ```

/// Glass view styles
public enum AUIGlassEffectStyle {
	/// Clear glass effect style.
	case clear
	/// Standard glass effect style.
	case regular
}

@MainActor
public protocol AUIGlassEffectViewPresenting: NSView {
	/// The amount of curvature for all corners of the glass.
	@discardableResult func cornerRadius(_ value: CGFloat) -> Self
	/// The style of glass this view uses.
	@discardableResult func style(_ style: AUIGlassEffectStyle) -> Self
	/// The color the glass effect view uses to tint the background and glass effect toward
	@discardableResult func tintColor(_ color: NSColor?) -> Self
}

/// Create a glass effect view
/// - Parameters:
///   - style: The glass style
///   - cornerRadius: The amount of curvature for all corners of the glass
///   - tintColor: The color the glass effect view uses to tint the background and glass effect toward
///   - viewBuilder: The glass view's content builder
/// - Returns: A new glass effect view
@MainActor
public func GlassEffect(
	style: AUIGlassEffectStyle = .regular,
	cornerRadius: CGFloat? = nil,
	tintColor: NSColor? = nil,
	_ viewBuilder: () -> NSView
) -> AUIGlassEffectViewPresenting {
	let view = makeGlassEffectView(viewBuilder)
		.translatesAutoresizingMaskIntoConstraints(false)
		.style(style)
		.tintColor(tintColor)

	if let cornerRadius {
		view.cornerRadius(cornerRadius)
	}

	return view
}

@MainActor
public extension NSView {
	/// Wrap this view in a glass effect view
	/// - Parameters:
	///   - style: The glass style
	///   - cornerRadius: The amount of curvature for all corners of the glass
	///   - tintColor: The color the glass effect view uses to tint the background and glass effect toward
	/// - Returns: A new glass effect view
	func glassEffect(
		style: AUIGlassEffectStyle = .regular,
		cornerRadius: CGFloat? = nil,
		tintColor: NSColor? = nil,
	) -> AUIGlassEffectViewPresenting {
		let view = makeGlassEffectView({ self })
			.translatesAutoresizingMaskIntoConstraints(false)
			.style(style)
			.tintColor(tintColor)
		if let cornerRadius {
			view.cornerRadius(cornerRadius)
		}
		return view
	}
}

// MARK: - Private

@MainActor
private func makeGlassEffectView(_ viewBuilder: () -> NSView) -> AUIGlassEffectViewPresenting {
	#if canImport(AppKit.NSGlassEffectView)
	if #available(macOS 26.0, *) {
		return NSGlassEffectView(viewBuilder)
	} else {
		return GlassEffectViewFallback(viewBuilder)
	}
	#else
	return GlassEffectViewFallback(viewBuilder)
	#endif
}

#if canImport(AppKit.NSGlassEffectView)
@available(macOS 26.0, *)
@MainActor
public extension NSGlassEffectView {
	/// The style of glass this view uses.
	/// - Parameter style: The glass style
	/// - Returns: self
	@discardableResult @inlinable
	func style(_ style: AUIGlassEffectStyle) -> Self {
		switch style {
		case .clear: self.style = .clear
		case .regular: self.style = .regular
		}
		return self
	}
}
#endif

@MainActor
class GlassEffectViewFallback: NSView, AUIGlassEffectViewPresenting {

	convenience init(_ viewBuilder: () -> NSView) {
		self.init()
		self.translatesAutoresizingMaskIntoConstraints = false
		let content = viewBuilder().translatesAutoresizingMaskIntoConstraints(false)
		content.pin(inside: self)
	}

	@discardableResult
	public func cornerRadius(_ value: CGFloat) -> Self {
		self.backgroundCornerRadius(value)
		return self
	}

	@discardableResult
	func style(_ style: AUIGlassEffectStyle) -> Self {
		return self
	}
	
	@discardableResult
	func tintColor(_ color: NSColor?) -> Self {
		return self
	}
}

// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("GlassEffect wrapper") {
	HStack {
		GlassEffect {
			NSTextField(label: "Hello!")
				.padding()
		}

		GlassEffect {
			NSTextField(label: "Hello!")
				.padding()
		}
		.cornerRadius(8)

		GlassEffect {
			NSTextField(label: "Hello!")
				.padding()
		}
		.cornerRadius(20)
	}
	.padding(8)
	.debugFrames()
}

@available(macOS 14, *)
#Preview("GlassEffect modifier") {
	HStack {
		NSTextField(label: "First one")
			.padding()
			.glassEffect()

		NSTextField(label: "Second one")
			.padding()
			.glassEffect()
			.cornerRadius(8)

		NSTextField(label: "Third one")
			.padding()
			.glassEffect()
			.cornerRadius(20)
	}
	.padding(8)
	.debugFrames(.systemGreen.alpha(0.4))
}

@available(macOS 14, *)
#Preview("doco") {
	GlassEffect {
		VStack {
			NSTextField(label: "Message 1")
			NSTextField(label: "Message 2")
		}
		.padding(8)
	}
	.debugFrames()
}

#endif
