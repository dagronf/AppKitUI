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

import AppKit.NSAlert
import os.log

@MainActor
public extension NSAlert {
	/// Create an alert with the specified style
	/// - Parameter style: The alert style
	convenience init(style: NSAlert.Style) {
		self.init()
		self.alertStyle = style
	}
}

// MARK: - Modifiers

@MainActor
public extension NSAlert {
	/// Set the message text for an alert
	/// - Parameter string: The message text
	/// - Returns: self
	@discardableResult @inlinable
	func messageText(_ string: String) -> Self {
		self.messageText = string
		return self
	}

	/// Set the informative text for an alert
	/// - Parameter string: The information text
	/// - Returns: self
	@discardableResult @inlinable
	func informativeText(_ string: String) -> Self {
		self.informativeText = string
		return self
	}

	/// Set the buttons to display on the alert
	/// - Parameter strings: The names of the buttons to display
	/// - Returns: self
	@discardableResult @inlinable
	func buttons(_ strings: [String]) -> Self {
		strings.forEach { self.addButton(withTitle: $0) }
		return self
	}

	/// Set the icon to display for the alert
	/// - Parameter icon: The icon
	/// - Returns: self
	@discardableResult @inlinable
	func icon(_ icon: NSImage?) -> Self {
		if let icon {
			self.icon = icon
		}
		return self
	}

	@discardableResult
	func accessoryView(_ viewBuilder: @escaping () -> NSView) -> Self {
		// Store the builder, so that we rebuild every time the alert is displayed
		self.usingStorage { $0.accessoryViewBuilder = viewBuilder }
		return self
	}
}

// MARK: - Bindings

@MainActor
public extension NSAlert {
	/// Set the suppression state to the specified value
	/// - Parameter value: The value
	/// - Returns: self
	@discardableResult
	func suppressionState(_ value: Bind<Bool>) -> Self {
		self.showsSuppressionButton = true
		value.register(self) { @MainActor [weak self] newValue in
			self?.suppressionButton?.state = newValue ? .on : .off
		}
		self.usingStorage { $0.suppressionState = value }

		// Register the suppression button's state with the binding
		self.suppressionButton?.state(value)
		return self
	}
}

// MARK: - Private

@MainActor
internal extension NSAlert {
	@MainActor
	class Storage {
		var accessoryViewBuilder: (() -> NSView)?
		var suppressionState: Bind<Bool>?
		deinit {
			os_log("deinit: NSAlert.Storage", log: logger, type: .debug)
		}
	}

	@MainActor
	func usingStorage(_ block: @escaping (Storage) -> Void) {
		self.usingAssociatedValue(key: "__nsalert_bond", initialValue: { Storage() }, block)
	}
}
