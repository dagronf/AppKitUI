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
import os.log

/// A view that allows arbitrary layout of children using constraints
@MainActor
public class LayoutContainer: NSView {
	/// Create a layout container, specifying the child views
	public convenience init(@NSViewsBuilder viewsBuilder: () -> [NSView]) {
		self.init()
		self.setup(viewsBuilder())
	}

	deinit {
		os_log("deinit: LayoutContainer", log: logger, type: .debug)
	}

	private var childViews: [NSView] = []
}

@MainActor
private extension LayoutContainer {
	func setup(_ views: [NSView]) {
		self.translatesAutoresizingMaskIntoConstraints = false
		self.childViews = views
		views.forEach { view in
			view.translatesAutoresizingMaskIntoConstraints = false
			self.addSubview(view)
		}
	}
}

@MainActor
public extension LayoutContainer {
	/// Create a constraint from a subview to another subview within the LayoutContainer
	/// - Parameters:
	///   - fromIndex: The index of the child view for the left side of the constraint
	///   - attr1: The attribute of the view for the left side of the constraint
	///   - rel: The relationship between the left side of the constraint and the right side of the constraint
	///   - toIndex: The index of the child view for the right side of the constraint
	///   - attr2: The attribute of the container view for the right side of the constraint
	///   - multiplier: The constant multiplied with the attribute on the right side of the constraint as part of getting the modified attribute
	///   - constant: The constant added to the multiplied attribute value on the right side of the constraint to yield the final modified attribute
	///   - priority: The priority of the created constraint
	/// - Returns: self
	@discardableResult
	func constraint(
		fromIndex: Int,
		attribute attr1: NSLayoutConstraint.Attribute,
		relatedBy rel: NSLayoutConstraint.Relation,
		toIndex: Int,
		attribute attr2: NSLayoutConstraint.Attribute,
		multiplier: Double = 1,
		constant: Double = 0,
		priority: NSLayoutConstraint.Priority? = nil
	) -> Self {

		guard let i1 = self.childViews.at(fromIndex) else {
			os_log("Container: Cannot find subview at index=%d", log: logger, type: .error, fromIndex)
			return self
		}

		guard let i2 = self.childViews.at(toIndex) else {
			os_log("Container: Cannot find subview at index=%d", log: logger, type: .error, toIndex)
			return self
		}

		let c = NSLayoutConstraint(
			item: i1, attribute: attr1,
			relatedBy: rel,
			toItem: i2, attribute: attr2,
			multiplier: multiplier,
			constant: constant
		)

		if let priority {
			c.priority = priority
		}

		self.addConstraint(c)

		return self
	}

	/// Create a constraint from a subview to the LayoutContainer
	/// - Parameters:
	///   - fromIndex: The index of the child view for the left side of the constraint
	///   - attr1: The attribute of the view for the left side of the constraint.
	///   - rel: The relationship between the left side of the constraint and the right side of the constraint.
	///   - attr2: The attribute of the container view for the right side of the constraint.
	///   - multiplier: The constant multiplied with the attribute on the right side of the constraint as part of getting the modified attribute.
	///   - constant: The constant added to the multiplied attribute value on the right side of the constraint to yield the final modified attribute.
	/// - Returns: self
	@discardableResult
	func constraint(
		fromIndex: Int,
		attribute attr1: NSLayoutConstraint.Attribute,
		relatedBy rel: NSLayoutConstraint.Relation,
		attribute attr2: NSLayoutConstraint.Attribute,
		multiplier: Double = 1,
		constant: Double = 0
	) -> Self {

		guard let i1 = self.childViews.at(fromIndex) else {
			os_log("Container: Cannot find subview at index=%d", log: logger, type: .error, fromIndex)
			return self
		}

		let c = NSLayoutConstraint(
			item: i1, attribute: attr1,
			relatedBy: rel,
			toItem: self, attribute: attr1,
			multiplier: multiplier,
			constant: constant
		)

		self.addConstraint(c)

		return self
	}

	/// Pin the indexed view inside this view
	/// - Parameter index: The index of the view within the container
	/// - Returns: self
	@discardableResult
	func constraintPinInside(index: Int) -> Self {
		guard let i1 = self.childViews.at(index) else {
			os_log("Container: Cannot find subview at index=%d", log: logger, type: .error, index)
			return self
		}
		i1.pin(inside: self)
		return self
	}
}


// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("basic") {
	LayoutContainer {
		NSButton(title: "Reset all results")
		NSTextField(label: "Do the funky chicken")
		AUIColorSelector()
		NSTextField(link: URL(fileURLWithPath: "hhtps://developer.apple.com/"), title: "Apple Developer")
	}
	.constraint(fromIndex: 0, attribute: .top, relatedBy: .equal, attribute: .top, constant: 20)
	.constraint(fromIndex: 0, attribute: .leading, relatedBy: .equal, attribute: .leading, constant: 20)

	.constraint(fromIndex: 1, attribute: .leading, relatedBy: .greaterThanOrEqual, toIndex: 0, attribute: .trailing, constant: 20)
	.constraint(fromIndex: 1, attribute: .top, relatedBy: .equal, toIndex: 0, attribute: .bottom, constant: 10, priority: .defaultHigh)
	.constraint(fromIndex: 1, attribute: .trailing, relatedBy: .equal, attribute: .trailing, constant: -40)

	.constraint(fromIndex: 2, attribute: .centerX, relatedBy: .equal, attribute: .centerX)
	.constraint(fromIndex: 2, attribute: .top, relatedBy: .equal, toIndex: 1, attribute: .bottom, constant: 20)
	.constraint(fromIndex: 2, attribute: .bottom, relatedBy: .equal, attribute: .bottom, constant: -20)

	.constraint(fromIndex: 3, attribute: .trailing, relatedBy: .equal, attribute: .trailing, constant: -4)
	.constraint(fromIndex: 3, attribute: .bottom, relatedBy: .equal, attribute: .bottom, constant: -4)

	.padding(30)
	.debugFrames()
}

#endif
