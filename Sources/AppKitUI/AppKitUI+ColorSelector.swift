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


/// A control that allows single or multiple selection of a colleection of colors
@MainActor
public class AUIColorSelector: NSView {
	/// Create a color selector view
	public convenience init() {
		self.init(frame: .zero)
		self.setup()
	}

	public override var intrinsicContentSize: NSSize {
		NSSize(width: -1, height: controlHeight(for: self.controlSize))
	}
	public override var firstBaselineOffsetFromTop: CGFloat { controlHeight(for: self.controlSize) - 3 }
	public override var lastBaselineOffsetFromBottom: CGFloat { 3 }
	//	public override var baselineOffsetFromBottom: CGFloat { 8 }

	deinit {
		os_log("deinit: AUIColorSelector", log: logger, type: .debug)
	}

	// Private

	private var colors: [NSColor] = [.systemRed, .systemOrange, .systemYellow, .systemGreen, .systemBlue, .systemPurple, .systemGray]
	private var selection: Bind<Int?>?
	private var selections: Bind<Set<Int>>?

	private let stack: NSStackView = {
		let s = NSStackView()
		s.orientation = .horizontal
		s.translatesAutoresizingMaskIntoConstraints = false

		s.setContentHuggingPriority(.required, for: .horizontal)
		s.setContentHuggingPriority(.required, for: .vertical)
		s.setContentCompressionResistancePriority(.required, for: .horizontal)
		s.setContentCompressionResistancePriority(.required, for: .vertical)
		return s
	}()

	private var allowsMultipleSelection = false
	private var isEnabledBinding = Bind(true)

	private var controlSize = NSControl.ControlSize.regular {
		didSet {
			self.colorButtons.forEach { $0.controlSize = self.controlSize }
		}
	}

	private var colorButtons: [ColorButton] {
		self.stack.arrangedSubviews.map { $0 as! ColorButton }
	}

	// The control selections
	private var selectionsCore = Set<Int>() {
		didSet {
			self.reflectSelection()
		}
	}
	private var onSelectionChange: ((Set<Int>) -> Void)?
}

@MainActor
private extension AUIColorSelector {
	func setup() {
		self.translatesAutoresizingMaskIntoConstraints = false
		self.wantsLayer = true
		self.layer!.contentsScale = 2
		self.setAccessibilityRole(.radioGroup)

		self.stack.pin(inside: self)

		self.updateContent()

		self.updateLayer()
	}

	func updateContent() {

		// Clean

		self.stack.arrangedSubviews.forEach {
			self.stack.removeArrangedSubview($0)

			// NOTE: If we don't call `removeFromSuperview` here, the object doesn't get cleaned up.
			$0.removeFromSuperview()
		}

		// Build

		self.colors.enumerated().map {
			let c = ColorButton($0.element)
				.isEnabled(self.isEnabledBinding)
				.tag($0.offset)
				.controlSize(self.controlSize)
				.onAction(target: self, action: #selector(buttonPressed(_:)))
			self.stack.addArrangedSubview(c)
		}

		self.reflectSelection()
	}

	@objc func buttonPressed(_ sender: ColorButton) {
		let index = sender.tag

		if self.allowsMultipleSelection {
			if self.selectionsCore.contains(index) {
				self.selectionsCore.remove(index)
			}
			else {
				self.selectionsCore.insert(index)
			}
		}
		else {
			self.selectionsCore = Set([index])
		}

		self.needsDisplay = true
	}

	func reflectSelection() {
		self.colorButtons.forEach {
			$0.state = (self.selectionsCore.contains($0.tag)) ? .on : .off
		}
		self.selection?.wrappedValue = self.selectionsCore.first
		self.selections?.wrappedValue = self.selectionsCore
		self.onSelectionChange?(self.selectionsCore)
	}
}

// MARK: - Modifiers

@MainActor
public extension AUIColorSelector {
	/// Set the colors to be displayed in the control
	/// - Parameter colors: The colors
	/// - Returns: self
	func colors(_ colors: [NSColor]) -> Self {
		self.colors = colors
		self.updateContent()
		return self
	}

	/// Set the control to select multiple items
	/// - Parameter value: If true, allows multiple selection
	/// - Returns: self
	@discardableResult
	func allowsMultipleSelection(_ value: Bool) -> Self {
		self.allowsMultipleSelection = value
		return self
	}

	/// Set the control size
	/// - Parameter size: The control size
	/// - Returns: self
	@discardableResult
	func controlSize(_ size: NSControl.ControlSize) -> Self {
		self.controlSize = size
		return self
	}

	/// Enable or disable the control
	/// - Parameter value: The enabled status
	/// - Returns: self
	@discardableResult
	func isEnabled(_ value: Bool) -> Self {
		self.isEnabledBinding.wrappedValue = value
		return self
	}

