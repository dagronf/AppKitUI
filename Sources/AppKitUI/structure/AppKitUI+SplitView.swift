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

@MainActor
public func VSplitView(
	dividerStyle: NSSplitView.DividerStyle = .paneSplitter,
	@NSViewsBuilder builder: () -> [NSView]
) -> NSSplitView {
	SplitView(orientation: .vertical, dividerStyle: dividerStyle, builder: builder)
}

@MainActor
public func HSplitView(
	dividerStyle: NSSplitView.DividerStyle = .paneSplitter,
	@NSViewsBuilder builder: () -> [NSView]
) -> NSSplitView {
	SplitView(orientation: .horizontal, dividerStyle: dividerStyle, builder: builder)
}

@MainActor
private func SplitView(
	orientation: NSUserInterfaceLayoutOrientation,
	dividerStyle: NSSplitView.DividerStyle,
	@NSViewsBuilder builder: () -> [NSView]
) -> NSSplitView {
	let s = NSSplitView()
	s.translatesAutoresizingMaskIntoConstraints = false

	s.dividerStyle = dividerStyle
	s.isVertical = (orientation == .vertical)

	let views = builder()
	views.forEach {
		$0.translatesAutoresizingMaskIntoConstraints = false
		s.addArrangedSubview($0)
	}
	return s
}

@MainActor
public extension NSSplitView {
	@discardableResult @inlinable
	func dividerStyle(_ style: NSSplitView.DividerStyle) -> Self {
		self.dividerStyle = style
		return self
	}

	@discardableResult @inlinable
	func holdingPriority(_ priority: NSLayoutConstraint.Priority, forItemAtIndex index: Int) -> Self {
		self.setHoldingPriority(priority, forSubviewAt: index)
		return self
	}
}
