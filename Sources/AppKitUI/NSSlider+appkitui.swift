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

import AppKit.NSSlider
import os.log

@MainActor
public extension NSSlider {
	/// Create a slider
	/// - Parameters:
	///   - value: The value
	///   - range: The available range for the slider
	convenience init(_ value: Bind<Double>, range: ClosedRange<Double>) {
		self.init()
		self
			.value(value)
			.range(range)
	}
}

// MARK: - Modifiers

@MainActor
public extension NSSlider {
	/// The number of tick marks associated with the slider.
	@discardableResult @inlinable
	func numberOfTickMarks(_ count: Int) -> Self {
		self.numberOfTickMarks = count
		return self
	}

	/// The minimum and maximum values the slider can send to its target.
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

	/// Set whether the slider fixes its values to those values represented by its tick marks.
	@discardableResult @inlinable
	func allowsTickMarkValuesOnly(_ stops: Bool) -> Self {
		self.allowsTickMarkValuesOnly = stops
		return self
	}

	/// Set the number of tick marks
	/// - Parameters:
	///   - value: The number of tick marks to display
	///   - allowsTickMarkValuesOnly: Whether to allow tick mark values
	/// - Returns: self
	@discardableResult @inlinable
	func numberOfTickMarks(_ value: Int, allowsTickMarkValuesOnly: Bool = false) -> Self {
		self.numberOfTickMarks = value
		self.allowsTickMarkValuesOnly(allowsTickMarkValuesOnly)
		return self
	}

	/// Set indicating whether the control sends its action message continuously to its target during mouse tracking.
	@discardableResult @inlinable
	func isContinuous(_ continuous: Bool) -> Self {
		self.isContinuous = continuous
		return self
	}

	/// Set indicating whether the control sends its action message continuously to its target during mouse tracking.
	@discardableResult @inlinable
	func trackFillColor(_ color: NSColor) -> Self {
		self.trackFillColor = color
		return self
	}

	/// Determines where the slider’s tick marks are displayed.
	@discardableResult @inlinable
	func tickMarkPosition(_ tickMarkPosition: NSSlider.TickMarkPosition) -> Self {
		self.tickMarkPosition = tickMarkPosition
		return self
	}

	/// Set the orientation for the slider
	@discardableResult @inlinable
	func isVertical(_ isVertical: Bool) -> Self {
		self.isVertical = isVertical
		return self
	}

	/// Set the slider type
	@discardableResult @inlinable
	func sliderType(_ type: NSSlider.SliderType) -> Self {
		self.sliderType = type
		return self
	}
}

// MARK: - Actions

@MainActor
public extension NSSlider {
	@discardableResult
	func onChange(_ block: @escaping (Double) -> Void) -> Self {
		self.usingSliderStorage { storage in
			storage.onChange = block
		}
		return self
	}
}

// MARK: - Bindings

@MainActor
public extension NSSlider {
	/// Bind the slider's value
	/// - Parameter bond: The binder
	/// - Returns: self
	@discardableResult
	func value(_ bond: Bind<Double>) -> Self {
		bond.register(self) { @MainActor [weak self] newValue in
			guard let `self` = self else { return }
			if self.doubleValue != newValue {
				self.doubleValue = newValue
			}
		}
		self.doubleValue = bond.wrappedValue

		self.usingSliderStorage { storage in
			storage.value = bond
		}

		return self
	}
}

// MARK: - Storage

private extension NSSlider {
	@MainActor class Storage {
		var onChange: ((Double) -> Void)?
		var value: Bind<Double>?
		weak var parent: NSSlider?

		init(_ parent: NSSlider) {
			self.parent = parent

			self.parent?.target = self
			self.parent?.action = #selector(onAction(_:))
		}

		deinit {
			os_log("deinit: NSSlider.Storage", log: logger, type: .debug)
		}

		@objc private func onAction(_ sender: NSSlider) {
			self.value?.wrappedValue = sender.doubleValue
			self.onChange?(sender.doubleValue)
		}
	}

	func usingSliderStorage(_ block: @escaping (Storage) -> Void) {
		self.usingAssociatedValue(key: "__nssliderbond", initialValue: { Storage(self) }, block)
	}
}


// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("default") {
	let state = Bind<Double>(0.33)
	VStack {
		NSSlider()
			.value(state)
		NSSlider()
			.value(state)
			.trackFillColor(.systemYellow)
		NSSlider()
			.value(state)
			.numberOfTickMarks(13)
		NSSlider()
			.value(state)
			.numberOfTickMarks(13)
			.allowsTickMarkValuesOnly(true)
	}
	.padding()
}

@available(macOS 14, *)
#Preview("sizing") {
	NSGridView {
		NSGridView.Row {
			NSTextField(label: "large:")
				.controlSize(.large)
			NSSlider()
				.value(0.66)
				.controlSize(.large)
		}

		NSGridView.Row {
			NSTextField(label: "regular:")
				.controlSize(.regular)
			NSSlider()
				.value(0.66)
				.controlSize(.regular)
		}

		NSGridView.Row {
			NSTextField(label: "small:")
				.controlSize(.small)
			NSSlider()
				.value(0.66)
				.controlSize(.small)
		}

		NSGridView.Row {
			NSTextField(label: "mini:")
				.controlSize(.mini)
			NSSlider()
				.value(0.66)
				.controlSize(.mini)
		}
	}
	.rowAlignment(.firstBaseline)
	.columnAlignment(.trailing, forColumn: 0)
	.padding()
}

#endif
