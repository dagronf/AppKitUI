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

/// `NSButton` radio helpers

public extension NSButton {
	/// Create a radio group (NSStackView of NSButtons)
	/// - Parameter orientation: The radio group orientation
	/// - Returns: A new radio group
	@discardableResult @inlinable
	static func radioGroup(orientation: NSUserInterfaceLayoutOrientation = .vertical) -> RadioGroup {
		RadioGroup(orientation: orientation)
	}
}

@MainActor
public class RadioGroup: NSStackView {
	/// Create a radio group
	/// - Parameter orientation: The orientation for the radio group
	public init(orientation: NSUserInterfaceLayoutOrientation = .vertical) {
		super.init(frame: .zero)
		self.translatesAutoresizingMaskIntoConstraints = false

		// The alignment _must_ be set before the orientation or else the orientation
		// resets to vertical and cannot be changed. Dunno why
		self.alignment = (orientation == .vertical) ? .leading : .centerY
		self.orientation = orientation
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	/// Set the radio button items
	/// - Parameter items: The titles for the radio buttons
	/// - Returns: self
	@discardableResult
	public func items(_ items: [String]) -> Self {
		self.setItems(items)
		return self
	}

	/// Set the control size
	/// - Parameter size: The control size
	/// - Returns: self
	@discardableResult
	public func controlSize(_ size: NSControl.ControlSize) -> Self {
		self.radioSize = size
		return self
	}

	/// The position for the radio button
	/// - Parameter pos: The position
	/// - Returns: self
	@discardableResult
	public func position(_ pos: NSControl.ImagePosition) -> Self {
		self.imagePosition = pos
		return self
	}

	/// Set the hugging priority for each radio control
	/// - Parameter value: The priority
	/// - Returns: self
	public func huggingResistance(_ value: NSLayoutConstraint.Priority) -> Self {
		self.allButtons.forEach { $0.setContentHuggingPriority(value, for: .horizontal) }
		self.needsLayout = true
		return self
	}

	/// Set the compression resistence for each radio control
	/// - Parameter value: The priority
	/// - Returns: self
	public func compressionResistance(_ value: NSLayoutConstraint.Priority) -> Self {
		self.allButtons.forEach { $0.setContentCompressionResistancePriority(value, for: .horizontal) }
		self.needsLayout = true
		return self
	}

	private var indexBinding: Bind<Int>?
	private var selectionChanged: ((Int) -> Void)?
	private var radioSize: NSControl.ControlSize = .regular {
		didSet {
			self.allButtons.forEach { $0.controlSize = radioSize }
		}
	}
	private var imagePosition: NSControl.ImagePosition = .imageLeading {
		didSet {
			self.allButtons.forEach { $0.imagePosition = imagePosition }
		}
	}
	private var isEnabled: Bool = true {
		didSet {
			self.allButtons.forEach { $0.isEnabled = isEnabled }
		}
	}
}

// MARK: - Actions

@MainActor
public extension RadioGroup {
	/// Called when the user changes the selection
	/// - Parameter block: The block to call
	/// - Returns: self
	@discardableResult
	func onSelectedIndexChange(_ block: @escaping (Int) -> Void) -> Self {
		self.selectionChanged = block
		return self
	}
}

// MARK: - Binding

@MainActor
public extension RadioGroup {
	/// Bind the radio group items
	/// - Parameter items: The items to display
	/// - Returns: self
	@discardableResult
	func items(_ items: Bind<[String]>) -> Self {
		items.register(self) { @MainActor [weak self] newItems in
			self?.setItems(newItems)
		}
		self.setItems(items.wrappedValue)
		return self
	}

	/// Bind the radio group index selection
	/// - Parameter index: The indexes to select
	/// - Returns: self
	@discardableResult
	func selectedIndex(_ index: Bind<Int>) -> Self {
		index.register(self) { @MainActor [weak self] newSelection in
			if newSelection != self?.selectedIndex {
				self?.selectItem(newSelection)
			}
		}
		self.indexBinding = index
		self.selectItem(index.wrappedValue)
		return self
	}

	/// Bind the enabled status
	/// - Parameter isEnabled: The enabled binder
	/// - Returns: self
	@discardableResult
	func isEnabled(_ isEnabled: Bind<Bool>) -> Self {
		isEnabled.register(self) { @MainActor [weak self] isEnabled in
			self?.allButtons.forEach { $0.isEnabled = isEnabled }
		}
		self.allButtons.forEach { $0.isEnabled = isEnabled.wrappedValue }
		return self
	}
}

// MARK: - Utilities

private extension RadioGroup {

	@objc func selectionDidChange(_ sender: NSButton) {
		self.selectItem(sender.tag)
	}

	/// All of the nested buttons
	var allButtons: [NSButton] {
		self.arrangedSubviews as! [NSButton]
	}

	/// All the current radio button titles
	var allTitles: [String] {
		self.allButtons.map { $0.title }
	}

	// The currently selected index
	var selectedIndex: Int {
		self.allButtons.firstIndex(where: { $0.state == .on }) ?? -1
	}

	func selectItem(_ index: Int) {
		self.allButtons.forEach {
			if $0.tag == index {
				$0.state = .on
			}
		}
		self.indexBinding?.wrappedValue = index
		self.selectionChanged?(index)
	}

	func setItems(_ items: [String]) {
		self.removeAllItems()
		items.enumerated().forEach {
			let b = NSButton(radioButtonWithTitle: $0.element, target: self, action: #selector(selectionDidChange(_:)))
			b.translatesAutoresizingMaskIntoConstraints = false
			b.tag = $0.offset
			b.controlSize = self.radioSize
			b.imagePosition = self.imagePosition
			if self.arrangedSubviews.count == 0 {
				b.state = .on
			}
			self.addArrangedSubview(b)
		}
	}

	func removeAllItems() {
		self.arrangedSubviews.forEach { self.removeArrangedSubview($0) }
	}
}

// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("default") {
	let selectedIndex = Bind(2)
	let isEnabled = Bind(false)
	ScrollView {
		VStack {
			HStack {
				VStack {
					NSButton.radioGroup()
						.items(["zero", "one", "two", "three", "four", "five"])
						.selectedIndex(selectedIndex)
					NSButton(title: "Reset")
						.onAction { _ in
							selectedIndex.wrappedValue = 2
						}
				}

				VStack {
					NSButton.radioGroup()
						.items(["zero", "one", "two", "three", "four", "five"])
						.selectedIndex(selectedIndex)
						.controlSize(.small)
						.isEnabled(isEnabled)
					NSSwitch()
						.state(isEnabled)
						.controlSize(.small)
				}

				NSButton.radioGroup()
					.controlSize(.mini)
					.items(["zero", "one", "two", "three", "four", "five"])
					.selectedIndex(selectedIndex)
			}

			HDivider()

			NSButton.radioGroup(orientation: .horizontal)
				.position(.imageAbove)
				.distribution(.fillEqually)
				.items(["Mavericks", "Catalina", "Big Sur"])
				.onSelectedIndexChange { index in
					Swift.print("Selection is now \(index)")
				}
				.padding()
				.debugFrame()

			HDivider()

			NSButton.radioGroup(orientation: .vertical)
				.items([
					"Show reduction of big quakes",
					"Lots of things that are great by never mentioned",
					"Big Sur"
				])
				.compressionResistance(.defaultLow)
				.huggingResistance(.init(1))
		}
	}
	.padding(top: 38, left: 20, bottom: 20, right: 20)
	.debugFrames()
}

#endif
