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

import AppKit.NSSwitch
import os.log

// If you need support for older versions of macOS, use AUISwitch instead

@available(macOS 10.15, *)
@MainActor
public extension NSSwitch {
	/// Set the state for the control
	/// - Parameter state: The new state
	/// - Returns: self
	@discardableResult @inlinable
	func state(_ state: NSControl.StateValue) -> Self {
		self.state = state
		return self
	}

	/// Set the on/off state for the control
	/// - Parameter state: The new state
	/// - Returns: self
	@discardableResult @inlinable
	func state(_ state: Bool) -> Self {
		self.state = state ? .on : .off
		return self
	}
}

// MARK: - Bindings

@available(macOS 10.15, *)
@MainActor
public extension NSSwitch {
	@discardableResult
	func state(_ state: Bind<NSControl.StateValue>) -> Self {
		state.register(self) { @MainActor [weak self] newValue in
			if newValue != self?.state {
				self?.state = newValue
			}
		}
		self.state = state.wrappedValue

		self.usingSwitchStorage { h in
			h.state = state
		}

		return self
	}

	@discardableResult
	func state(_ state: Bind<Bool>) -> Self {
		state.register(self) { @MainActor [weak self] newValue in
			self?.state = newValue ? .on : .off
		}
		self.state = state.wrappedValue ? NSControl.StateValue.on : NSControl.StateValue.off

		self.usingSwitchStorage { h in
			h.onOffState = state
		}

		return self
	}
}

@available(macOS 10.15, *)
private extension NSSwitch {
	@MainActor class Storage {
		var onOffState: Bind<Bool>?
		var state: Bind<NSControl.StateValue>?
		var action: ((NSControl.StateValue) -> Void)?

		init(_ control: NSSwitch) {
			control.target = self
			control.action = #selector(actionCalled(_:))
		}

		deinit {
			os_log("deinit: NSSwitch.Storage", log: logger, type: .debug)
		}

		@objc func actionCalled(_ sender: NSSwitch) {
			self.state?.wrappedValue = sender.state
			self.onOffState?.wrappedValue = sender.state == .on
			self.action?(sender.state)
		}
	}

	func usingSwitchStorage(_ block: @escaping (Storage) -> Void) {
		self.usingAssociatedValue(key: "__nsswitchbond", initialValue: { Storage(self) }, block)
	}
}

// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("default") {
	let state = Bind<NSControl.StateValue>(.off)
	let isEnabled = Bind(true)
	VStack {
		NSSwitch()
			.state(state)
		HStack {
			NSSwitch()
				.state(state)
				.isEnabled(isEnabled)
			AUICheckbox(title: "enabled")
				.state(isEnabled)
		}
	}
}

#endif
