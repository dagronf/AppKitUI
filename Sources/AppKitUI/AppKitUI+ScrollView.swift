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

final class FlippedClipView: NSClipView {
	override var isFlipped: Bool {
		return true
	}
}

/// Wrapper for NSScrollView
///
/// Usage:
///
/// ```swift
/// ScrollView(fitHorizontally: true) {
///    VStack(spacing: 16, alignment: .leading) {
///       Label("This is the first line")
///       Label("This is the second line")
///    }
///}
/// ```
@MainActor
public class ScrollView: NSScrollView {

	public init(
		borderType: NSBorderType = .lineBorder,
		fitHorizontally: Bool = true,
		autohidesScrollers: Bool = true,
		content builder: () -> NSView
	) {
		super.init(frame: .zero)
		self.wantsLayer = true
		self.translatesAutoresizingMaskIntoConstraints = false
		self.configure(
			borderType: borderType,
			fitHorizontally: fitHorizontally,
			autohidesScrollers: autohidesScrollers,
			content: builder
		)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configure(
		borderType: NSBorderType,
		fitHorizontally: Bool,
		autohidesScrollers: Bool,
		content builder: () -> NSView
	) {
		self.translatesAutoresizingMaskIntoConstraints = false
		self.borderType = .noBorder
		self.backgroundColor = .clear
		self.drawsBackground = false

		self.autohidesScrollers = autohidesScrollers
		self.hasVerticalScroller = true
		self.borderType = borderType

		self.drawsBackground(false)
		self.backgroundColor(.clear)

		if !fitHorizontally {
			self.hasHorizontalScroller = true
		}

		let clipView = FlippedClipView()
		clipView.drawsBackground = false
		clipView.translatesAutoresizingMaskIntoConstraints = false
		self.contentView = clipView

		// This has to be called AFTER the assignment -- it seems like macOS is resetting it back to true
		self.contentView.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			clipView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			clipView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			clipView.topAnchor.constraint(equalTo: self.topAnchor),
			clipView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
		])

		let contentView = builder()
		contentView.translatesAutoresizingMaskIntoConstraints = false
		self.documentView = contentView

		NSLayoutConstraint.activate([
			contentView.leadingAnchor.constraint(equalTo: clipView.leadingAnchor),
			contentView.topAnchor.constraint(equalTo: clipView.topAnchor),
			// NOTE: No need for bottomAnchor
		])

		if fitHorizontally {
			NSLayoutConstraint.activate([
				contentView.trailingAnchor.constraint(equalTo: clipView.trailingAnchor),
			])
		}
	}
}

// MARK: - Modifiers

@MainActor
public extension ScrollView {
	/// A Boolean that indicates whether the scroll view automatically hides its scroll bars when they are not needed.
	@discardableResult @inlinable
	func autohidesScrollers(_ autohidesScrollers: Bool) -> Self {
		self.autohidesScrollers = autohidesScrollers
		return self
	}

	/// The color of the content view’s background.
	@discardableResult @inlinable
	func backgroundColor(_ color: NSColor) -> Self {
		self.backgroundColor = color
		return self
	}

	/// A value that specifies the appearance of the scroll view’s border.
	@discardableResult @inlinable
	func borderType(_ type: NSBorderType) -> Self {
		self.borderType = type
		return self
	}

	/// Set whether the scrollview draws its background
	@discardableResult @inlinable
	func drawsBackground(_ value: Bool) -> Self {
		self.drawsBackground = value
		return self
	}

	/// The distance that the scroll view’s subviews are inset from the enclosing scroll view during tiling.
	@discardableResult @inlinable
	func contentInsets(_ inset: Double) -> Self {
		self.contentInsets(NSEdgeInsets(top: inset, left: inset, bottom: inset, right: inset))
	}

	/// The distance that the scroll view’s subviews are inset from the enclosing scroll view during tiling.
	@discardableResult @inlinable
	func contentInsets(_ contentInsets: NSEdgeInsets) -> Self {
		self.contentInsets = contentInsets
		return self
	}
}

// MARK: - Private
