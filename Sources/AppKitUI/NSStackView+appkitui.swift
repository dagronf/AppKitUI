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

@MainActor
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

@MainActor
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

// MARK: - Stack specific hugging and clipping

@MainActor
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

	/// Sets the Auto Layout priority for resisting clipping of views in the stack view when Auto Layout attempts to reduce the stack view’s size.
	/// - Parameters:
	///   - priority: The priority
	///   - orientation: The orientation
	/// - Returns: self
	///
	/// [Stack hugging priority](https://developer.apple.com/documentation/appkit/nsstackview/sethuggingpriority(_:for:))
	@discardableResult @inlinable
	func clippingResistance(_ priority: NSLayoutConstraint.Priority, for orientation: NSLayoutConstraint.Orientation) -> Self {
		self.setClippingResistancePriority(priority, for: orientation)
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

@MainActor
private func makeDockSizeStack__(_ dockSize: Bind<Double>) -> NSView {
	VStack(alignment: .leading, spacing: 4) {
		NSTextField(label: "Size:")
		NSSlider(dockSize, range: 0 ... 1)
			.numberOfTickMarks(2)
		HStack {
			NSTextField(label: "Small")
				.font(.caption2)
				.gravityArea(.leading)
			NSView.Spacer()
			NSTextField(label: "Large")
				.font(.caption2)
				.gravityArea(.trailing)
		}
	}
}

@available(macOS 14, *)
#Preview("Simple slider") {
	let dockSize = Bind(0.1)
	makeDockSizeStack__(dockSize)
		.width(250)
		.debugFrames()
}

@available(macOS 14, *)
#Preview("Simple Settings") {

	let sizeInPoints = Bind(12.0)
	let imageSelection = Bind(0)
	let clipboardSettingsSelection = Bind(1)
	let ditherContentOfClipboard = Bind(false)

	let calculateBestColorTable = Bind(false)
	let verifyColorTableIntegrity = Bind(true)
	let notifyOnLossOfColorInformation = Bind(false)
	let notifyBeforeConversion = Bind(false)

	NSGridView(columnSpacing: 6, rowSpacing: 12) {
		NSGridView.Row {
			NSTextField(label: "General Editing:")
			VStack(alignment: .leading, spacing: 6) {
				RadioGroup()
					.items(["Select existing image", "Add a margin around image"])
					.selectedIndex(imageSelection)
				HStack {
					NSTextField(label: "Size:")
					NSTextField(value: sizeInPoints, formatter: NumberFormatter())
						.width(50)
						.isEnabled(imageSelection.oneWayTransform { $0 == 1 })
					NSTextField(label: "points")
				}
				NSButton.checkbox(title: "Reposition windows after change")
				NSButton.checkbox(title: "Remember recent items")
			}
		}

		NSGridView.Row {
			HDivider()
		}
		.mergeCells(0 ... 1)

		NSGridView.Row {
			NSTextField(label: "Clipboard Settings:")
			VStack(alignment: .leading, spacing: 6) {
				RadioGroup()
					.items([
						"Copy selection from image only",
						"Erase selection from image"
					])
					.selectedIndex(clipboardSettingsSelection)
				VStack(alignment: .leading, spacing: 4) {
					NSButton.checkbox(title: "Dither content of clipboard")
						.huggingPriority(.init(10), for: .horizontal)
						.state(ditherContentOfClipboard)
						.descriptionText("Optional description for this setting if this option is enabled.")
				}
			}
			.hugging(.init(10), for: .horizontal)
		}

		NSGridView.Row {
			HDivider()
		}
		.mergeCells(0 ... 1)

		NSGridView.Row {
			NSTextField(label: "Color Optimization:")
			VStack(alignment: .leading, spacing: 6) {
				NSButton.checkbox(title: "Calculate best color table")
					.state(calculateBestColorTable)
				NSButton.checkbox(title: "Verify color table integrity")
					.state(verifyColorTableIntegrity)
				NSButton.checkbox(title: "Notify on loss of color information")
					.state(notifyOnLossOfColorInformation)
				NSButton.checkbox(title: "Notify before CMYK to RGB conversion")
					.state(notifyBeforeConversion)
			}
		}
	}
	.rowAlignment(.firstBaseline)
	.columnAlignment(.trailing, forColumn: 0)
	.padding()
	.debugFrames()
}

#endif
