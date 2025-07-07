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

public extension NSSegmentedControl {
	/// A segment definition
	struct Segment {
		/// Segment tile
		let title: String
		/// Segment image
		let image: NSImage?
		/// The scaling for the segment image
		let imageScaling: NSImageScaling?
		/// The horizontal alignment for the text within the segment
		let alignment: NSTextAlignment?
		/// The segment's tool tip
		let toolTip: String?
		/// The menu to associate with the segment
		let menu: NSMenu?
		/// Should we show a menu indicator for this segment?
		let showsMenuIndicator: Bool

		/// Create a segmented control segment
		/// - Parameters:
		///   - title: The title for the segment
		///   - image: The image for the segment
		///   - imageScaling: The scaling to apply to the image
		///   - alignment: The text alignment for the segment
		///   - toolTip: The segment's tool tip
		///   - menu: A menu associated with the segment
		///   - showsMenuIndicator: If true, displays an indicator if there's a menu available
		public init(
			title: String,
			image: NSImage? = nil,
			imageScaling: NSImageScaling? = nil,
			alignment: NSTextAlignment? = nil,
			toolTip: String? = nil,
			menu: NSMenu? = nil,
			showsMenuIndicator: Bool = false
		) {
			self.title = title
			self.image = image
			self.imageScaling = imageScaling
			self.alignment = alignment
			self.toolTip = toolTip
			self.menu = menu
			self.showsMenuIndicator = showsMenuIndicator
		}
	}
}

@MainActor
public extension NSSegmentedControl {
	/// Create a segment control using a segment items builder
	/// - Parameters:
	///   - style: The segmented control style
	///   - distribution: The distribution for the segments
	///   - segments: The builder
	convenience init(
		style: NSSegmentedControl.Style? = nil,
		distribution: NSSegmentedControl.Distribution? = nil,
		@NSSegmentItemsBuilder segments: () -> [NSSegmentedControl.Segment]
	) {
		self.init()
		
		if let style {
			self.style(style)
		}
		if let distribution {
			self.segmentDistribution(distribution)
		}
		self.segments(segments())
	}
}

@MainActor
public extension NSSegmentedControl {
	/// Set the segments
	/// - Parameter segments: The segments
	/// - Returns: self
	@discardableResult
	func segments(_ segments: [String]) -> Self {
		self.segmentCount = segments.count
		(0 ..< segments.count).forEach { index in
			self.setLabel(segments[index], forSegment: index)
		}
		return self
	}

	/// Set the segments for the segmented control
	/// - Parameter segments: The segments
	/// - Returns: self
	@discardableResult
	func segments(_ segments: [NSSegmentedControl.Segment]) -> Self {
		self.segmentCount = segments.count
		(0 ..< segments.count).forEach { index in
			let which = segments[index]
			self.setLabel(which.title, forSegment: index)
			self.setImage(which.image, forSegment: index)
			self.setShowsMenuIndicator(which.showsMenuIndicator, forSegment: index)
			if let imageScaling = which.imageScaling {
				self.setImageScaling(imageScaling, forSegment: index)
			}
			if let alignment = which.alignment {
				self.setAlignment(alignment, forSegment: index)
			}
			if let toolTip = which.toolTip {
				self.setToolTip(toolTip, forSegment: index)
			}
			if let menu = which.menu {
				self.setMenu(menu, forSegment: index)
			}
		}
		return self
	}

	/// Set the segment image
	/// - Parameters:
	///   - image: The image to set
	///   - imageScaling: The scaling to apply to the image
	///   - segmentIndex: The index of the segment to set the image for
	/// - Returns: self
	@discardableResult
	func image(_ image: NSImage, imageScaling: NSImageScaling? = nil, forSegmentIndex segmentIndex: Int) -> Self {
		self.setImage(image, forSegment: segmentIndex)
		if let imageScaling {
			self.setImageScaling(imageScaling, forSegment: segmentIndex)
		}
		return self
	}

