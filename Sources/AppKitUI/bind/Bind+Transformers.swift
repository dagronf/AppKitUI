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

/// A protocol that defines a two way transform between two value types
public protocol BindTransformer<T1, T2> {
	associatedtype T1: Equatable
	associatedtype T2: Equatable
	func encode(_ value: T1) -> T2
	func decode(_ value: T2) -> T1
}

// MARK: - Defined binding transformers

public class BindTransformers {
	private init() {}
}

public extension BindTransformers {

	// MARK: String to Int and back

	public struct StringToInt: BindTransformer {
		public init(formatter: NumberFormatter) {
			self.formatter = formatter
		}
		public func encode(_ value: String) -> Int {
			self.formatter.number(from: value)?.intValue ?? 0
		}
		public func decode(_ value: Int) -> String {
			self.formatter.string(from: NSNumber(value: value)) ?? "0"
		}
		private let formatter: NumberFormatter
	}

	public struct IntToString: BindTransformer {
		public init(formatter: NumberFormatter) {
			self.formatter = formatter
		}
		public func encode(_ value: Int) -> String {
			self.formatter.string(from: NSNumber(value: value)) ?? "0"
		}
		public func decode(_ value: String) -> Int {
			self.formatter.number(from: value)?.intValue ?? 0
		}
		private let formatter: NumberFormatter
	}

	// MARK: String to Bool and back

	public struct StringToBool: BindTransformer {
		public init() { }
		public func encode(_ value: String) -> Bool { NSString(string: value).boolValue }
		public func decode(_ value: Bool) -> String { value ? "true" : "false" }
	}

	public struct BoolToString: BindTransformer {
		public init() { }
		public func encode(_ value: Bool) -> String { value ? "true" : "false" }
		public func decode(_ value: String) -> Bool { NSString(string: value).boolValue }
	}

	// MARK: Bool to NSControl.StateValue and back

	public struct BoolToState: BindTransformer {
		public init() { }
		public func encode(_ value: Bool) -> NSControl.StateValue { value ? .on : .off }
		public func decode(_ value: NSControl.StateValue) -> Bool { value != .off }
	}

	public struct StateToBool: BindTransformer {
		public init() { }
		public func encode(_ value: NSControl.StateValue) -> Bool { value != .off }
		public func decode(_ value: Bool) -> NSControl.StateValue { value ? .on : .off }
	}

	// MARK: Invert a bool binding

	/// A binding transformer for converting a bool value to the inverse of that value
	public struct BoolInverted: BindTransformer {
		public init() { }
		public func encode(_ value: Bool) -> Bool { !value }
		public func decode(_ value: Bool) -> Bool { !value }
	}
}
