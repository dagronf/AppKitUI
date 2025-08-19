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

// MARK: - Creators

/// Create a vertical stack
/// - Parameters:
///   - alignment: The view alignment within the stack view
///   - spacing: The spacing
///   - gravity: The gravity to apply to ALL elements in the stack.
///   - builder: The stack builder
/// - Returns: A new stack object
///
/// The gravity, if supplied, applies to all items in a stack. This is useful for example when you want to
/// add a bunch of buttons to the trailing of a stack instead of in the center.
@MainActor
public func VStack(
	alignment: NSLayoutConstraint.Attribute? = nil,
	spacing: Double? = nil,
	gravity: NSStackView.Gravity? = nil,
	@NSViewsBuilder builder: () -> [NSView]
) -> NSStackView {
	NSStackView(orientation: .vertical, alignment: alignment, spacing: spacing, gravity: gravity, builder: builder)
}

/// Create a horizontal stack
/// - Parameters:
///   - alignment: The view alignment within the stack view
///   - spacing: The spacing
///   - gravity: The gravity to apply to ALL elements in the stack
///   - builder: The stack builder
/// - Returns: A new stack object
///
/// The gravity, if supplied, applies to all items in a stack. This is useful for example when you want to
/// add a bunch of buttons to the trailing of a stack instead of in the center.
@MainActor
public func HStack(
	alignment: NSLayoutConstraint.Attribute? = nil,
	spacing: Double? = nil,
	gravity: NSStackView.Gravity? = nil,
	@NSViewsBuilder builder: () -> [NSView]
) -> NSStackView {
	NSStackView(orientation: .horizontal, alignment: alignment, spacing: spacing, gravity: gravity, builder: builder)
}
