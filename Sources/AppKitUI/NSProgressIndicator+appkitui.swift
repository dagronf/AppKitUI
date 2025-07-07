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

import AppKit.NSProgressIndicator

@MainActor
public extension NSProgressIndicator {
	/// The style for the progress indicator
	/// - Parameter style: The style
	/// - Returns: self
	@discardableResult @inlinable
	func style(_ style: NSProgressIndicator.Style) -> Self {
		self.style = style
		return self
	}

	/// Is the progress indicator integerminite
	/// - Parameter value: Indeterminite state
	/// - Returns: self
	@discardableResult @inlinable
	func isIndeterminite(_ value: Bool) -> Self {
		self.isIndeterminate = value
		return self
	}

	/// The minimum and maximum values the progress indicator can send to its target.
	@discardableResult @inlinable
	func range(_ range: ClosedRange<Double>) -> Self {
		self.minValue = range.lowerBound
		self.maxValue = range.upperBound
		return self
	}

	/// The value of the receiver’s cell as a double-precision floating-point number
	@discardableResult @inlinable
	func value(_ value: Double) -> Self {
		self.doubleValue = value
		return self
	}

	/// The value of the receiver’s cell as a double-precision floating-point number
	@discardableResult @inlinable
	func usesThreadedAnimation(_ value: Bool) -> Self {
		self.usesThreadedAnimation = value
		return self
	}
}


// MARK: - Bindings

@MainActor
public extension NSProgressIndicator {
	/// Bind the current value for the progress
	/// - Parameter value: The value binding
	/// - Returns: self
	func value(_ value: Bind<Double>) -> Self {
		value.register(self) { @MainActor [weak self] newValue in
			guard let `self` = self else { return }
			if self.doubleValue != newValue {
				self.doubleValue = newValue
			}
		}
		self.doubleValue = value.wrappedValue
		return self
	}

	/// Bind the controls 'animating' value
	/// - Parameter value: The binding
	/// - Returns: self
	func isAnimating(_ value: Bind<Bool>) -> Self {
		value.register(self) { @MainActor [weak self] newState in
			guard let `self` = self else { return }
			newState ? self.startAnimation(self) : self.stopAnimation(self)
		}
		value.wrappedValue ? self.startAnimation(self) : self.stopAnimation(self)
		return self
	}

	/// A Boolean that indicates whether the progress indicator is indeterminate.
	/// - Parameter value: the binding
	/// - Returns: self
	func isIndeterminite(_ value: Bind<Bool>) -> Self {
		value.register(self) { @MainActor [weak self] newState in
			self?.isIndeterminate = newState
		}
		self.isIndeterminate = value.wrappedValue
		return self
	}
}

// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("default") {
	let animating = Bind<Bool>(false)
	let value = Bind(66.0)
	VStack {
		HStack {
			NSProgressIndicator()
				.range(0 ... 100)
				.value(value)
				.isIndeterminite(false)
				.width(150)
			NSProgressIndicator()
				.style(.spinning)
				.isIndeterminite(false)
				.range(0 ... 100)
				.value(value)
			NSButton()
				.onAction { _ in
					value.wrappedValue = Double.random(in: 0 ... 100)
				}
		}

		HStack {
			NSProgressIndicator()
				.isAnimating(animating)
				.width(150)
			NSProgressIndicator()
				.style(.spinning)
				.isAnimating(animating)
			NSButton()
				.onAction { _ in
					animating.toggle()
				}
		}
	}
}
#endif
