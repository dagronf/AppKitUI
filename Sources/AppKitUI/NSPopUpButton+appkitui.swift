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

import AppKit.NSPopUpButton

@MainActor
public extension NSPopUpButton {
	/// The style for the popup button
	enum Style {
		/// A pull-down menu
		case pullsDown
		/// A pop-up menu
		case popsUp
	}

	/// Set the popup button style
	/// - Parameter style: The style
	/// - Returns: self
	@discardableResult @inlinable
	func style(_ style: Style) -> Self {
		self.pullsDown = (style == .pullsDown)
		return self
	}

	/// Set the menu item content for the combo box
	/// - Parameter content: The menu items to appear for the combo box
	/// - Returns: self
	@discardableResult
	func menuItems(_ content: [String]) -> Self {
		self.setMenuItems(content)
		return self
	}

	/// Set the menu for the popup button
	/// - Parameter menu: The menu
	/// - Returns: self
	@discardableResult @inlinable
	func menu(_ menu: NSMenu) -> Self {
		self.menu = menu
		return self
	}

	/// Set the menu for the popup button
	/// - Parameters:
	///   - title: The menu title
	///   - builder: The block returning `NSMenuItem`s for the menu
	/// - Returns: self
	@discardableResult
	func menu(title: String = "", @NSMenuItemsBuilder builder: () -> [NSMenuItem]) -> Self {
		self.menu = NSMenu(title: title, builder: builder)
		return self
	}
}

// MARK: - Actions

@MainActor
public extension NSPopUpButton {
	/// Provide a block to call when the popup button selection changes
	/// - Parameter block: The block to call
	/// - Returns: self
	@discardableResult
	func onSelectionChange(_ block: @escaping (Int) -> Void) -> Self {
		self.usingPopUpButtonStorage { $0.action = block }
		return self
	}
}

// MARK: - Binding

@MainActor
public extension NSPopUpButton {
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
	func selectedIndex(_ selected: Bind<Int>) -> Self {
		selected.register(self) { @MainActor [weak self] newSelection in
			self?.selectItem(at: newSelection)
		}

		self.usingPopUpButtonStorage { $0.selectedIndex = selected }
		self.selectItem(at: selected.wrappedValue)

		return self
	}
}

// MARK: - Private

fileprivate extension NSPopUpButton {
	@MainActor
	class Storage {
		weak var parent: NSPopUpButton?
		var action: ((Int) -> Void)?
		var selectedIndex: Bind<Int>?

		init(_ parent: NSPopUpButton) {
			self.parent = parent
			parent.target = self
			parent.action = #selector(actionCalled(_:))
		}

		@objc private func actionCalled(_ sender: NSPopUpButton) {
			let selectedIndex = sender.indexOfSelectedItem
			self.selectedIndex?.wrappedValue = selectedIndex
			self.action?(selectedIndex)
		}
	}

	@MainActor
	func usingPopUpButtonStorage(_ block: @escaping (Storage) -> Void) {
		self.usingAssociatedValue(key: "__nspopupbutton_bond", initialValue: { Storage(self) }, block)
	}
}


// MARK: - Utility functions

@MainActor
private extension NSPopUpButton {
	private func setMenuItems(_ content: [String]) {
		self.removeAllItems()
		self.addItems(withTitles: content)
	}
}

// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("default") {
	let items = Bind(["zero", "one", "two", "three", "four", "five"])
	let selection = Bind(2)

	let items2 = Bind(["Animals", "cat", "dog", "catepillar", "platypus", "bunyip"])
	VStack {
		HStack {
			NSPopUpButton()
				.menuItems(items)
				.selectedIndex(selection)
				.onSelectionChange { s in
					Swift.print("popsUp Selection did change to \(s)")
				}

			NSPopUpButton()
				.style(.pullsDown)
				.menuItems(items2)
				.onSelectionChange { s in
					Swift.print("pullsDown Selection did change to \(s)")
				}
		}

// TODO: Fix this - popup button doesnt save when change?

		NSPopUpButton()
			.style(.pullsDown)
			.menu {
				NSMenuItem(title: "Cats and dogs and fish")
				NSMenuItem(title: "Poodles and caterpillars")
				NSMenuItem(title: "Zoomies with a silly cat")
			}
			.onSelectionChange { s in
				Swift.print("pullsDown Selection did change to \(s)")
			}
	}
}

#endif
