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

/// An Number Text Field <-> NSStepper pair
@MainActor
public class NumberStepperView: NSStackView {
	/// Create a Number Text Field/Stepper pair
	/// - Parameters:
	///   - value: The value for the control
	///   - formatter: The formatter for generating a string representation of the value
	///   - increment: The amount by which the receiver changes with each increment or decrement.
	public init(value: Bind<Double>, formatter: NumberFormatter, increment: Double) {
		self.value = value

		let minValue = formatter.minimum?.doubleValue ?? 0.0
		let maxValue = formatter.maximum?.doubleValue ?? 100.0
		self.range = minValue ... maxValue

		super.init(frame: .zero)
		self.setup(value, formatter, increment)
	}

	public required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	/// A Boolean value that indicates whether the receiver reacts to mouse events.
	public var isEnabled: Bool = true {
		didSet {
			self.textField.isEnabled = self.isEnabled
			self.stepper.isEnabled = self.isEnabled
			self.stepper.needsDisplay = true
		}
	}

	/// The text field’s bezel style, square or rounded.
	public var bezelStyle: NSTextField.BezelStyle {
		get { self.textField.bezelStyle }
		set { self.textField.bezelStyle = newValue }
	}

	/// The text field’s bezel style, square or rounded.
	public var isBezeled: Bool {
		get { self.textField.isBezeled }
		set { self.textField.isBezeled = newValue }
	}

	/// A Boolean value that controls whether the text field’s cell draws a background color behind the text.
	public var drawsBackground: Bool {
		get { self.textField.drawsBackground }
		set { self.textField.drawsBackground = newValue }
	}

	public let textField = NSTextField()
	public let stepper = NSStepper()
	public let value: Bind<Double>
	public let range: ClosedRange<Double>
	private var valueBeforeEditingStarted: Double?
}

@MainActor
public extension NumberStepperView {
	/// Expose the embedded text control
	/// - Parameter exposureBlock: The block, passing a reference to the text field
	/// - Returns: self
	@discardableResult
	public func withEmbeddedTextControl(_ exposureBlock: (NSTextField) -> Void) -> Self {
		exposureBlock(self.textField)
		return self
	}

	/// The text field’s bezel style, square or rounded.
	/// - Returns: self
	@discardableResult @inlinable
	public func bezelStyle(_ value: NSTextField.BezelStyle) -> Self {
		self.bezelStyle = value
		return self
	}

	/// A Boolean value that controls whether the text field draws a bezeled background around its contents.
	@discardableResult @inlinable
	func isBezeled(_ s: Bool) -> Self {
		self.isBezeled = s
		return self
	}

	/// A Boolean value that controls whether the text field’s cell draws a background color behind the text.
	@discardableResult @inlinable
	func drawsBackground(_ s: Bool) -> Self {
		self.drawsBackground = s
		return self
	}

	/// A Boolean value that indicates whether the receiver reacts to mouse events.
	/// - Returns: self
	@discardableResult @inlinable
	public func isEnabled(_ value: Bind<Bool>) -> Self {
		value.register(self) { @MainActor [weak self] newValue in
			self?.isEnabled = newValue
		}
		self.isEnabled = value.wrappedValue
		return self
	}
}


private extension NumberStepperView {
	func setup(_ value: Bind<Double>, _ formatter: NumberFormatter, _ increment: Double) {
		self.translatesAutoresizingMaskIntoConstraints = false
		self.orientation = .horizontal
		self.spacing = 2

		self.textField.translatesAutoresizingMaskIntoConstraints = false
		self.textField.formatter = formatter
		self.textField.alignment = .right
		self.textField.delegate = self

		self.addArrangedSubview(self.textField)

		self.stepper.translatesAutoresizingMaskIntoConstraints = false
		self.stepper.minValue = self.range.lowerBound
		self.stepper.maxValue = self.range.upperBound
		self.stepper.increment = increment

		self.stepper.target = self
		self.stepper.action = #selector(stepperValueChanged(_:))

		self.addArrangedSubview(self.stepper)

		value.register(self) { @MainActor [weak self, weak value] newValue in
			guard let `self` = self else { return }

			let clamped = max(self.range.lowerBound, min(self.range.upperBound, newValue))
			if clamped != newValue {
				value?.wrappedValue = clamped
			}
			else {
				self.textField.doubleValue = newValue
				self.stepper.doubleValue = newValue
			}
		}

		self.textField.doubleValue = value.wrappedValue
		self.stepper.doubleValue = value.wrappedValue
	}
}

@MainActor
extension NumberStepperView: NSTextFieldDelegate {
	@objc private func stepperValueChanged(_ sender: NSStepper) {
		let newValue = sender.doubleValue
		self.textField.doubleValue = newValue
		self.value.wrappedValue = newValue
	}

	public func controlTextDidBeginEditing(_ obj: Notification) {
		self.valueBeforeEditingStarted = self.textField.doubleValue
	}

	public func controlTextDidEndEditing(_ obj: Notification) {
		// Only update the stepper value when the text finishes editing
		let newValue = self.textField.doubleValue
		self.stepper.doubleValue = newValue
		self.value.wrappedValue = newValue
		self.valueBeforeEditingStarted = nil
	}

	// Called when the user presses escape during a text editing session
	public override func cancelOperation(_ sender: Any?) {
		if let v = self.valueBeforeEditingStarted {
			self.textField.abortEditing()
			self.value.wrappedValue = v
		}
	}
}

// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("default") {
	let enabled = Bind(false)

	let nf = NumberFormatter {
		$0.minimum = 0
		$0.maximum = 100
	}
	let value = Bind(20.0) { newValue in
		Swift.print("value is now '\(nf.string(for: newValue))'")
	}

	let nf2 = NumberFormatter {
		$0.minimum = -1
		$0.maximum = 1
		$0.minimumFractionDigits = 0
		$0.maximumFractionDigits = 4
	}
	let nf2Value = Bind(0.5) { newValue in
		Swift.print("nf2Value is now '\(nf2.string(for: newValue))'")
	}

	let nf3 = NumberFormatter {
		$0.minimum = -10
		$0.maximum = 10
		$0.minimumFractionDigits = 3
		$0.maximumFractionDigits = 3
	}
	let nf3Value = Bind(0.0) { newValue in
		Swift.print("nf3Value is now '\(nf3.string(for: newValue))'")
	}

	VStack {
		HStack {
			NumberStepperView(value: value, formatter: nf, increment: 1)
				.width(100)

			NSButton(title: "Reset") { _ in
				value.wrappedValue = 99
			}

			NSTextField(label: "")
				.textColor(.tertiaryLabelColor)
				.font(.systemSmall)
				.width(50)
				.content(value.formattedString(nf))
		}

		HStack {
			NumberStepperView(value: nf2Value, formatter: nf2, increment: 0.05)
				.bezelStyle(.roundedBezel)
			NSButton(title: "Reset") { _ in
				nf2Value.wrappedValue = 200
			}
			NSTextField(label: "")
				.textColor(.tertiaryLabelColor)
				.font(.systemSmall)
				.width(50)
				.content(nf2Value.formattedString(nf2))
		}

		HStack {
			NumberStepperView(value: nf3Value, formatter: nf3, increment: 0.05)
				.isEnabled(enabled)
				.isBezeled(false)
				.drawsBackground(false)
				.spacing(4)
				.withEmbeddedTextControl {
					$0.font(.monospacedDigit.size(24).weight(.medium))
				}
				.debugFrame(.systemYellow)
			NSButton.checkbox(title: "Enable")
				.state(enabled)
		}
	}
	//.debugFrames()
}

#endif
