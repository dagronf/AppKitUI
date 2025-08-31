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

/// Create a z-stack
/// - Parameters:
///   - padding: The minimum padding around the child views
///   - builder: view builder
/// - Returns: A new view
///
/// First item in the list is the _highest_ item in the zstack
@MainActor
public func ZStack(
	padding: Double = 20,
	@NSViewsBuilder builder: () -> [NSView]
) -> NSView {
	let view = NSView()
	view.translatesAutoresizingMaskIntoConstraints = false

	// Build the child views
	let children = builder()

	var v: NSView?

	children.enumerated().forEach { item in

		let child = item.element

		if child !== NSView.empty {
			child.translatesAutoresizingMaskIntoConstraints = false
			view.addSubview(child, positioned: .above, relativeTo: v)

			view.addConstraint(NSLayoutConstraint(item: child, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
			view.addConstraint(NSLayoutConstraint(item: child, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0))

			view.addConstraint(NSLayoutConstraint(item: child, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: view, attribute: .leading, multiplier: 1, constant: padding))
			view.addConstraint(NSLayoutConstraint(item: child, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: view, attribute: .top, multiplier: 1, constant: padding))
			view.addConstraint(NSLayoutConstraint(item: child, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: view, attribute: .trailing, multiplier: 1, constant: padding))
			view.addConstraint(NSLayoutConstraint(item: child, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: view, attribute: .bottom, multiplier: 1, constant: padding))

			v = child
		}
	}

	return view
}

// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("Basic") {
	ZStack {
		NSView()
			.backgroundFill(.systemRed)
			.frame(width: 100, height: 50)
		NSView()
			.backgroundFill(.systemBlue)
			.frame(width: 50, height: 100)
	}
	.backgroundBorder(.systemGreen, lineWidth: 1)
}

@available(macOS 14, *)
#Preview("ZStack") {
	ZStack {
		HStack {
			NSView()
				.backgroundFill(.systemRed)
				.frame(width: 50, height: 50)
			NSView()
				.backgroundFill(.systemGreen)
				.frame(width: 50, height: 50)
			NSView()
				.backgroundFill(.systemBlue)
				.frame(width: 50, height: 50)
		}
		NSView()
			.backgroundFill(.systemBrown)
			.frame(width: 30, height: 30)
		NSButton()
			.title("Fish and chips")
			.huggingPriority(.defaultLow, for: .horizontal)
	}
}

#endif
