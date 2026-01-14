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

#if canImport(AppKit.NSGlassEffectView)

import AppKit

@available(macOS 26.0, *)
@MainActor
public extension NSGlassEffectContainerView {
	/// Create a glass effect container view that efficiently merges descendant glass effect views together
	/// when they are within a specified proximity to each other.
	/// - Parameters:
	///   - viewBuilder: The content for the glass effect view
	///
	/// Note that the glass effect container view has NO visual appearance of its own, it works on the glass effect
	/// views contained within it. It's the glass scene root
	convenience init(spacing: CGFloat = 0, _ viewBuilder: () -> NSView) {
		self.init()
		self.translatesAutoresizingMaskIntoConstraints = false
		let content = viewBuilder()
		content.translatesAutoresizingMaskIntoConstraints = false
		self.contentView = content
		self.spacing = spacing
	}
}

// MARK: - Modifiers

@available(macOS 26.0, *)
@MainActor
public extension NSGlassEffectContainerView {
	/// The proximity at which the glass effect container view begins merging eligible descendent glass effect views.
	/// - Parameter value: The curvature
	/// - Returns: self
	@discardableResult @inlinable
	func spacing(_ value: CGFloat) -> Self {
		self.spacing = value
		return self
	}
}

// MARK: - Previews

#if DEBUG

@available(macOS 26.0, *)
#Preview("default") {
	NSGlassEffectContainerView(spacing: 32) {
		HStack {
			NSButton.image(.systemSymbol("chevron.left"))
				.onAction { _ in Swift.print("Pressed left") }
				.glassEffect()
			NSButton.image(.systemSymbol("circle"))
				.onAction { _ in Swift.print("Pressed circle") }
				.glassEffect()
			NSButton.image(.systemSymbol("chevron.right"))
				.onAction { _ in Swift.print("Pressed right") }
				.glassEffect()
		}
	}
}

#endif

#endif
