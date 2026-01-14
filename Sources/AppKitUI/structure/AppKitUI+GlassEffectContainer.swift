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

/// A GlassEffect view is an `NSGlassEffectContainerView` that degrades back to 10.13 by
/// dropping glass effects for macOS < 26.0
///
/// Usage example :-
///
/// ```swift
/// GlassEffectContainer(spacing: 32) {
///    HStack {
///       NSButton.image(.systemSymbol("chevron.left"))
///          .onAction { _ in Swift.print("Pressed left") }
///          .glassEffect()
///       NSButton.image(.systemSymbol("circle"))
///          .onAction { _ in Swift.print("Pressed circle") }
///          .glassEffect()
///       NSButton.image(.systemSymbol("chevron.right"))
///          .onAction { _ in Swift.print("Pressed right") }
///          .glassEffect()
///    }
/// }
/// ```

import AppKit

@MainActor
public protocol GlassEffectContainerViewPresenting: NSView {
	/// The proximity at which the glass effect container view begins merging eligible descendent glass effect views.
	@discardableResult func spacing(_ value: CGFloat?) -> Self
}

/// Create a glass effect container view
/// - Parameters:
///   - spacing: The proximity at which the glass effect container view begins merging eligible descendent glass effect views.
///   - viewBuilder: The content builder
/// - Returns: A glass effect container
@MainActor
public func GlassEffectContainer(
	spacing: CGFloat? = nil,
	_ viewBuilder: () -> NSView
) -> GlassEffectContainerViewPresenting {
	makeGlassEffectContainerView(viewBuilder)
		.translatesAutoresizingMaskIntoConstraints(false)
		.spacing(spacing)
}

// MARK: - Private

#if canImport(AppKit.NSGlassEffectView)
@available(macOS 26.0, *)
extension NSGlassEffectContainerView: GlassEffectContainerViewPresenting {
	public func spacing(_ value: CGFloat?) -> Self {
		if let value {
			self.spacing = value
		}
		return self
	}
}
#endif

@MainActor
private func makeGlassEffectContainerView(_ viewBuilder: () -> NSView) -> GlassEffectContainerViewPresenting {
	#if canImport(AppKit.NSGlassEffectView)
	if #available(macOS 26.0, *) {
		return NSGlassEffectContainerView(viewBuilder)
	} else {
		return GlassEffectContainerViewFallback(viewBuilder)
	}
	#else
	return GlassEffectContainerViewFallback(viewBuilder)
	#endif
}

@MainActor
internal class GlassEffectContainerViewFallback: NSView, GlassEffectContainerViewPresenting {

	convenience init(_ viewBuilder: () -> NSView) {
		self.init()
		self.translatesAutoresizingMaskIntoConstraints = false
		let content = viewBuilder().translatesAutoresizingMaskIntoConstraints(false)
		content.pin(inside: self)
	}

	@discardableResult public func spacing(_ value: CGFloat?) -> Self { self }
	@discardableResult public func spacing(_ value: CGFloat) -> Self { self }
}

// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("basic") {
	GlassEffectContainer {
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
	}
	.padding()
	.debugFrames()
}

@available(macOS 14, *)
#Preview("spacing:30") {
	GlassEffectContainer(spacing: 30) {
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
	}
	.padding()
	.debugFrames(.systemBlue.alpha(0.4))
}

@available(macOS 14.0, *)
#Preview("image buttons") {
	GlassEffectContainer(spacing: 32) {
		HStack {
			NSButton.image(.systemSymbol("chevron.left"))
				.frame(dimension: 32)
				.onAction { _ in Swift.print("Pressed left") }
				.glassEffect()
			NSButton.image(.systemSymbol("circle"))
				.frame(dimension: 32)
				.onAction { _ in Swift.print("Pressed circle") }
				.glassEffect()
			NSButton.image(.systemSymbol("chevron.right"))
				.frame(dimension: 32)
				.onAction { _ in Swift.print("Pressed right") }
				.glassEffect()
		}
	}
	.padding(12)
	.debugFrames()
}

@available(macOS 14.0, *)
#Preview("capsule buttons") {
	GlassEffect {
		HStack {
			NSButton.image(.systemSymbol("chevron.left"))
				.frame(dimension: 32)
				.onAction { _ in Swift.print("Pressed left") }
			NSButton.image(.systemSymbol("circle"))
				.frame(dimension: 32)
				.onAction { _ in Swift.print("Pressed circle") }
			NSButton.image(.systemSymbol("chevron.right"))
				.frame(dimension: 32)
				.onAction { _ in Swift.print("Pressed right") }
		}
	}
	.padding(12)
	.debugFrames()
}

#endif
