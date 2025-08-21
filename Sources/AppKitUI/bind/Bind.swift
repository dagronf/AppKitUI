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

import Foundation
import os.log

/// A binder to pass/share a value and be notified when the value changes
@MainActor
public class Bind<Wrapped: Equatable> {
	/// The wrapped value
	public var wrappedValue: Wrapped {
		get {
			self.wrappedValue_
		}
		set {
			if self.wrappedValue_ != newValue {
				self.wrappedValue_ = newValue
			}
		}
	}

	/// Create a binding
	/// - Parameters:
	///   - value: The initial value for the binding
	///   - delayType: The delay operation to apply when calling observers, or nil to automatically update observers
	public init(_ value: Wrapped, delayType: DelayingCallType? = nil) {
		self.wrappedValue_ = value

		if let delayType {
			self.delay = DelayingCall(delayType)
		}
		else {
			self.delay = nil
		}
	}

	/// Create a binding
	/// - Parameters:
	///   - value: The initial value for the binding
	///   - delayType: The delay operation to apply when calling observers, or nil to automatically update observers
	///   - block: An initial observation block
	public convenience init(_ value: Wrapped, delayType: DelayingCallType? = nil, _ block: @escaping (Wrapped) -> Void) {
		self.init(value, delayType: delayType)
		self.register(self, block)
	}

	deinit {
		os_log("deinit: %{public}@", log: logger, type:.debug, "\(self)")
	}

	// MARK: Private

	private let delay: DelayingCall?
	private var observers: [WeakWrapper<Wrapped>] = []
	private var wrappedValue_: Wrapped {
		didSet {
			self.update()
		}
	}
}

// MARK: - Register for changes

@MainActor
public extension Bind {
	/// Register a callback block for when the value changes
	/// - Parameters:
	///   - owner: The owner for the block (usually `self`)
	///   - block: The block to call when the change occurs
	func register(_ owner: AnyObject, _ block: @escaping (Wrapped) -> Void) {
		self.observers.append(WeakWrapper(owner: owner, callback: block))
	}
}

// MARK: - Update and notify

@MainActor
private extension Bind {
	// Reflect our wrapped value to the observers
	func update() {
		assert(Thread.isMainThread)
		if let delay {
			// If there is a delay associated with this binding, make sure we use it
			delay.perform { [weak self] in
				self?.__update()
			}
		}
		else {
			self.__update()
		}
	}

	// Reflect the changes immediately
	func __update() {
		assert(Thread.isMainThread)
		for w in self.observers {
			if w.owner != nil { w.callback(self.wrappedValue) }
		}
	}
}


// MARK: - Private

private class WeakWrapper<Wrapped: Equatable> {
	weak var owner: AnyObject?
	let callback: (Wrapped) -> Void
	init(owner: AnyObject? = nil, callback: @escaping (Wrapped) -> Void) {
		self.owner = owner
		self.callback = callback
	}

	deinit {
		os_log("deinit: %{public}@", log: logger, type:.debug, "\(self)")
	}
}

