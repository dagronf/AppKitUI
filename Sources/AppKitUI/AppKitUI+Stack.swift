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
///   - builder: The stack builder
/// - Returns: A new stack object
@MainActor
public func VStack(
	alignment: NSLayoutConstraint.Attribute? = nil,
	spacing: Double? = nil,
	@NSViewsBuilder builder: () -> [NSView]
) -> NSStackView {
	NSStackView(orientation: .vertical, alignment: alignment, spacing: spacing, builder: builder)
}

/// Create a horizontal stack
/// - Parameters:
///   - alignment: The view alignment within the stack view
///   - spacing: The spacing
///   - builder: The stack builder
/// - Returns: A new stack object
@MainActor
public func HStack(
	alignment: NSLayoutConstraint.Attribute? = nil,
	spacing: Double? = nil,
	@NSViewsBuilder builder: () -> [NSView]
) -> NSStackView {
	NSStackView(orientation: .horizontal, alignment: alignment, spacing: spacing, builder: builder)
}