	/// Set the spacing between each of the color buttons
	/// - Parameter value: The spacing
	/// - Returns: self
	@discardableResult
	func spacing(_ value: Double) -> Self {
		self.stack.spacing = value
		return self
	}
}

// MARK: - Actions

@MainActor
public extension AUIColorSelector {
	/// A block to call when the selection changes
	/// - Parameter block: A block, passing the current selection for the control
	/// - Returns: self
	@discardableResult
	func onSelectionChange(_ block: @escaping (Set<Int>) -> Void) -> Self {
		self.onSelectionChange = block
		return self
	}
}

// MARK: - Binding

@MainActor
public extension AUIColorSelector {
	/// Bind the enabled state for the control
	/// - Parameter value: If true, enables the control
	/// - Returns: self
	func isEnabled(_ value: Bind<Bool>) -> Self {
		value.register(self) { @MainActor [weak self] newValue in
			self?.isEnabledBinding.wrappedValue = newValue
		}
		self.isEnabledBinding.wrappedValue = value.wrappedValue
		return self
	}

	/// Set the colors to be displayed in the control
	/// - Parameter colors: The colors
	/// - Returns: self
	func colors(_ colors: Bind<[NSColor]>) -> Self {
		colors.register(self) { @MainActor [weak self] newValue in
			self?.colors = newValue
			self?.updateContent()
		}

		self.colors = colors.wrappedValue
		self.updateContent()
		return self
	}

	/// Bind the control's selection (single selection)
	/// - Parameter selection: The single selection (radio style)
	/// - Returns: self
	public func selection(_ selection: Bind<Int?>) -> Self {
		self.selection = selection
		selection.register(self) { @MainActor [weak self] newValue in
			if newValue != self?.selectionsCore.first {
				self?.selectionsCore = newValue == nil ? Set() : Set([newValue!])
			}
		}

		if let selection = selection.wrappedValue {
			self.selectionsCore = Set([selection])
		}
		else {
			self.selectionsCore = Set()
		}

		return self
	}

	/// Bind the control's selections (multiple selection)
	/// - Parameter selection: The selection
	/// - Returns: self
	public func selections(_ selections: Bind<Set<Int>>) -> Self {
		self.selections = selections
		selections.register(self) { @MainActor [weak self] newValue in
			if newValue != self?.selectionsCore {
				self?.selectionsCore = newValue
			}
		}
		self.selectionsCore = selections.wrappedValue
		return self
	}
}

// MARK: - AppKit color button

@MainActor
private class ColorButton: NSButton {

	var color: NSColor = .gray {
		didSet {
			self.needsDisplay = true
		}
	}

	convenience init(_ color: NSColor) {
		self.init(frame: .zero)

		self.translatesAutoresizingMaskIntoConstraints = false

		self.color = color
		self.setAccessibilityRole(.radioButton)

		self.wantsLayer = true

		self.gradientLayer.zPosition = 5
		self.circleMaskLayer.zPosition = 10
		self.selectionLayer.zPosition = 20
		self.borderLayer.zPosition = 25

		self.layer!.addSublayer(self.gradientLayer)
		self.layer!.addSublayer(self.selectionLayer)
		self.layer!.addSublayer(self.borderLayer)

		if #available(macOS 11, *) {
		}
		else {
			// For macOS 10.13, the bezel style MUST be regular square for layers to work!
			self.bezelStyle = .regularSquare
		}

		self.isBordered = false
		self.imagePosition = .imageOnly
	}

	deinit {
		os_log("deinit: ColorButton", log: logger, type: .debug)
	}

	public override var intrinsicContentSize: NSSize {
		let sz = controlHeight(for: self.controlSize)
		return NSSize(width: sz, height: sz)
	}

	let gradientLayer = CAGradientLayer()
	let circleMaskLayer = CAShapeLayer()
	let borderLayer = CAShapeLayer()
	let selectionLayer = CAShapeLayer()

	override func updateLayer() {
		super.updateLayer()

		let bounds = self.bounds
		var destination = bounds.insetBy(dx: 0.5, dy: 0.5)
		if bounds.width > bounds.height {
			destination.origin.x = (bounds.width - bounds.height) / 2.0
			destination.size.width = bounds.height
		}
		else if bounds.width < bounds.height {
			destination.origin.y = (bounds.width - bounds.height) / 2.0
			destination.size.height = bounds.width
		}

		let ihc = self.isHighContrast

		// The color circle
		let c = self.circleMaskLayer
		c.frame = self.bounds
		c.path = CGPath(ellipseIn: destination, transform: nil)

		let g = self.gradientLayer
		g.frame = self.bounds
		g.colors = [
			self.color.lighter(withLevel: 0.3).effectiveCGColor,
			self.color.darker(withLevel: 0.3).effectiveCGColor
		]
		g.startPoint = .init(x: 0, y: 0)
		g.endPoint = .init(x: 0, y: 1)

		g.mask = c

		//
		// The selection circle
		//
		let s = self.selectionLayer
		s.frame = self.bounds

		let inset = destination.insetBy(dx: destination.height / 4, dy: destination.height / 4)
		s.path = CGPath(ellipseIn: inset, transform: nil)
		s.fillColor = CGColor.white
		s.strokeColor = ihc ? CGColor.black : CGColor.black.copy(alpha: 0.8)
		s.lineWidth = 0.5

		s.isHidden = self.state != .on

		//
		// The border
		//
		let b = self.borderLayer
		b.frame = self.bounds
		b.fillColor = CGColor.clear
		b.path = CGPath(ellipseIn: destination, transform: nil)
		b.strokeColor = ihc ? CGColor.black : CGColor(gray: 0, alpha: 0.4)
		b.lineWidth = 0.5

		//
		// Handle enabled state
		//
		self.alphaValue = self.isEnabled ? 1.0 : 0.5
	}

