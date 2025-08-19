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
public extension NSSearchField {
	/// Show a recents menu
	/// - Parameters:
	///   - autosaveName: The name under which the search field automatically archives the list of recent search strings.
	///   - maximumRecents: The maximum number of recents to show in the recents menu
	/// - Returns: self
	@discardableResult
	func showRecents(autosaveName: String, maximumRecents: Int = 10) -> Self {
		self.recentsAutosaveName = autosaveName
		let searchMenu = NSMenu(title: "Recent Searches") {
			NSMenuItem(title: "Recent Searches")
				.tag(NSSearchField.recentsTitleMenuItemTag)
			NSMenuItem(title: "Item")
				.tag(NSSearchField.recentsMenuItemTag)

			NSMenuItem.separator()

			NSMenuItem(title: "Clear Recent Searches")
				.tag(NSSearchField.clearRecentsMenuItemTag)
		}
		self.searchMenuTemplate = searchMenu
		return self
	}

	/// A Boolean value indicating whether the cell calls its search action method when the user clicks the
	/// search button or presses Return, or after each keystroke.
	@discardableResult @inlinable
	func sendsWholeSearchString(_ value: Bool) -> Self {
		self.sendsWholeSearchString = value
		return self
	}

	/// A Boolean value indicating whether the cell calls its action method immediately when an
	/// appropriate action occurs.
	@discardableResult @inlinable
	func sendsSearchStringImmediately(_ value: Bool) -> Self {
		self.sendsSearchStringImmediately = value
		return self
	}
}

// MARK: - Actions

@MainActor
public extension NSSearchField {
	/// A block to call when a search should start
	/// - Parameter block: The block to call
	/// - Returns: self
	@discardableResult
	func onSearch(_ block: @escaping (String) -> Void) -> Self {
		self.usingSearchFieldStorage { $0.onSearch = block }
		return self
	}
}

// MARK: - Storage

@MainActor
private extension NSSearchField {
	func usingSearchFieldStorage(_ block: @escaping (Storage) -> Void) {
		self.usingAssociatedValue(key: "__nssearchfield_bond", initialValue: { Storage(self) }, block)
	}

	@MainActor
	class Storage: NSObject, NSSearchFieldDelegate, @unchecked Sendable {
		weak var control: NSTextField?

		var onSearch: ((String) -> Void)?

		init(_ control: NSSearchField) {
			self.control = control
			super.init()

			control.target = self
			control.action = #selector(performSearch(_:))
		}

		deinit {
			os_log("deinit: NSSearchField.Storage", log: logger, type: .debug)
		}

		@objc func performSearch(_ sender: NSSearchField) {
			self.onSearch?(sender.stringValue)
		}
	}
}


// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("default") {
	let searchText = Bind("")
	let searchText2 = Bind("Original text")
	weak var searchControl: NSSearchField?
	VStack {
		NSSearchField()
			.store(in: &searchControl)
			.content(searchText)
			.sendsSearchStringImmediately(false)
			.placeholder("Start typing")
			.onSearch {
				Swift.print("Performing search -> \($0)...")
			}

		NSSearchField()
			.content(searchText2)
			.showRecents(autosaveName: "second")
			.onSearch { searchText in
				Swift.print("Search submitted -> \(searchText)...")
			}
	}
	.padding()
}

#endif
