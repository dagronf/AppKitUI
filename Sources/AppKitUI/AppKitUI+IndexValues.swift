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

/// A representation of multiple index values
public protocol AUIIndexes {
	/// The represented index value(s)
	var auiIndexValues: [Int] { get }
}

extension Int: AUIIndexes {
	/// An Int value represented as index values
	@inlinable public var auiIndexValues: [Int] { [self] }
}

extension Array: AUIIndexes where Element == Int {
	/// An int array represented as index values
	@inlinable public var auiIndexValues: [Int] { self }
}

extension ClosedRange: AUIIndexes where Bound == Int {
	/// An Closed Range int array represented as index values
	@inlinable public var auiIndexValues: [Int] { self.map { $0 } }
}
