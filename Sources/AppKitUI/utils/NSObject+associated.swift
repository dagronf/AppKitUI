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
extension NSObject {
	func getAssociatedValue<T: AnyObject>(key: String) -> T? {
		return objc_getAssociatedObject(self, key.address) as? T
	}

	func setAssociatedValue<T: AnyObject>(key: String, value: T) {
		objc_setAssociatedObject(self, key.address, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
	}

	func usingAssociatedValue<T: AnyObject>(key: String, initialValue: () -> T, _ block: (T) -> Void) {
		let helper: T = self.getAssociatedValue(key: key) ?? initialValue()
		block(helper)
		self.setAssociatedValue(key: key, value: helper)
	}
}

extension String {
	fileprivate var address: UnsafeRawPointer {
		return UnsafeRawPointer(bitPattern: abs(hashValue))!
	}
}
