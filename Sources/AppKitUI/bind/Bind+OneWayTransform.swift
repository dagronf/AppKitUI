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

@MainActor
public extension Bind {
	/// Returns a new value binder which returns a transformed value from this binder
	/// - Parameter block: A block which transforms this binder's value to a new value
	/// - Returns: A new binding
	///
	/// Note that being a one-way binding means that the created binding WILL NOT reflect changed
	/// values back to this binding.
	///
	/// The benefit of a one-way transform is removing the overhead of the second binding observation
	func oneWayTransform<NEWBINDERTYPE>(_ block: @escaping (Wrapped) -> NEWBINDERTYPE) -> Bind<NEWBINDERTYPE> {
		// Grab out the current value of this binder, and transform it using the block
		let initialValue = block(self.wrappedValue)

		// Create the new binding
		let newBinder = Bind<NEWBINDERTYPE>(initialValue)

		// Register for any changes in ourself to reflect to the new binding
		self.register(self) { @MainActor newValue in
			let value = block(newValue)
			newBinder.wrappedValue = value
		}
		return newBinder
	}
}

// MARK: - Bool conveniences

@MainActor
public extension Bind where Wrapped == Bool {
	/// Create a one-way binding that represents the inverse of this binding
	func toggled() -> Bind<Bool> {
		self.oneWayTransform { $0 == false }
	}

	/// Transform a bool state value into a read-only string representation of the state ("on"/"off")
	func stateString() -> Bind<String> {
		self.oneWayTransform { $0 ? "on" : "off" }
	}

	/// Toggle the binding's bool value
	@inlinable func toggle() {
		self.wrappedValue.toggle()
	}
}

@MainActor
public extension Bind where Wrapped == Int64 {
	/// Format a int64 value as a byte value
	/// - Parameters:
	///  - countStyle: Specifies display of file or storage byte counts. The display style is platform specific.
	/// - Returns: A read-only string binding
	func byteFormatted(_ formatter: ByteCountFormatter) -> Bind<String> {
		return self.oneWayTransform {
			return formatter.string(for: $0) ?? ""
		}
	}
}

@MainActor
public extension Bind where Wrapped: ExpressibleByIntegerLiteral {
	/// Transform a number value (eg. Int, Double etc) into a string using a formatter
	func formattedString(_ formatter: NumberFormatter) -> Bind<String> {
		self.oneWayTransform { formatter.string(for: $0) ?? "" }
	}
}


@MainActor
public extension Bind where Wrapped == [String] {
	/// Toggle the value of the binding
	@inlinable
	func stringValue() -> Bind<String> {
		self.oneWayTransform { $0.joined(separator: ", ") }
	}
}
