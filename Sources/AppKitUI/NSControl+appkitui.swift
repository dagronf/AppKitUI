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
import AppKit.NSControl

@MainActor
public extension NSControl {
	/// Set the tag for the control
	/// - Parameter value: The tag value
	/// - Returns: self
	@discardableResult @inlinable
	func tag(_ value: Int) -> Self {
		self.tag = value
		return self
	}

	/// The size of the control.
	@discardableResult @inlinable
	func isEnabled(_ isEnabled: Bool) -> Self {
		self.isEnabled = isEnabled
		return self
	}

	/// The size of the control.
	@discardableResult
	@objc func controlSize(_ size: NSControl.ControlSize) -> Self {
		self.controlSize = size
		self.invalidateIntrinsicContentSize()
		return self
	}

	/// The font used to draw text in the receiver’s cell.
	/// - Parameter font: The font
	/// - Returns: self
	@discardableResult
	@objc func font(_ font: NSFont) -> Self {
		self.font = font
		return self
	}
}

// MARK: Binding

@MainActor
public extension NSControl {
	/// Bind the enabled state for the control
	@discardableResult
	func isEnabled(_ isEnabled: Bind<Bool>) -> Self {
		isEnabled.register(self) { @MainActor [weak self] newValue in
			self?.isEnabled = newValue
		}
		self.isEnabled = isEnabled.wrappedValue
		return self
	}
}
