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

/// A selector/target pair
class ControlAction {
	init(target: AnyObject? = nil, action: Selector, from: AnyObject? = nil) {
		self.target = target
		self.action = action
		self.from = from
	}

	func perform() {
		if let target = self.target {
			NSApp.sendAction(self.action, to: target, from: self.from)
		}
	}

	private weak var target: AnyObject?  // Held weakly so we don't get a self-referential loop
	private weak var from: AnyObject?
	private let action: Selector
}

/// A window that can become the key window (ie. a window that accepts key and mouse events
class KeyableWindow: NSWindow {
	override var canBecomeKey: Bool { true }
}
