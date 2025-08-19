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

import AppKit.NSStackView

public extension NSStackView {
	/// Create a stack view and populate it with views
	/// - Parameters:
	///   - orientation: The orientation (horizontal or vertical)
	///   - alignment: The stack alignment
	///   - spacing: The spacing between elements in a stack
	///   - gravity: The gravity to apply to ALL elements in the stack
	///   - views: The child views
	convenience init(
		orientation: NSUserInterfaceLayoutOrientation,
		alignment: NSLayoutConstraint.Attribute? = nil,
		spacing: Double? = nil,
		gravity: NSStackView.Gravity? = nil,
		_ views: [NSView]
	) {
		self.init()
		self.translatesAutoresizingMaskIntoConstraints = false
		self.orientation = orientation

		if let spacing {
			self.spacing = spacing
		}

		if let alignment {
			self.alignment = alignment
		}

		views.forEach { view in
			if view !== NSView.empty {
				view.translatesAutoresizingMaskIntoConstraints = false

				if let gravity = view.gravityArea() {
					self.addView(view, in: gravity)
				}
				else {
					self.addArrangedSubview(view)
				}
			}
		}
	}

	/// Create a stack view and populate it with views
	/// - Parameters:
	///   - orientation: The orientation (horizontal or vertical)
	///   - alignment: The stack alignment
	///   - spacing: The spacing between elements in a stack
	///   - gravity: The gravity to apply to ALL elements in the stack
	///   - views: The builder for the child views
	convenience init(
		orientation: NSUserInterfaceLayoutOrientation,
		alignment: NSLayoutConstraint.Attribute? = nil,
		spacing: Double? = nil,
		gravity: NSStackView.Gravity? = nil,
		@NSViewsBuilder builder: () -> [NSView]
	) {
		self.init(orientation: orientation, alignment: alignment, spacing: spacing, gravity: gravity, builder())
	}
}

// MARK: - Modifiers

public extension NSStackView {
	/// The geometric padding, in points, inside the stack view, surrounding its views.
	@discardableResult
	override func padding(_ padding: Double = 20) -> Self {
		self.edgeInsets = NSEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
		return self
	}

	/// The geometric padding, in points, inside the stack view, surrounding its views.
	@discardableResult
	@objc override func padding(top: Double = 0, left: Double = 0, bottom: Double = 0, right: Double = 0) -> Self {
		self.edgeInsets = NSEdgeInsets(top: top, left: left, bottom: bottom, right: right)
		return self
	}

	/// Set the edge insets for the stack view
	/// - Parameter insets: The insets
	/// - Returns: self
	@discardableResult @inlinable
	func edgeInsets(_ insets: NSEdgeInsets) -> Self {
		self.edgeInsets = insets
		return self
	}

	/// Set the distribution
	/// - Parameter distribution: The distribution
	/// - Returns: self
	///
	/// [distribution documentation](https://developer.apple.com/documentation/appkit/nsstackview/distribution-swift.property)
	@discardableResult @inlinable
	func distribution(_ distribution: Distribution) -> Self {
		self.distribution = distribution
		return self
	}

	/// The spacing between each stack item
	/// - Parameter spacing: The spacing
	/// - Returns: self
	@discardableResult @inlinable
	func spacing(_ spacing: Double) -> Self {
		self.spacing = spacing
		return self
	}

	/// The view alignment within the stack view.
	/// - Parameter alignment: The alignment
	/// - Returns: self
	///
	/// [alignment documentation](https://developer.apple.com/documentation/appkit/nsstackview/alignment)
	@discardableResult @inlinable
	func alignment(_ alignment: NSLayoutConstraint.Attribute) -> Self {
		self.alignment = alignment
		return self
	}

	/// Returns the first subview that matches the given identifier
	/// - Parameter identifier: The NSUserInterfaceItemIdentifier to search for
	/// - Returns: The matching NSView, or nil if no match is found
	override func allSubviews() -> [NSView] {
		var items: [NSView] = [self]
		for subview in self.arrangedSubviews {
			items.append(contentsOf: subview.allSubviews())
		}
		return items
	}
}

public extension NSStackView {
	/// Sets the Auto Layout priority for the stack view to minimize its size, for a specified user interface axis.
	/// - Parameters:
	///   - priority: The priority
	///   - orientation: The orientation
	/// - Returns: self
	///
	/// [Stack hugging priority](https://developer.apple.com/documentation/appkit/nsstackview/sethuggingpriority(_:for:))
	@discardableResult @inlinable
	func hugging(_ priority: NSLayoutConstraint.Priority, for orientation: NSLayoutConstraint.Orientation) -> Self {
		self.setHuggingPriority(priority, for: orientation)
		return self
	}
}

// MARK: - NSStackView Gravity

private let __gravityIdentifier = "AppKitUI.NSStackView.Gravity"

@MainActor
extension NSView {
	/// Set the gravity area for this view (used only if its parent is a stack view)
	/// - Parameter value: The gravity
	/// - Returns: self
	public func gravityArea(_ value: NSStackView.Gravity) -> Self {
		self.setArbitraryValue(value, forKey: __gravityIdentifier)
		return self
	}

	/// Get the gravity for this view if it has been set
	func gravityArea() -> NSStackView.Gravity? {
		self.getArbitraryValue(forKey: __gravityIdentifier)
	}
}

// MARK: - Previews

#if DEBUG
private let _text = "Call me Ishmael. Some years ago—never mind how long precisely—having little or no money in my purse, and nothing particular to interest me on shore, I thought I would sail about a little and see the watery part of the world. It is a way I have of driving off the spleen and regulating the circulation. Whenever I find myself growing grim about the mouth; whenever it is a damp, drizzly November in my soul; whenever I find myself involuntarily pausing before coffin warehouses, and bringing up the rear of every funeral I meet; and especially whenever my hypos get such an upper hand of me, that it requires a strong moral principle to prevent me from deliberately stepping into the street, and methodically knocking people’s hats off—then, I account it high time to get to sea as soon as I can. This is my substitute for pistol and ball. With a philosophical flourish Cato throws himself upon his sword; I quietly take to the ship. There is nothing surprising in this. If they but knew it, almost all men in their degree, some time or other, cherish very nearly the same feelings towards the ocean with me."

@available(macOS 14, *)
#Preview("Basic stack") {
	VStack {
		HStack {
			NSButton(title: "Fish and chips")
			NSButton(title: "cats")
		}

		NSTextField(label: _text)
			.alignment(.justified)
			.compressionResistancePriority(.defaultLow, for: .horizontal)

		HStack {
			NSButton(title: "Fish and chips")
			NSButton(title: "cats")
		}
		.distribution(.fillEqually)
	}
	.debugFrames(.systemGreen)
}

#endif
