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

import AppKit.NSView

// MARK: - Hugging and compression

@MainActor
public extension NSView {
	/// Sets the priority with which a view resists being made larger than its intrinsic size.
	@discardableResult @inlinable
	func huggingPriority(_ p: NSLayoutConstraint.Priority, for orientation: NSLayoutConstraint.Orientation) -> Self {
		self.setContentHuggingPriority(p, for: orientation)
		return self
	}

	/// Sets the priority with which a view resists being made larger than its intrinsic size.
	@discardableResult @inlinable
	func huggingPriority(_ p: Float, for orientation: NSLayoutConstraint.Orientation) -> Self {
		self.huggingPriority(NSLayoutConstraint.Priority(rawValue: p), for: orientation)
	}

	/// Sets the priority with which a view resists being made smaller than its intrinsic size.
	@discardableResult @inlinable
	func compressionResistancePriority(_ p: NSLayoutConstraint.Priority, for orientation: NSLayoutConstraint.Orientation) -> Self {
		self.setContentCompressionResistancePriority(p, for: orientation)
		return self
	}

	/// Sets the priority with which a view resists being made smaller than its intrinsic size.
	@discardableResult @inlinable
	func compressionResistancePriority(_ p: Float, for orientation: NSLayoutConstraint.Orientation) -> Self {
		self.compressionResistancePriority(NSLayoutConstraint.Priority(rawValue: p), for: orientation)
	}
}

// MARK: Setting a size

@MainActor
public extension NSView {

	/// Adds this view as a child of another view, and attached the edges of this view to the new parent's edges
	/// - Parameters:
	///   - view: The view to pin this view inside
	///   - padding: The padding between this view and the parent view
	/// - Returns: self
	@discardableResult
	func pin(inside view: NSView, padding: Double = 0) -> Self {
		self.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(self)
		view.addConstraint(NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: padding))
		view.addConstraint(NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -padding))
		view.addConstraint(NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: padding))
		view.addConstraint(NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -padding))
		return self
	}

	/// Set the width for the view
	/// - Parameters:
	///   - width: The width
	///   - priority: The constraint priority
	/// - Returns: self
	@discardableResult
	func width(_ width: Double?, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		guard let width = width else { return self }
		self.translatesAutoresizingMaskIntoConstraints = false
		let c = self.widthAnchor.constraint(equalToConstant: width)
		if let priority { c.priority = priority }
		c.isActive = true
		return self
	}

	/// Set the minimum width for a view
	/// - Parameters:
	///   - minWidth: The minimum width value
	///   - priority: The constraint priority
	/// - Returns: self
	@discardableResult
	func minWidth(_ minWidth: Double, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		self.translatesAutoresizingMaskIntoConstraints = false
		let c = NSLayoutConstraint(
			item: self, attribute: .width,
			relatedBy: .greaterThanOrEqual,
			toItem: nil, attribute: .notAnAttribute,
			multiplier: 1.0, constant: minWidth
		)
		if let priority { c.priority = priority }
		c.isActive = true
		return self
	}

	/// Set the maximum width for a view
	/// - Parameters:
	///   - maxWidth: The maximum width value
	///   - priority: The constraint priority
	/// - Returns: self
	@discardableResult
	func maxWidth(_ maxWidth: Double, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		self.translatesAutoresizingMaskIntoConstraints = false
		let c = NSLayoutConstraint(
			item: self, attribute: .width,
			relatedBy: .lessThanOrEqual,
			toItem: nil, attribute: .notAnAttribute,
			multiplier: 1.0, constant: maxWidth
		)
		if let priority { c.priority = priority }
		c.isActive = true
		return self
	}

	/// Set the height for the view
	/// - Parameters:
	///   - height: The view's height
	///   - priority: The constraint priority
	/// - Returns: self
	@discardableResult
	func height(_ height: Double?, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		guard let height = height else { return self }
		self.translatesAutoresizingMaskIntoConstraints = false
		let c = self.heightAnchor.constraint(equalToConstant: height)
		if let priority { c.priority = priority }
		c.isActive = true
		return self
	}

	/// Set the minimum height for a view
	/// - Parameters:
	///   - minHeight: The minimum height value
	///   - priority: The constraint priority
	/// - Returns: self
	@discardableResult
	func minHeight(_ minHeight: Double, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		self.translatesAutoresizingMaskIntoConstraints = false
		let c = NSLayoutConstraint(
			item: self, attribute: .height,
			relatedBy: .greaterThanOrEqual,
			toItem: nil, attribute: .notAnAttribute,
			multiplier: 1.0, constant: minHeight
		)
		if let priority { c.priority = priority }
		c.isActive = true
		return self
	}

	/// Set the maximum height for a view
	/// - Parameters:
	///   - maxHeight: The maximum height value
	///   - priority: The constraint priority
	/// - Returns: self
	@discardableResult
	func maxHeight(_ maxHeight: Double, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		self.translatesAutoresizingMaskIntoConstraints = false
		let c = NSLayoutConstraint(
			item: self, attribute: .height,
			relatedBy: .lessThanOrEqual,
			toItem: nil, attribute: .notAnAttribute,
			multiplier: 1.0, constant: maxHeight
		)
		if let priority { c.priority = priority }
		c.isActive = true
		return self
	}

	/// Set the view's frame size
	/// - Parameters:
	///   - width: The width
	///   - height: The height
	///   - priority: The constraint priority
	/// - Returns: self
	@discardableResult
	func frame(width: Double? = nil, height: Double? = nil, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		self.translatesAutoresizingMaskIntoConstraints = false
		if let width { self.width(width, priority: priority) }
		if let height { self.height(height, priority: priority) }
		return self
	}

	/// Set the views dimension (same width and height) for the view
	/// - Parameters:
	///   - dimension: The dimension
	///   - priority: The priority for the created constraints
	/// - Returns: self
	@discardableResult
	func frame(dimension: Double, priority: NSLayoutConstraint.Priority? = nil) -> Self {
		self
			.width(dimension, priority: priority)
			.height(dimension, priority: priority)
	}
}

