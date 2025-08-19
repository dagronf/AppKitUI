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
			self._wrappedValue
		}
		set {
			if self._wrappedValue != newValue {
				self._wrappedValue = newValue
			}
		}
	}

	/// Create a binding
	/// - Parameters:
	///   - value: The initial value for the binding
	///   - delayType: The delay to apply when calling observers, or nil to automatically update observers
	public init(_ value: Wrapped, delayType: DelayingCallType? = nil) {
		self._wrappedValue = value

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
	///   - delayType: The delay to apply when calling observers, or nil to automatically update observers
	///   - block: An initial observation block
	public convenience init(_ value: Wrapped, delayType: DelayingCallType? = nil, _ block: @escaping (Wrapped) -> Void) {
		self.init(value, delayType: delayType)
		self.register(self, block)
	}

	deinit {
		os_log("deinit: %{public}@", log: logger, type:.debug, "\(self)")
	}

	/// Register a callback block when the value changes
	/// - Parameters:
	///   - owner: The owner for the block (usually `self`)
	///   - block: The block to call when the change occurs
	public func register(_ owner: AnyObject, _ block: @escaping (Wrapped) -> Void) {
		self.observers.append(WeakWrapper(owner: owner, callback: block))
	}

	// MARK: Update

	// Reflect our wrapped value to the observers
	private func update() {
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

	private func __update() {
		for w in self.observers {
			if w.owner != nil { w.callback(self.wrappedValue) }
		}
	}

	// MARK: Private

	private let delay: DelayingCall?
	private var observers: [WeakWrapper<Wrapped>] = []
	private var _wrappedValue: Wrapped {
		didSet {
			self.update()
		}
	}
}

// MARK: - Bond conveniences

@MainActor
public extension Bind where Wrapped == Bool {
	/// Toggle the value of the binding
	@inlinable func toggle() {
		self.wrappedValue.toggle()
	}

	/// Return a one-way binding that present the inverse of this value
	/// - Returns: a new binding
	///
	/// Note: any changes in the new binding will NOT reflect back to this binding (one way!)
	@inlinable func inverted() -> Bind<Bool> {
		self.oneWayTransform { $0 == false }
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
