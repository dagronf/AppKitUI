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

/// Methods for storing arbitrary values within an NSView
///
/// Useful for items like `NSStackView` where you can specify a gravity value when you add the
/// item to the stack.
///
/// For example: -
///
/// ```swift
/// HStack {
///    NSButton(title: "􀎬 Customer Portal")
///       .isBordered(false)
///       .gravityArea(.leading)  // align leading within the parent stack
///       .onAction { _ in
///           // Do something!
///       }
///
///    NSButton(title: "Online Store 􁽇")
///       .isBordered(false)
///       .gravityArea(.trailing)  // align trailing within the parent stack
///       .onAction { _ in
///           // do something!
///       }
/// }
/// ```

import AppKit
import os.log

private let __arbitraryValuesIdentifier = "AppKitUI.ArbitraryValues"

@MainActor
internal extension NSView {
	/// A class holding a dictionary of arbitrary key-value pairs
	private class Values {
		var allValues = [String: Any]()
		deinit {
			os_log("deinit: NSView.Values", log: logger, type: .debug)
		}
	}

	/// Set an arbitrary value in this view
	/// - Parameters:
	///   - value: The value
	///   - key: The key
	func setArbitraryValue<T: Any>(_ value: T, forKey key: String) {
		let values: NSView.Values = getAssociatedValue(key: __arbitraryValuesIdentifier) ?? NSView.Values()
		values.allValues[key] = value
		self.setAssociatedValue(key: __arbitraryValuesIdentifier, value: values)
	}

	/// Get an arbitrary value from the view
	/// - Parameter key: The value's key
	/// - Returns: The value, or nil if it couldn't be found
	func getArbitraryValue<T: Any>(forKey key: String) -> T? {
		if let values: NSView.Values = getAssociatedValue(key: __arbitraryValuesIdentifier) {
			return values.allValues[key] as? T
		}
		return nil
	}
}
