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

// MARK: - Two way bindings (Bimap)

@MainActor
public extension Bind {
	/// Create a new binding that maps this value via a `BindTransformer` to a new binding (and vice-versa)
	/// - Parameter transformer: The transformer that maps values between the two binding values
	/// - Returns: A new binding
	///
	/// A two-way transformer uses a transformer to map between two value types (eg. an Int and a String)
	/// The two-way transformer is expected to be idempotent
	func twoWayTransform<NEWBINDERTYPE>(_ transformer: BindTransformer<Wrapped, NEWBINDERTYPE>) -> Bind<NEWBINDERTYPE> {
		// Grab out the current value of this binder, and encoding to the the transformed value
		let initialValue = transformer.encode(self.wrappedValue)

		// Create the new binding, and set the initial value to the transformed value
		let newBinder = Bind<NEWBINDERTYPE>(initialValue)

		// Register for any changes in THIS binding, and reflect changes through the encoder to the NEW binding
		//
		// In the case that the BindTransformer doesn't exactly reverse (ie. A -> B and B -> A) we need to make sure we
		// don't re-enter the update block and cause an infinite recursion
		let encodeLock = ReentryChecker()
		self.register(self) { @MainActor newValue in
			encodeLock.tryEnter {
				let value = transformer.encode(newValue)
				if newBinder.wrappedValue != value {
					newBinder.wrappedValue = value
				}
			}
		}

		// Register for changes on the NEW binding, and reflect changes through the decoder to this binding
		//
		// In the case that the BindTransformer doesn't exactly reverse (ie. A -> B and B -> A) we need to make sure we
		// don't re-enter the update block and cause an infinite recursion
		let decodeLock = ReentryChecker()
		newBinder.register(self) { @MainActor [weak self] (newValue: NEWBINDERTYPE) in
			decodeLock.tryEnter {
				let value = transformer.decode(newValue)
				if self?.wrappedValue != value {
					self?.wrappedValue = value
				}
			}
		}

		return newBinder
	}

	/// Reflect the value of this binding to another binding and vice versa (two-way binding)
	/// - Parameter reflector: The binding to reflect
	///
	/// Note: The reflector should be stored somewhere
	func reflect(_ reflector: Bind<Wrapped>) {
		// Register for changes in the reflector, and transfer the value back to this binding
		let backwardReentrantLock = ReentryChecker()
		reflector.register(self) { @MainActor [weak self] newValue in
			backwardReentrantLock.tryEnter {
				if self?.wrappedValue != newValue {
					self?.wrappedValue = newValue
				}
			}
		}

		// Register for changes in THIS binding, and transfer the value to the reflector
		let forwardsReentrantLock = ReentryChecker()
		self.register(reflector) { @MainActor [weak reflector] newValue in
			// Make sure we don't re-enter
			forwardsReentrantLock.tryEnter {
				if reflector?.wrappedValue != newValue {
					reflector?.wrappedValue = newValue
				}
			}
		}

		reflector.wrappedValue = self.wrappedValue
	}
}
