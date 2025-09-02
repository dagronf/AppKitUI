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

@MainActor
public extension NSButton {
	/// A single radio element within a Radio Group
	public class RadioElement {
		/// The element title
		let title: String
		/// An optional description
		let description: String?

		/// Create a single radio button element configuration
		/// - Parameters:
		///   - title: The titlw
		///   - description: The description (optional)
		public init(title: String, description: String? = nil) {
			self.title = title
			self.description = description
		}

		// Storage for the created radio button
		fileprivate var button: NSButton?
	}

	/// Create a radio group (NSStackView of NSButtons)
	/// - Parameter orientation: The radio group orientation
	/// - Returns: A new radio group
	@discardableResult @inlinable
	static func radioGroup(orientation: NSUserInterfaceLayoutOrientation = .vertical) -> AUIRadioGroup {
		AUIRadioGroup(orientation: orientation)
	}
}

// MARK: - Radio Grouping

@MainActor
public class AUIRadioGroup: NSStackView {
	/// Create a radio group
	/// - Parameter orientation: The orientation for the radio group
	public init(orientation: NSUserInterfaceLayoutOrientation = .vertical) {
		super.init(frame: .zero)
		self.translatesAutoresizingMaskIntoConstraints = false

		// The alignment _must_ be set before the orientation or else the orientation
		// resets to vertical and cannot be changed. Dunno why
		self.alignment = (orientation == .vertical) ? .leading : .centerY
		self.orientation = orientation
		self.spacing = 6
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	/// Set the radio button items from an sequence of strings
	/// - Parameter items: The titles for the radio buttons
	/// - Returns: self
	@discardableResult
	public func items(_ items: Sequence<String>) -> Self {
		items.forEach { title in
			self.item(title: title)
		}
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
	@discardableResult
	public func huggingResistance(_ value: NSLayoutConstraint.Priority) -> Self {
		self.allButtons.forEach { $0.button?.setContentHuggingPriority(value, for: .horizontal) }
		self.needsLayout = true
		return self
	}

	/// Set the compression resistence for each radio control
	/// - Parameter value: The priority
	/// - Returns: self
	@discardableResult
	public func compressionResistance(_ value: NSLayoutConstraint.Priority) -> Self {
		self.allButtons.forEach { $0.button?.setContentCompressionResistancePriority(value, for: .horizontal) }
		self.needsLayout = true
		return self
	}

	/// Add a radio element to the radio group
	/// - Parameters:
	///   - title: The element's title
	///   - description: The element's description
	/// - Returns: self
	public func item(title: String, description: String? = nil) -> Self {
		let rdef = NSButton.RadioElement(title: title, description: description)
		return self.item(rdef)
	}

	/// Add a radio element to the radio group
	/// - Parameters:
	///   - element: The radio element
	/// - Returns: self
	public func item(_ element: NSButton.RadioElement) -> Self {
		let btn = NSButton(radioButtonWithTitle: element.title, target: self, action: #selector(selectionDidChange(_:)))
		btn.translatesAutoresizingMaskIntoConstraints = false
		btn.tag = self.allButtons.count
		btn.controlSize = self.radioSize
		btn.imagePosition = self.imagePosition
		if self.allButtons.count == 0 {
			btn.state = .on
		}

		element.button = btn

		if let description = element.description {
			let descriptionField = NSTextField(label: description)
				.font(.systemSmall)
				.textColor(.secondaryLabelColor)
				.huggingPriority(.defaultLow, for: .horizontal)
				.compressionResistancePriority(.init(1), for: .horizontal)
				.compressionResistancePriority(.defaultHigh, for: .vertical)

			let result = VStack(alignment: .leading, spacing: 4) {
				btn
				descriptionField
			}
			.hugging(.init(1), for: .horizontal)

			result.addConstraint(
				NSLayoutConstraint(
					item: descriptionField, attribute: .leading,
					relatedBy: .equal,
					toItem: btn, attribute: .leading,
					multiplier: 1, constant: 20
				)
			)
			self.addArrangedSubview(result)
		}
		else {
			self.addArrangedSubview(btn)
		}

		self.allButtons.append(element)

		return self
	}

	/// All of the nested buttons definitions
	private var allButtons: [NSButton.RadioElement] = []
	private var indexBinding: Bind<Int>?
	private var selectionChanged: ((Int) -> Void)?
	private var radioSize: NSControl.ControlSize = .regular {
		didSet {
			self.allButtons.forEach { $0.button?.controlSize = radioSize }
		}
	}
	private var imagePosition: NSControl.ImagePosition = .imageLeading {
		didSet {
			self.allButtons.forEach { $0.button?.imagePosition = imagePosition }
		}
	}
	private var isEnabled: Bool = true {
		didSet {
			self.allButtons.forEach { $0.button?.isEnabled = isEnabled }
		}
	}
}

// MARK: - Actions

@MainActor
public extension AUIRadioGroup {
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
public extension AUIRadioGroup {
	/// Set the radio group's elements
	/// - Parameter elements: The string titles to display on the elements within the radio group
	/// - Returns: self
	@discardableResult
	func items(_ elements: Bind<[String]>) -> Self {
		elements.register(self) { @MainActor [weak self] newElements in
			guard let `self` = self else { return }
			assert(Thread.isMainThread)
			self.removeAllItems()
			newElements.forEach { title in
				self.item(title: title)
			}
			self.needsUpdateConstraints = true
			self.needsLayout = true
		}

		self.removeAllItems()
		elements.wrappedValue.forEach { title in
			self.item(title: title)
		}

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
			self?.allButtons.forEach { $0.button?.isEnabled = isEnabled }
		}
		self.allButtons.forEach { $0.button?.isEnabled = isEnabled.wrappedValue }
		return self
	}
}

// MARK: - Utilities

private extension AUIRadioGroup {

	@objc func selectionDidChange(_ sender: NSButton) {
		self.selectItem(sender.tag)
	}

	/// All the current radio button titles
	var allTitles: [String] {
		self.allButtons.map { $0.title }
	}

	// The currently selected index
	var selectedIndex: Int {
		self.allButtons.firstIndex(where: { $0.button?.state == .on }) ?? -1
	}

	func selectItem(_ index: Int) {
		self.allButtons
			.compactMap{ $0.button }
			.forEach {
				$0.state = ($0.tag == index) ? .on : .off
			}
		self.indexBinding?.wrappedValue = index
		self.selectionChanged?(index)
	}

	func removeAllItems() {
		let view = self.arrangedSubviews
		view.forEach { self.removeArrangedSubview($0) }
		view.forEach { $0.removeFromSuperview() }
		self.allButtons.removeAll()
	}
}

// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("default", traits: .fixedLayout(width: 500, height: 800)) {
	let selectedIndex = Bind(2)
	let isEnabled = Bind(false)
	let selectedIndex2 = Bind(1)

	let randomItems = [
		"Automatic prominence while speaking", 
		"FaceTime Live Photos",
		"Live Captions",
		"Silence Unknown Callers",
		"Call Filtering"
	]
	let randomElements = Bind<[String]>(randomItems.shuffled())

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
				.item(
					title: "Show reduction of big quakes",
					description: "This is a test of the description field for a radio button. It shows that description fields can be added to a radio button."
				)
				.item(
					title: "Lots of things that are great by never mentioned"
				)
				.item(title: "Big Sur")
				.selectedIndex(selectedIndex2)
				.compressionResistance(.defaultLow)
				.huggingResistance(.init(1))

			HDivider()

			VStack {
				NSButton.radioGroup()
					.items(randomElements)
					.compressionResistance(.defaultLow)
					.huggingResistance(.init(1))
				NSButton(title: "Reset order") { _ in
					randomElements.wrappedValue = randomItems.shuffled()
				}
			}
		}
		.padding()
	}
	.padding(top: 38, left: 20, bottom: 20, right: 20)
	//.debugFrames()
}

#endif