	override func drawFocusRingMask() {
		var destination = self.bounds
		if bounds.width > bounds.height {
			destination.origin.x = (bounds.width - bounds.height) / 2.0
			destination.size.width = bounds.height
		}
		else if bounds.width < bounds.height {
			destination.origin.y = (bounds.width - bounds.height) / 2.0
			destination.size.height = bounds.width
		}
		let dest = NSBezierPath(ovalIn: destination)
		NSColor.black.setFill()
		dest.fill()
	}
}

// MARK: - Sizing helpers

private func controlHeight(for size: NSControl.ControlSize) -> Double {
	if size == .regular { return 16 }
	else if size == .small { return 14 }
	else if size == .mini { return 12 }

	if #available(macOS 11, *) {
		if size == .large {
			return 20
		}
	}
//	if #available(macOS 26, *) {
//		if size == .extraLarge {
//			return 26
//		}
//	}
	fatalError()
}

// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("default") {
	let enabled = Bind(true)
	let editableColors = Bind([
		NSColor(red: 0.969, green: 0.552, blue: 0.379, alpha: 1.000),
		NSColor(red: 0.919, green: 0.130, blue: 0.392, alpha: 1.000),
		NSColor(red: 0.391, green: 0.054, blue: 0.373, alpha: 1.000),
		NSColor(red: 0.050, green: 0.069, blue: 0.392, alpha: 1.000),
	])

	let menuColors = Bind(Set([1, 4]))

	NSView(layoutStyle: .centered) {
		NSGridView(rowSpacing: 12) {
			NSGridView.Row {
				NSTextField(label: "Default:")
				AUIColorSelector()
			}
			NSGridView.Row {
				NSTextField(label: "Multiple select:")
				AUIColorSelector()
					.allowsMultipleSelection(true)
			}

			NSGridView.Row {
				NSTextField(label: "Default (Disabled):")
				AUIColorSelector()
					.isEnabled(false)
			}

			NSGridView.Row {
				NSTextField(label: "Enabled state:")

				HStack {
					AUIColorSelector()
						.isEnabled(enabled)
					AUISwitch()
						.state(enabled)
				}
			}

			NSGridView.Row {
				NSTextField(label: "Custom spacing:")
				VStack(alignment: .leading) {
					AUIColorSelector()
						.spacing(2)
					AUIColorSelector()
						.spacing(12)
				}
				NSGridCell.emptyContentView
			}

			NSGridView.Row {
				NSTextField(label: "Color changing:")
				HStack {
					AUIColorSelector()
						.colors(editableColors)
					NSButton(title: "Reverse colors")
						.onAction { _ in
							editableColors.wrappedValue = editableColors.wrappedValue.reversed()
						}
				}
				NSGridCell.emptyContentView
			}

			NSGridView.Row {
				NSTextField(label: "Size:")
				VStack(alignment: .leading) {
//					AUIColorSelector()
//						.controlSize(.extraLarge)
					AUIColorSelector()
						.controlSize(.large)
					AUIColorSelector()
						.controlSize(.regular)
					AUIColorSelector()
						.controlSize(.small)
						.spacing(6)
					AUIColorSelector()
						.controlSize(.mini)
						.spacing(4)
				}
				NSGridCell.emptyContentView
			}

			NSGridView.Row {
				NSTextField(label: "Add to menu:")
				NSButton()
					.onActionMenu(
						NSMenu {
							NSMenuItem()
								.view {
									HStack(spacing: 12) {
										NSButton()
											.image(NSImage(named: NSImage.stopProgressTemplateName)!)
											.imagePosition(.imageOnly)
											.isBordered(false)
											.onAction { _ in
												menuColors.wrappedValue = Set()
											}
										AUIColorSelector()
											.colors([.systemRed, .systemYellow, .systemOrange, .systemGreen, .systemPurple, .systemBlue])
											.allowsMultipleSelection(true)
											.selections(menuColors)
									}
									.padding(12)
								}
							NSMenuItem(title: "Tags…")
								.onAction { _ in
									Swift.print("Tags menu")
								}
						}
					)
				NSGridCell.emptyContentView
			}
		}
		.rowAlignment(.firstBaseline)
		.columnAlignment(.trailing, forColumn: 0)
	}
}

#endif