	@discardableResult @inlinable
	func textAlignment(_ alignment: NSTextAlignment, forSegmentIndex segmentIndex: Int) -> Self {
		self.setAlignment(alignment, forSegment: segmentIndex)
		return self
	}

	/// Set the segmented style
	/// - Parameter style: The style
	/// - Returns: self
	@discardableResult @inlinable
	func style(_ style: NSSegmentedControl.Style) -> Self {
		self.segmentStyle = style
		return self
	}

	/// Set the tracking mode
	/// - Parameter mode: The tracking mode
	/// - Returns: self
	@discardableResult @inlinable
	func trackingMode(_ mode: NSSegmentedControl.SwitchTracking) -> Self {
		self.trackingMode = mode
		return self
	}

	/// Set the width for a segment
	/// - Parameters:
	///   - width: The segment width
	///   - segmentIndex: The index of the segment
	/// - Returns: self
	@discardableResult @inlinable
	func width(_ width: Double, forSegmentIndex segmentIndex: Int) -> Self {
		self.setWidth(width, forSegment: segmentIndex)
		return self
	}

	/// Set the tooltip for a segment
	/// - Parameters:
	///   - toolTip: The tool tip
	///   - segmentIndex: The index of the segment
	/// - Returns: self
	@discardableResult @inlinable
	func toolTip(_ toolTip: String, forSegmentIndex segmentIndex: Int) -> Self {
		self.setToolTip(toolTip, forSegment: segmentIndex)
		return self
	}

	/// Set the distribution for the segments in the control
	/// - Parameter distribution: The distribution for the segments
	/// - Returns: self
	@discardableResult @inlinable
	func segmentDistribution(_ distribution: NSSegmentedControl.Distribution) -> Self {
		self.segmentDistribution = distribution
		return self
	}

	/// Set the menu for a segment
	/// - Parameters:
	///   - menu: The menu
	///   - showMenuIndicator: If true, displays an indicator that the menu is available
	///   - segmentIndex: The index of the segment
	/// - Returns: self
	@discardableResult @inlinable
	func menu(_ menu: NSMenu, showMenuIndicator: Bool = false, forSegment segmentIndex: Int) -> Self {
		self.setMenu(menu, forSegment: segmentIndex)
		self.setShowsMenuIndicator(showMenuIndicator, forSegment: segmentIndex)
		return self
	}

	/// Select exactly one segment
	@discardableResult @inlinable
	func selectIndex(_ index: Int) -> Self {
		self.selectedSegment = index
		return self
	}

	/// Select indexes
	/// - Parameter indexes: The indexes to select
	/// - Returns: self
	@discardableResult @inlinable
	func selectIndexes(_ indexes: Set<Int>) -> Self {
		(0 ..< self.segmentCount).forEach { index in
			self.setSelected(indexes.contains(index), forSegment: index)
		}
		return self
	}

	/// Enable indexes
	/// - Parameter indexes: The indexes to enable
	/// - Returns: self
	@discardableResult @inlinable
	func enabledIndexes(_ indexes: Set<Int>) -> Self {
		(0 ..< self.segmentCount).forEach { index in
			self.setEnabled(indexes.contains(index), forSegment: index)
		}
		return self
	}
}


// MARK: - Actions

@MainActor
public extension NSSegmentedControl {
	/// Set a callback for when the segmented control selection changes
	/// - Parameter block: The block to call
	/// - Returns: self
	@discardableResult
	func onSelectionChange(_ block: @escaping (Int) -> Void) -> Self {
		self.usingSegmentedControlStorage { $0.onSelectionChange = block }
		return self
	}

	/// Set a callback for when the segmented control selection changes
	/// - Parameter block: The block to call
	/// - Returns: self
	@discardableResult
	func onSelectionsChange(_ block: @escaping (Set<Int>) -> Void) -> Self {
		self.usingSegmentedControlStorage { $0.onSelectionsChange = block }
		return self
	}
}

// MARK: - Bindings

