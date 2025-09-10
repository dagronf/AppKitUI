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

// MARK: - Gesture handling

public extension NSGestureRecognizer {
	/// The buttons required by a gesture recognizer
	struct ButtonMask: OptionSet, Sendable {
		public let rawValue: Int
		public static let primary = ButtonMask(rawValue: 1 << 0)
		public static let secondary = ButtonMask(rawValue: 1 << 1)
		public static let tertiary = ButtonMask(rawValue: 1 << 2)
		public init(rawValue: Int) {
			self.rawValue = rawValue
		}
	}
}

@MainActor
public extension NSView {
	/// Install a click gesture handler for the view
	/// - Parameters:
	///   - numberOfClicksRequired: The number of clicks required to activate the gesture
	///   - buttonMask: The button(s) required to activate the gesture
	///   - onClick: The block to call when a click is registered
	/// - Returns: self
	///
	/// Useful when you want a click on a control that doesn't support an action (eg. an NSView)
	@discardableResult
	func onClickGesture(
		numberOfClicksRequired: Int = 1,
		buttonMask: NSGestureRecognizer.ButtonMask = .primary,
		_ onClick: @escaping () -> Void
	) -> Self {
		let g = NSClickGestureRecognizer(target: self, action: #selector(__aui_handleClickGesture(_:)))
		g.numberOfClicksRequired = numberOfClicksRequired
		g.buttonMask = buttonMask.rawValue
		g.setAssociatedValue(key: "__aui_nsview_clickgesturehandler", value: ClickWrapper(onClick: onClick))
		self.addGestureRecognizer(g)
		return self
	}
}

// MARK: - Private handlers

private extension NSView {
	@objc private func __aui_handleClickGesture(_ sender: NSGestureRecognizer) {
		let click: ClickWrapper? = sender.getAssociatedValue(key: "__aui_nsview_clickgesturehandler")
		click?.onClick()
	}

	private class ClickWrapper {
		init(onClick: @escaping () -> Void) {
			self.onClick = onClick
		}
		let onClick: () -> Void
	}
}