// MARK: - Constraints between two views

@MainActor
public extension NSView {
	/// Add a constraint to make two views equal widths
	/// - Parameters:
	///   - ids: The identifiers for the views to make equal
	///   - priority: The constraint priority
	///   - constant: The constraint constant value
	/// - Returns: self
	@discardableResult @inlinable
	func equalWidths(
		_ ids: [AUIIdentifier],
		priority: NSLayoutConstraint.Priority? = nil,
		constant: Double = 0
	) -> Self {
		self.equalConstraint(.width, ids, priority: priority, constant: constant)
	}

	/// Add a constraint to make two views equal heights
	/// - Parameters:
	///   - ids: The identifiers for the views to make equal
	///   - priority: The constraint priority
	///   - constant: The constraint constant value
	/// - Returns: self
	@discardableResult @inlinable
	func equalHeights(
		_ ids: [AUIIdentifier],
		priority: NSLayoutConstraint.Priority? = nil,
		constant: Double = 0
	) -> Self {
		self.equalConstraint(.height, ids, priority: priority, constant: constant)
	}

	/// Add a constraint to make two views equal widths and heights
	/// - Parameters:
	///   - ids: The identifiers for the views to make equal
	///   - priority: The constraint priority
	///   - constant: The constraint constant value
	/// - Returns: self
	@discardableResult @inlinable
	func equalSizes(
		_ ids: [AUIIdentifier],
		priority: NSLayoutConstraint.Priority? = nil,
		constant: Double = 0
	) -> Self {
		self
			.equalConstraint(.width, ids, priority: priority, constant: constant)
			.equalConstraint(.height, ids, priority: priority, constant: constant)
	}

	/// Add a constraint to make two views have the same leading position
	/// - Parameters:
	///   - ids: The identifiers for the views to make equal
	///   - priority: The constraint priority
	///   - constant: The constraint constant value
	/// - Returns: self
	@discardableResult @inlinable
	func equalLeading(
		_ ids: [AUIIdentifier],
		priority: NSLayoutConstraint.Priority? = nil,
		constant: Double = 0
	) -> Self {
		self.equalConstraint(.leading, ids, priority: priority, constant: constant)
	}

	/// Add a constraint to make two views have the same trailing position
	/// - Parameters:
	///   - ids: The identifiers for the views to make equal
	///   - priority: The constraint priority
	///   - constant: The constraint constant value
	/// - Returns: self
	@discardableResult @inlinable
	func equalTrailing(
		_ ids: [AUIIdentifier],
		priority: NSLayoutConstraint.Priority? = nil,
		constant: Double = 0
	) -> Self {
		self.equalConstraint(.trailing, ids, priority: priority, constant: constant)
	}

	/// Add a constraint to make two views have the same trailing position
	/// - Parameters:
	///   - ids: The identifiers for the views to make equal
	///   - priority: The constraint priority
	///   - constant: The constraint constant value
	/// - Returns: self
	@discardableResult @inlinable
	func equalBottom(
		_ ids: [AUIIdentifier],
		priority: NSLayoutConstraint.Priority? = nil,
		constant: Double = 0
	) -> Self {
		self.equalConstraint(.bottom, ids, priority: priority, constant: constant)
	}