@MainActor
public extension NSSegmentedControl {
	/// Bind the selected index for the control
	/// - Parameter value: The selection binding
	/// - Returns: self
	func selectedIndex(_ value: Bind<Int>) -> Self {
		value.register(self) { @MainActor [weak self] selection in
			if self?.selectedSegment != selection {
				self?.selectedSegment = selection
			}
		}
		self.usingSegmentedControlStorage { $0.selection = value }
		self.selectedSegment = value.wrappedValue
		return self
	}

	/// Bind the selected indexes for the control
	/// - Parameter value: The selection binding
	/// - Returns: self
	func selectedIndexes(_ values: Bind<Set<Int>>) -> Self {
		values.register(self) { @MainActor [weak self] selection in
			self?.selectIndexes(selection)
		}
		self.usingSegmentedControlStorage { $0.selections = values }
		self.selectIndexes(values.wrappedValue)
		return self
	}

	/// Bind enabled indexes
	/// - Parameter indexes: The indexes to enable
	/// - Returns: self
	func enabledIndexes(_ indexes: Bind<Set<Int>>) -> Self {
		indexes.register(self) { @MainActor [weak self] selected in
			self?.enabledIndexes(selected)
		}
		self.enabledIndexes(indexes.wrappedValue)
		return self
	}
}

// MARK: - Segment builders

@MainActor
@resultBuilder
public enum NSSegmentItemsBuilder {
	public static func buildBlock() -> [NSSegmentedControl.Segment] { [] }
}

@MainActor
public extension NSSegmentItemsBuilder {
	static func buildBlock(_ settings: NSSegmentedControl.Segment...) -> [NSSegmentedControl.Segment] {
		settings
	}

	static func buildBlock(_ settings: [NSSegmentedControl.Segment]) -> [NSSegmentedControl.Segment] {
		settings
	}

	static func buildOptional(_ component: [NSSegmentedControl.Segment]?) -> [NSSegmentedControl.Segment] {
		component ?? []
	}

	/// Add support for if statements.
	static func buildEither(first components: [NSSegmentedControl.Segment]) -> [NSSegmentedControl.Segment] {
		 components
	}

	static func buildEither(second components: [NSSegmentedControl.Segment]) -> [NSSegmentedControl.Segment] {
		 components
	}

	/// Add support for loops.
	static func buildArray(_ components: [[NSSegmentedControl.Segment]]) -> [NSSegmentedControl.Segment] {
		 components.flatMap { $0 }
	}
}


// MARK: Storage

@MainActor
private extension NSSegmentedControl {
	func usingSegmentedControlStorage(_ block: @escaping (Storage) -> Void) {
		self.usingAssociatedValue(key: "__nssegmentedbond", initialValue: { Storage(self) }, block)
	}

	/// Return the selected indexes for the control
	var __selectedIndexes: Set<Int> {
		Set((0 ..< self.segmentCount).compactMap {
			self.isSelected(forSegment: $0) ? $0 : nil
		})
	}

	@MainActor class Storage {
		weak var control: NSSegmentedControl?

		var onSelectionChange: ((Int) -> Void)?
		var onSelectionsChange: ((Set<Int>) -> Void)?

		var selection: Bind<Int>?
		var selections: Bind<Set<Int>>?

		init(_ control: NSSegmentedControl) {
			control.target = self
			control.action = #selector(actionCalled(_:))
			self.control = control
		}

		deinit {
			Swift.print("deinit: NSSegmentedControl.Storage")
		}

		@objc func actionCalled(_ sender: NSSegmentedControl) {
			let selections = sender.__selectedIndexes
			self.onSelectionChange?(selections.first ?? -1)
			self.selection?.wrappedValue = selections.first ?? -1

			self.onSelectionsChange?(selections)
			self.selections?.wrappedValue = selections
		}
	}
}

// MARK: - Previews

#if DEBUG

@MainActor private let _dropDownImage = NSImage(named: "NSDropDownIndicatorTemplate")!
@MainActor private let _segmentImage = NSImage(named: "NSToolbarPrintItemImage")!

