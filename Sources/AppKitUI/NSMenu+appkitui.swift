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

@MainActor
public extension NSMenu {
	/// Create an NSMenu
	/// - Parameters:
	///   - title: The menu title
	///   - items: The menu items
	convenience init(title: String, items: [NSMenuItem]) {
		self.init(title: title)
		items.forEach { item in
			self.addItem(item)
		}
	}

	/// Create an NSMenu
	/// - Parameters:
	///   - builder: The builder for generating the menu items
	convenience init(@NSMenuItemsBuilder builder: () -> [NSMenuItem]) {
		self.init(title: "", items: builder())
	}

	/// Create an NSMenu
	/// - Parameters:
	///   - title: The menu title
	///   - builder: The builder for generating the menu items
	convenience init(title: String, @NSMenuItemsBuilder builder: () -> [NSMenuItem] ) {
		self.init(title: title, items: builder())
	}

	/// Set autoenables menu items
	/// - Parameter autoenablesItems:
	/// - Returns: self
	@discardableResult @inlinable
	func autoenablesItems(_ autoenablesItems: Bool) -> Self {
		self.autoenablesItems = autoenablesItems
		return self
	}
}

@MainActor
public extension NSMenu {
	/// Set a function that is called when this menu will appear
	/// - Parameter block: The block to call
	/// - Returns: self
	func onMenuWillAppear(_ block: @escaping (NSMenu) -> Void) -> Self {
		self.usingMenuStorage { $0.onMenuWillAppearBlock = block }
		return self
	}
}

// MARK: - Private

@MainActor
private extension NSMenu {
	func usingMenuStorage(_ block: @escaping (Storage) -> Void) {
		self.usingAssociatedValue(key: "__nsmenu_bond", initialValue: { Storage(self) }, block)
	}

	@MainActor class Storage: NSObject, NSMenuDelegate {
		var onMenuWillAppearBlock: ((NSMenu) -> Void)?
		init(_ menu: NSMenu) {
			super.init()
			menu.delegate = self
		}

		deinit {
			os_log("deinit: NSMenu.Storage", log: logger, type: .debug)
		}

		func menuWillOpen(_ menu: NSMenu) {
			self.onMenuWillAppearBlock?(menu)
		}
	}
}

// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("default") {
	let selected = Bind(2)
	VStack {
		NSPopUpButton()
			.menu(
				NSMenu(title: "title") {
					NSMenuItem(title: "zero")
						.image(systemSymbolName: "0.circle")
						.onAction { _ in Swift.print("zero") }
					NSMenuItem(title: "one") { _ in Swift.print("one") }
						.image(systemSymbolName: "1.circle")
						.onAction { _ in Swift.print("one") }
						.isEnabled(false)
					NSMenuItem(title: "two")
						.image(systemSymbolName: "2.circle")
						.onAction { _ in Swift.print("two") }
					NSMenuItem(title: "three")
						.image(systemSymbolName: "3.circle")
						.badge(.alerts(count: 2))
						.onAction { _ in Swift.print("three") }
					NSMenuItem(title: "Wheeee!") {
						NSMenuItem(title: "eight")
							.onAction { _ in Swift.print("eight") }
					}
				}
				.onMenuWillAppear { menu in
					Swift.print("Menu will appear")
				}
			)
			.selectedIndex(selected)
	}
}

#endif
