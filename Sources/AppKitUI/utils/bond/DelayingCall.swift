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

/// Delay types
public enum DelayingCallType {
	/// No delay
	case none
	/// Debounce a call.
	case debounce(TimeInterval)
	/// Throttle a call
	case throttle(TimeInterval)
}

// MARK: - Delaying call

class DelayingCall {
	init(_ type: DelayingCallType) {
		self.type = type
		switch type {
		case .none:
			self.debounce = nil
			self.throttle = nil
		case .debounce(let timeInterval):
			self.debounce = Debounce(delay: timeInterval, queue: .main)
			self.throttle = nil
		case .throttle(let timeInterval):
			self.throttle = Throttle(delay: timeInterval, queue: .main)
			self.debounce = nil
		}
	}

	deinit {
		Swift.print("deinit: DelayingCall")
	}

	func perform(action: @escaping (() -> Void)) {
		switch self.type {
		case .none:
			action()
		case .debounce(let timeInterval):
			self.debounce!.debounce(action: action)
		case .throttle(let timeInterval):
			self.throttle!.throttle(action: action)
		}
	}

	private let type: DelayingCallType
	private let debounce: Debounce?
	private let throttle: Throttle?
}

// A class which throttles calls to its perform: action
class Throttle {
	/// Create a throttler
	/// - Parameters:
	///   - delay: The time to wait between action invocations
	///   - queue: The queue to run the action on
	init(delay: TimeInterval, queue: DispatchQueue = .main) {
		self.delay = delay
		self.queue = queue
	}

	deinit {
		self.workItem?.cancel()
	}

	/// Throttle an action
	/// - Parameter action: The action
	func throttle(action: @escaping (() -> Void)) {
		do {
			// Make sure that this can only be once at a time
			self.lock.wait()
			defer { self.lock.signal() }

			let now = Date()

			if let lastExecution = self.lastExecutionTime {
				let timeSinceLastExecution = now.timeIntervalSince(lastExecution)

				if timeSinceLastExecution < self.delay {
					// If we haven't waited long enough, schedule the action
					self.workItem?.cancel()

					let workItem = DispatchWorkItem { [weak self] in
						self?.lastExecutionTime = Date()
						action()
					}
					self.workItem = workItem

					self.queue.asyncAfter(
						deadline: .now() + (self.delay - timeSinceLastExecution),
						execute: workItem
					)
					return
				}
			}

			// Either first execution or enough time has passed
			self.lastExecutionTime = now
		}

		// Perform the action
		action()
	}

	// MARK: - Properties

	private let delay: TimeInterval
	private var workItem: DispatchWorkItem?
	private let queue: DispatchQueue
	private var lastExecutionTime: Date?

	private let lock = DispatchSemaphore(value: 1)
}

// A class which debounces calls to its perform: action
class Debounce {
	/// Create a debouncer
	/// - Parameters:
	///   - delay: The time to wait before performing an action
	///   - queue: The queue to run the action on
	init(delay: TimeInterval, queue: DispatchQueue = .main) {
		self.delay = delay
		self.queue = queue
	}

	deinit {
		self.workItem?.cancel()
	}

	/// Debounce an action
	/// - Parameter action: The action
	func debounce(action: @escaping (() -> Void)) {
		self.workItem?.cancel()

		let wi = DispatchWorkItem(block: { action() })
		self.workItem = wi
		self.queue.asyncAfter(deadline: .now() + self.delay, execute: wi)
	}

	// MARK: - Properties

	private let queue: DispatchQueue
	private var workItem: DispatchWorkItem?
	private var delay: TimeInterval
}