	/// Add constraints to views so that the attribute for each view is equal
	/// - Parameters:
	///   - attribute: The layout attribute
	///   - ids: The identifiers for the views to make equal
	///   - priority: The constraint priority
	///   - constant: The constraint constant value
	/// - Returns: self
	@discardableResult
	func equalConstraint(
		_ attribute: NSLayoutConstraint.Attribute,
		_ ids: [AUIIdentifier],
		priority: NSLayoutConstraint.Priority? = nil,
		constant: Double = 0
	) -> Self {
		guard ids.count > 1 else { return self }
		do {
			let views: [NSView] = try ids.map {
				guard let foundView = self.firstSubview(withIdentifier: $0.identifier) else {
					Swift.print("Unable to find child view with tag '\($0.identifier.rawValue)'")
					throw CocoaError(.coderInvalidValue)
				}
				return foundView
			}

			guard let first = views.first else { return self }
			views.dropFirst().forEach { view in
				view.translatesAutoresizingMaskIntoConstraints = false
				let c = NSLayoutConstraint(
					item: first, attribute: attribute,
					relatedBy: .equal,
					toItem: view, attribute: attribute,
					multiplier: 1, constant: constant
				)
				if let priority { c.priority = priority }
				self.addConstraint(c)
			}
		}
		catch {
			// Do nothing -- just fall out
		}
		return self
	}

	/// Apply a constraint between two subviews
	/// - Parameters:
	///   - from: The identifier for the 'from' view
	///   - attr1: The layout attribute
	///   - relatedBy: The relationship between the left side of the constraint and the right side of the constraint.
	///   - to: The identifier for the 'to' view
	///   - attr2: The attribute of the view for the right side of the constraint.
	///   - multipler: The constant multiplied with the attribute on the right side of the constraint as part of getting the modified attribute.
	///   - constant: The constant added to the multiplied attribute value on the right side of the constraint to yield the final modified attribute.
	///   - priority: The priority of the constraint.
	/// - Returns: self
	@discardableResult
	func constraint(
		from: AUIIdentifier,
		attribute attr1: NSLayoutConstraint.Attribute,
		relatedBy: NSLayoutConstraint.Relation,
		to: AUIIdentifier,
		attribute attr2: NSLayoutConstraint.Attribute,
		multipler: Double = 1,
		constant: Double = 0,
		priority: NSLayoutConstraint.Priority? = nil
	) -> Self {
		guard
			let fromView = self.firstSubview(withIdentifier: from.identifier),
			let toView = self.firstSubview(withIdentifier: to.identifier)
		else {
			Swift.print("Unable to find child view(s) with tag '\(from.identifier.rawValue)':'\(to.identifier.rawValue)'")
			return self
		}

		let c = NSLayoutConstraint(
			item: fromView, attribute: attr1,
			relatedBy: relatedBy,
			toItem: toView, attribute: attr2,
			multiplier: multipler,
			constant: constant
		)
		if let priority {
			c.priority = priority
		}
		self.addConstraint(c)

		return self
	}
}


@MainActor
extension NSView {
	/// Returns the first subview that matches the given identifier
	/// - Parameter identifier: The NSUserInterfaceItemIdentifier to search for
	/// - Returns: The matching NSView, or nil if no match is found
	func firstSubview(withIdentifier identifier: NSUserInterfaceItemIdentifier) -> NSView? {
		// Check if this view matches the identifier
		if self.identifier == identifier {
			return self
		}

		// Recursively search through all subviews
		for subview in subviews {
			if let matchingView = subview.firstSubview(withIdentifier: identifier) {
				return matchingView
			}
		}

		return nil
	}

	/// Returns the first subview that matches the given identifier
	/// - Parameter identifier: The NSUserInterfaceItemIdentifier to search for
	/// - Returns: The matching NSView, or nil if no match is found
	@objc func allSubviews() -> [NSView] {
		// Check if this view matches the identifier
		var items = [self]

		// Recursively search through all subviews
		for subview in subviews {
			items.append(contentsOf: subview.allSubviews())
		}

		return items
	}
}


// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("HStack equal widths") {
	VStack {
		HStack {
			NSButton()
				.identifier("button1")
				.title("Fish and chips")
			NSButton()
				.identifier("button2")
				.title("cats")
		}
		.equalWidths(["button1", "button2"])

		HStack {
			NSButton()
				.identifier("button1")
				.bezelStyle(.flexiblePush)
				.title("Fish and chips")
			NSButton()
				.identifier("button2")
				.bezelStyle(.flexiblePush)
				.title("cats")
				.height(80)
		}
		.equalWidths(["button1", "button2"])
		.equalHeights(["button1", "button2"], priority: .defaultLow)

		HStack {
			NSButton()
				.identifier("button1")
				.bezelStyle(.flexiblePush)
				.title("Fish and chips")
			NSButton()
				.identifier("button2")
				.bezelStyle(.flexiblePush)
				.title("cats")
				.height(80)
		}
		.equalHeights(["button1", "button2"], priority: .defaultLow)
	}
	.debugFrames()
}

#endif
