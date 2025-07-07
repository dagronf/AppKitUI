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

import AppKit.NSStepper

@MainActor
public extension NSStepper {

	@MainActor convenience init(
		initialValue: Double = 20,
		range: ClosedRange<Double> = 0 ... 100,
		increment: Double = 1
	) {
		self.init()
		self.minValue = range.lowerBound
		self.maxValue = range.upperBound
		self.increment = increment
		self.doubleValue = initialValue
	}

	@MainActor convenience init(
		value: Bind<Double>,
		range: ClosedRange<Double> = 0 ... 100,
		increment: Double = 1
	) {
		self.init()
		self.minValue = range.lowerBound
		self.maxValue = range.upperBound
		self.increment = increment

		self.value(value)
	}
}

// MARK: - Methods

@MainActor
public extension NSStepper {
	/// Set the stepper value
	/// - Parameter value: The value
	/// - Returns: self
	@MainActor
	@discardableResult @inlinable
	func value(_ value: Double) -> Self {
		self.doubleValue = value
		return self
	}

	/// Set how the control responds to mouse events
	/// - Parameter value: If true performs autorepeating when the mouse is down
	/// - Returns: self
	@MainActor
	@discardableResult @inlinable
	func autorepeat(_ value: Bool) -> Self {
		self.autorepeat = value
		return self
	}

	/// Set whether the stepper wraps around the minimum and maximum values
	/// - Parameter value: If true, perform wrapping
	/// - Returns: self
	@MainActor
	@discardableResult @inlinable
	func valueWraps(_ value: Bool) -> Self {
		self.valueWraps = value
		return self
	}
}

// MARK: - Actions

public extension NSStepper {
	/// Supply a block to be called when the value changes
	/// - Parameter block: The block to call
	/// - Returns: self
	@MainActor
	@discardableResult
	func onChange(_ block: @escaping (Double) -> Void) -> Self {
		self.usingStepperStorage {
			$0.onChange = block
		}
		return self
	}
}

// MARK: - Bindings

public extension NSStepper {
	/// Bind the value
	/// - Parameter value: The stepper value
	/// - Returns: self
	@MainActor
	@discardableResult
	func value(_ value: Bind<Double>) -> Self {
		value.register(self) { @MainActor [weak self, weak value] newValue in
			guard let `self` = self, newValue != self.doubleValue else {
				return
			}

			let clamped = max(self.minValue, min(self.maxValue, newValue))

			if clamped != newValue {
				// The control has clamped the value -- we need to reflect that clamp
				DispatchQueue.main.async {
					value?.wrappedValue = clamped
				}
			}
			else {
				self.doubleValue = newValue
			}
		}

		self.usingStepperStorage { $0.value = value }

		self.doubleValue = value.wrappedValue
		return self
	}
}

// MARK: Storage

private extension NSStepper {
	@MainActor
	class Storage {
		weak var control: NSStepper?
		var value: Bind<Double>?
		var onChange: ((Double) -> Void)?

		init(_ control: NSStepper) {
			control.target = self
			control.action = #selector(actionCalled(_:))
			self.control = control
		}

		@objc func actionCalled(_ sender: NSStepper) {
			self.value?.wrappedValue = sender.doubleValue
			self.onChange?(sender.doubleValue)
		}
	}

	@MainActor
	func usingStepperStorage(_ block: @escaping (Storage) -> Void) {
		self.usingAssociatedValue(key: "__nsstepperbond", initialValue: { Storage(self) }, block)
	}
}


// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("default") {
	let value = Bind<Double>(20)
	VStack {
		HStack(spacing: 2) {
			NSTextField(label: "My groovy stepper:")
			NSTextField(value: value, formatter: NumberFormatter())
				.alignment(.right)
				.width(50)
				.onChange { newText in
					Swift.print("NSTextField -> \(newText)")
				}
			NSStepper(value: value, range: 0 ... 100, increment: 1)
				.onChange {
					Swift.print("NSStepper -> \($0)")
				}
		}
	}
	.padding()
}

#endif