@available(macOS 14, *)
#Preview("default") {
	let selIndex = Bind(1)

	let enabledSegments = Bind(Set([0, 1, 3]))

	VStack(spacing: 12) {
		NSSegmentedControl()
			.segments(["one", "two", "three"])
			.selectedIndex(selIndex)
			.onSelectionChange {
				Swift.print("NSSegmentedControl change: \($0)")
			}

		NSSegmentedControl()
			.trackingMode(.selectAny)
			.segments(["cat", "dog", "caterpillar", "noodles"])
			.onSelectionsChange { sele in
				Swift.print("Selections = \(sele)")
			}

		HStack {
			NSSegmentedControl()
				.style(.capsule)
				.segments(["cat", "dog", "caterpillar", "noodles"])
				.enabledIndexes(enabledSegments)
				.onSelectionsChange { sele in
					Swift.print("capsule = \(sele)")
				}
			NSButton(title: "Only enable segment 2")
				.controlSize(.small)
				.onAction { _ in
					enabledSegments.wrappedValue = [2]
				}
		}

		NSSegmentedControl(distribution: .fillEqually) {
			NSSegmentedControl.Segment(
				title: "Colors",
				image: NSImage(named: NSImage.colorPanelName),
				imageScaling: .scaleProportionallyDown,
				toolTip: "Colors segment"
			)
			NSSegmentedControl.Segment(
				title: "Machine",
				image: NSImage(named: NSImage.computerName),
				imageScaling: .scaleProportionallyDown,
				toolTip: "Machine segment",
				menu: NSMenu(title: "wheee") {
					NSMenuItem(title: "First") { item in
						Swift.print("'\(item.title)' selected")
					}
					NSMenuItem(title: "Second") { item in
						Swift.print("'\(item.title)' selected")
					}
				},
				showsMenuIndicator: true
			)
			NSSegmentedControl.Segment(
				title: "Everyone else",
				image: NSImage(named: NSImage.everyoneName),
				imageScaling: .scaleProportionallyDown,
				toolTip: "Everyone else segment"
			)
		}

		HDivider()

		HStack {
			NSSegmentedControl()
				.controlSize(.large)
				.trackingMode(.momentary)
				.segments(["Thingy", ""])
				.image(_segmentImage, imageScaling: .scaleProportionallyDown, forSegmentIndex: 0)
				.image(_dropDownImage, imageScaling: .scaleProportionallyDown, forSegmentIndex: 1)
				.menu(
					NSMenu(title: "One") {
						NSMenuItem(title: "fish")
					},
					forSegment: 1
				)
				.onSelectionChange { value in
					Swift.print("newvalue -> \(value)")
				}

			NSSegmentedControl()
				.trackingMode(.momentary)
				.segments(["Thingy", ""])
				.image(_segmentImage, imageScaling: .scaleProportionallyDown, forSegmentIndex: 0)
				.image(_dropDownImage, imageScaling: .scaleProportionallyDown, forSegmentIndex: 1)
				.menu(
					NSMenu(title: "One") {
						NSMenuItem(title: "fish")
					},
					forSegment: 1
				)
			NSSegmentedControl()
				.controlSize(.small)
				.trackingMode(.momentary)
				.font(.caption1)
				.segments(["Thingy", ""])
				.image(_segmentImage, imageScaling: .scaleProportionallyDown, forSegmentIndex: 0)
				.image(_dropDownImage, imageScaling: .scaleProportionallyDown, forSegmentIndex: 1)
				.menu(
					NSMenu(title: "One") {
						NSMenuItem(title: "fish")
					},
					forSegment: 1
				)

			NSSegmentedControl()
				.controlSize(.mini)
				.trackingMode(.momentary)
				.font(.footnote)
				.segments(["Thingy", ""])
				.image(_segmentImage, imageScaling: .scaleProportionallyDown, forSegmentIndex: 0)
				.image(_dropDownImage, imageScaling: .scaleProportionallyDown, forSegmentIndex: 1)
				.menu(
					NSMenu(title: "One") {
						NSMenuItem(title: "fish")
					},
					forSegment: 1
				)
		}
	}
}

#endif

