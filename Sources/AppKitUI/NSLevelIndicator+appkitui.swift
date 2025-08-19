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
import os.log

@MainActor
public extension NSLevelIndicator {
	/// Create a level indicator
	/// - Parameters:
	///   - style: The indicator style
	///   - value: The value binding
	///   - range: The range of values
	convenience init(
		style: NSLevelIndicator.Style,
		value: Bind<Double>,
		range: ClosedRange<Double> = 0 ... 100
	) {
		self.init()

		self.levelIndicatorStyle = style
		self.minValue = range.lowerBound
		self.maxValue = range.upperBound

		value.register(self) { @MainActor [weak self] newValue in
			if self?.doubleValue != newValue {
				self?.doubleValue = newValue
			}
		}
		self.usingLevelIndicatorStorage { $0.value = value }

		self.doubleValue = value.wrappedValue
	}
}

// MARK: - Modifiers

@MainActor
public extension NSLevelIndicator {
	/// The warning level value
	@discardableResult @inlinable
	func warningValue(_ value: Double) -> Self {
		self.warningValue = value
		return self
	}

	/// The warning fill color
	@available(macOS 10.13, *)
	@discardableResult @inlinable
	func warningColor(_ value: NSColor?) -> Self {
		self.warningFillColor = value
		return self
	}

	/// The warning value and fill color
	@available(macOS 10.13, *)
	@discardableResult @inlinable
	func warning(_ value: Double, color: NSColor) -> Self {
		self.warningValue = value
		self.warningFillColor = color
		return self
	}

	/// The critical level value
	@discardableResult @inlinable
	func criticalValue(_ value: Double) -> Self {
		self.criticalValue = value
		return self
	}

	/// The critical fill color
	@available(macOS 10.13, *)
	@discardableResult @inlinable
	func criticalColor(_ value: NSColor?) -> Self {
		self.criticalFillColor = value
		return self
	}

	/// The warning value and fill color
	@available(macOS 10.13, *)
	@discardableResult @inlinable
	func critical(_ value: Double, color: NSColor) -> Self {
		self.criticalValue = value
		self.criticalFillColor = color
		return self
	}

	/// Is the level indicator changeable by the user?
	@available(macOS 10.13, *)
	@discardableResult @inlinable
	func isEditable(_ editable: Bool) -> Self {
		self.isEditable = editable
		return self
	}

	/// Set the level indicator='s fill color
	/// - Parameter color: The color
	/// - Returns: self
	@available(macOS 10.13, *)
	@discardableResult @inlinable
	func fillColor(_ color: NSColor) -> Self {
		self.fillColor = color
		return self
	}

	/// The number of tick marks
	/// - Parameter value: The number of tick marks
	/// - Returns: self
	@discardableResult @inlinable
	func numberOfTickMarks(_ value: Int) -> Self {
		self.numberOfTickMarks = value
		return self
	}

	/// The number of major tick marks
	/// - Parameter value: The number of major tick marks
	/// - Returns: self
	@discardableResult @inlinable
	func numberOfMajorTickMarks(_ value: Int) -> Self {
		self.numberOfMajorTickMarks = value
		return self
	}

	/// Set the ratings image
	/// - Parameter ratingImage: The image
	/// - Returns: self
	@available(macOS 10.13, *)
	@discardableResult @inlinable
	func ratingImage(_ ratingImage: NSImage) -> Self {
		self.ratingImage = ratingImage
		return self
	}
}

// MARK: - Storage

@MainActor
internal extension NSLevelIndicator {
	@MainActor
	class Storage: @unchecked Sendable {
		private weak var parent: NSLevelIndicator?
		private var kvo: NSKeyValueObservation?
		fileprivate var value: Bind<Double>?

		init(_ parent: NSLevelIndicator) {
			self.parent = parent
			self.setupListener()
		}

		deinit {
			os_log("deinit: NSLevelIndicator.Storage", log: logger, type: .debug)
		}

		func setupListener() {
			guard let cell = self.parent?.cell else { fatalError() }
			self.kvo = cell.observe(\.doubleValue, options: [.old, .new]) { [weak self] _, change in
				if let old = change.oldValue, let new = change.newValue, new != old {
					DispatchQueue.main.async {
						self?.valueDidChange(new)
					}
				}
			}
		}

		@MainActor
		func valueDidChange(_ newValue: Double) {
			if let value = self.value, value.wrappedValue != newValue {
				value.wrappedValue = newValue
			}
		}
	}

	@MainActor
	func usingLevelIndicatorStorage(_ block: @escaping (Storage) -> Void) {
		self.usingAssociatedValue(key: "__nslevelindicator_bond", initialValue: { Storage(self) }, block)
	}
}


// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("default") {
	let value1 = Bind(2.0)
	let value2 = Bind(66.0)
	let value3 = Bind(7.0)
	VStack {
		NSLevelIndicator(style: .rating, value: value1, range: 0 ... 5)
			.isEditable(true)
			.width(200)

		NSLevelIndicator(style: .continuousCapacity, value: value2, range: 0 ... 100)
			.isEditable(true)
			.fillColor(.systemGreen)
			.warning(80, color: .systemYellow)
			.critical(90, color: .systemRed)

		NSLevelIndicator(style: .discreteCapacity, value: value3, range: 0 ... 10)
			.isEditable(true)
			.numberOfTickMarks(13)
			.numberOfMajorTickMarks(3)
			.fillColor(.systemGreen)
			.warning(6, color: .systemYellow)
			.critical(9, color: .systemRed)

		NSLevelIndicator(style: .relevancy, value: value2, range: 0 ... 100)
	}
	.onChange(value3) { Swift.print("value3 = \($0)") }
}
#endif
