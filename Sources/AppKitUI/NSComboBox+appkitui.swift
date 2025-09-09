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

import AppKit.NSComboBox

@MainActor
public extension NSComboBox {
	/// Set the menu item content for the combo box
	/// - Parameter content: The menu items to appear for the combo box
	/// - Returns: self
	@discardableResult
	func menuItems(_ content: [String]) -> Self {
		self.setMenuItems(content)
		self.usingComboBoxStorage { _ in }
		return self
	}

	/// A Boolean value indicating whether the combo box tries to complete what the user types.
	/// - Parameter value: If true, sets the control to autocomplete
	/// - Returns: self
	@discardableResult @inlinable
	func autocompletes(_ value: Bool) -> Self {
		self.completes = value
		return self
	}

	/// A Boolean value indicating whether the combo box has a vertical scroller.
	/// - Parameter value: If true, displays a vertical scroller when needed
	/// - Returns: self
	@discardableResult @inlinable
	func hasVerticalScroller(_ value: Bool) -> Self {
		self.hasVerticalScroller = true
		return self
	}

	/// A Boolean value indicating whether the combo box displays a border.
	/// - Parameter value: If true, displays a vertical scroller when needed
	/// - Returns: self
	@discardableResult @inlinable
	func isButtonBordered(_ value: Bool) -> Self {
		self.isButtonBordered = true
		return self
	}
}

// MARK: Actions

@MainActor
public extension NSComboBox {
	/// A block to call when the selected menu item changes
	/// - Parameter change: The block to call
	/// - Returns: self
	@discardableResult
	func onSelectionChange(_ change: @escaping (Int?) -> Void) -> Self {
		self.usingComboBoxStorage { $0.onChangeSelection = change }
		return self
	}
}

// MARK: Binding

@MainActor
public extension NSComboBox {
	/// Bind the menu content
	/// - Parameter content: The content binder
	/// - Returns: self
	@discardableResult
	func menuItems(_ content: Bind<[String]>) -> Self {
		content.register(self) { @MainActor [weak self] newContent in
			guard let `self` = self else { return }
			self.setMenuItems(newContent)
		}

		self.setMenuItems(content.wrappedValue)
		return self
	}

	/// Bind the current selection
	/// - Parameter selected: selection index binding
	/// - Returns: self
	@discardableResult
	func selectedItem(_ selected: Bind<Int?>) -> Self {
		selected.register(self) { @MainActor [weak self] newSelection in
			self?.updateSelection(newSelection)
		}

		self.usingComboBoxStorage { $0.selection = selected }
		self.updateSelection(selected.wrappedValue)

		return self
	}
}

// MARK: - Utility functions

@MainActor private extension NSComboBox {
	private func setMenuItems(_ content: [String]) {
		self.removeAllItems()
		self.addItems(withObjectValues: content)
		self.noteNumberOfItemsChanged()
		self.reloadData()
	}

	private func updateSelection(_ selected: Int?) {
		// Deselect any items in the list
		self.deselectAllItems()

		if let selected, selected < self.numberOfItems {
			self.selectItem(at: selected)
			self.objectValue = self.itemObjectValue(at: selected)
		}
	}

	private func deselectAllItems() {
		(0 ..< self.numberOfItems).forEach { index in
			self.deselectItem(at: index)
		}
	}
}

// MARK: - Control storage

@MainActor
private extension NSComboBox {
	func usingComboBoxStorage(_ block: @escaping (ComboBoxStorage) -> Void) {
		self.usingAssociatedValue(key: "__nscombobox_bond", initialValue: { ComboBoxStorage(self) }, block)
	}

	@MainActor
	class ComboBoxStorage: @unchecked Sendable {
		var selection: Bind<Int?>?
		var onChangeSelection: ((Int?) -> Void)?
		var notifications: [NSObjectProtocol] = []
		weak var parent: NSComboBox?

		init(_ control: NSComboBox) {
			self.parent = control
			let didChange = NotificationCenter.default.addObserver(
				forName: NSComboBox.selectionDidChangeNotification,
				object: control,
				queue: .main
			) { [weak self, weak control] _ in
				guard let `control` = control else { return }
				DispatchQueue.main.async { [weak self] in
					self?.performChange(control)
				}
			}
			self.notifications.append(didChange)
		}

		@MainActor
		private func performChange(_ which: NSComboBox) {
			assert(Thread.isMainThread)
			let selected = (which.indexOfSelectedItem == -1) ? nil : which.indexOfSelectedItem
			self.selection?.wrappedValue = selected
			self.onChangeSelection?(selected)

			which.reflect()
		}
	}
}

// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("default") {
	let selectedItem: Bind<Int?> = Bind(2)
	let selectedString: Bind<String> = Bind("two")

	HStack {
		NSComboBox()
			.identifier("1")
			.autocompletes(true)
			.content(selectedString)
			.menuItems(["zero", "one", "two", "three", "four", "five"])
			.selectedItem(selectedItem)
			.onSelectionChange { which in
				Swift.print(which ?? -1)
			}

		NSTextField()
			.identifier("2")
			.content(selectedString)
	}
	.equalWidths(["1", "2"])
	.padding(top: 30, left: 20, bottom: 20, right: 20)
	.debugFrames()
}
#endif
