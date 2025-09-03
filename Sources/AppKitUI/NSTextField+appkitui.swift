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

import AppKit.NSTextField

// MARK: - Label conveniences

@MainActor
public extension NSTextField {
	/// Create a text field label
	/// - Parameter text: The label text
	convenience init(label text: String) {
		self.init()
		self.label()
			.content(text)
	}

	/// Create a text field label
	/// - Parameter text: The label attributed text
	convenience init(label text: NSAttributedString) {
		self.init()
		self.label()
			.content(text)
	}

	/// Create a text field label (not editable)
	/// - Parameter text: The text binding
	convenience init(label text: Bind<String>) {
		self.init()
		self.label()
			.content(text)
	}

	/// Create a text field
	/// - Parameter content: The text binding
	convenience init(content: Bind<String>) {
		self.init()
		self.content(content)
	}

	/// Create a text field label displaying a Double value
	/// - Parameters:
	///   - value: The Double value
	///   - formatter: The formatter to use when displaying/validating the text
	convenience init(value: Bind<Double>, formatter: Formatter) {
		self.init()
		self
			.content(value, formatter: formatter)
			.updateOnEndEditingOnly(true)
	}
}

@MainActor
public extension NSTextField {
	/// Create a text field containing a link
	/// - Parameters:
	///   - url: The link URL
	///   - title: The text for the link
	convenience init(link url: URL, title: String? = nil) {
		self.init()
		self.link(url: url, title: title)
	}
}

@MainActor
private extension NSTextField {
	/// Create a non-editable text field
	@discardableResult
	func label() -> NSTextField {
		self
			.isEditable(false)        // not editable
			.isBezeled(false)         // no border
			.drawsBackground(false)   // transparent background
			.alignment(.natural)      // regular alignment
	}

	/// Crete a text field with a styled and clickable link
	/// - Parameters:
	///   - url: The destination URL
	///   - title: The title to display
	/// - Returns: A non-editable text field containing a link
	@discardableResult
	func link(url: URL, title: String? = nil) -> NSTextField {
		let text = NSAttributedString(string: title ?? url.absoluteString, attributes: [
			.link: url,
			.underlineStyle: NSUnderlineStyle.single.rawValue
		])
		return self.label()
			.isSelectable(true)
			.allowsEditingTextAttributes(true)
			.content(text)
	}
}

// MARK: - Modifiers

@MainActor
public extension NSTextField {
	/// Set the content for the text field
	/// - Parameter str: The string
	/// - Returns: self
	@discardableResult @inlinable
	func content(_ str: String) -> Self {
		self.stringValue = str
		return self
	}

	/// Set the content for the text field
	/// - Parameter str: The attributed string
	/// - Returns: self
	@discardableResult @inlinable
	func content(_ str: NSAttributedString) -> Self {
		self.attributedStringValue = str
		return self
	}

	/// Set the placeholder text for the text field
	/// - Parameter str: The string
	/// - Returns: self
	@discardableResult @inlinable
	func placeholder(_ str: String) -> Self {
		self.placeholderString = str
		return self
	}

	/// Set the placeholder text for the text field
	/// - Parameter str: The string
	/// - Returns: self
	@discardableResult @inlinable
	func placeholder(_ str: NSAttributedString) -> Self {
		self.placeholderAttributedString = str
		return self
	}

	/// Set the text foreground color
	/// - Parameter color: The color
	/// - Returns: self
	@discardableResult @inlinable
	func textColor(_ color: NSColor) -> Self {
		self.textColor = color
		return self
	}

	/// Set the text background color
	/// - Parameter color: The color
	/// - Returns: self
	@discardableResult @inlinable
	func backgroundColor(_ color: NSColor) -> Self {
		self.backgroundColor = color
		return self
	}

	/// A Boolean value that determines whether the user can select the content of the text field.
	@discardableResult @inlinable
	func isSelectable(_ s: Bool) -> Self {
		self.isSelectable = s
		return self
	}

	/// A Boolean value that controls whether the text field draws a bezeled background around its contents.
	@discardableResult @inlinable
	func isBezeled(_ s: Bool) -> Self {
		self.isBezeled = s
		return self
	}

	/// A Boolean value that controls whether the text field draws a solid black border around its contents.
	@discardableResult @inlinable
	func isBordered(_ s: Bool) -> Self {
		self.isBordered = s
		return self
	}

	/// Set whether the label wraps text whose length that exceeds the label's frame.
	@discardableResult @inlinable
	func wraps(_ wraps: Bool) -> Self {
		self.cell?.wraps = wraps
		return self
	}

	/// The alignment mode of the text in the receiver’s cell.
	@discardableResult @inlinable
	func alignment(_ alignment: NSTextAlignment) -> Self {
		self.alignment = alignment
		return self
	}

	/// The line break mode to use when drawing text in the cell.
	@discardableResult @inlinable
	func lineBreakMode(_ mode: NSLineBreakMode) -> Self {
		self.cell?.lineBreakMode = mode
		return self
	}

	/// A Boolean value that controls whether single-line text fields tighten intercharacter spacing before truncating the text.
	@discardableResult @inlinable
	func allowsDefaultTighteningForTruncation(_ allow: Bool) -> Self {
		self.allowsDefaultTighteningForTruncation = allow
		return self
	}

	/// Set whether the label truncates text that does not fit within the label's bounds.
	@discardableResult @inlinable
	func truncatesLastVisibleLine(_ truncates: Bool) -> Self {
		self.cell?.truncatesLastVisibleLine = truncates
		return self
	}

	/// Set the maximum number of lines to display in a multiline text field
	@discardableResult @inlinable
	func maximumNumberOfLines(_ lineCount: Int) -> Self {
		if lineCount > 0 {
			self.maximumNumberOfLines = lineCount
		}
		return self
	}

	/// Set the bezel style for the text field
	/// - Parameter style: The style
	/// - Returns: self
	@discardableResult @inlinable
	func bezelStyle(_ style: NSTextField.BezelStyle) -> Self {
		if let cell = self.cell as? NSTextFieldCell {
			cell.bezelStyle = style
		}
		return self
	}

	/// Set a rounded bezel for the text field
	@discardableResult @inlinable
	func roundedBezel() -> Self {
		self.bezelStyle(.roundedBezel)
	}

	/// A Boolean value that controls whether the user can edit the value in the text field.
	@discardableResult @inlinable
	func isEditable(_ isEditable: Bool) -> Self {
		self.isEditable = isEditable
		return self
	}

	/// A Boolean value that controls whether the text field’s cell draws a background color behind the text.
	@discardableResult @inlinable
	func drawsBackground(_ drawsBackground: Bool) -> Self {
		self.drawsBackground = drawsBackground
		return self
	}

	/// Set continuous updates from the text field
	@discardableResult @inlinable
	func isContinuous(_ b: Bool) -> Self {
		self.isContinuous = b
		return self
	}

	/// A Boolean value indicating whether excess text scrolls past the label's bounds
	@discardableResult @inlinable
	func isScrollable(_ b: Bool) -> Self {
		self.cell?.isScrollable = b
		return self
	}

	/// A Boolean value that controls whether the user can change font attributes of the text field’s string.
	@discardableResult @inlinable
	func allowsEditingTextAttributes(_ b: Bool) -> Self {
		self.allowsEditingTextAttributes = b
		return self
	}

	func updateOnEndEditingOnly(_ value: Bool) -> Self {
		self.usingTextFieldStorage { $0.updateOnEndEditingOnly = value }
		return self
	}
}

// MARK: - Bindings

@MainActor
public extension NSTextField {
	/// Bind the string content
	/// - Parameter str: The string binder
	/// - Returns: self
	@discardableResult
	func content(_ str: Bind<String>) -> Self {
		// Register for changes to the binding
		str.register(self) { @MainActor [weak self] newValue in
			if self?.stringValue != newValue {
				self?.stringValue = newValue
			}
		}

		self.usingTextFieldStorage { $0.stringValue = str }

		self.stringValue = str.wrappedValue

		return self
	}

	internal func reflect() {
		self.usingTextFieldStorage { $0.stringValue?.wrappedValue = self.stringValue }
	}

	/// Bind double content
	/// - Parameters:
	///   - value: The value binder
	///   - formatter: The formatter to use when displaying/validating the text
	/// - Returns: self
	@discardableResult
	func content(_ value: Bind<Double>, formatter: Formatter) -> Self {
		// Register for changes to the binding
		value.register(self) { @MainActor [weak self] newValue in
			guard let `self` = self else { return }
			if self.doubleValue != newValue {
				self.doubleValue = newValue

				self.usingTextFieldStorage {
					$0.onChange?(self.stringValue)
				}

			}
		}
		self.formatter = formatter
		self.usingTextFieldStorage { $0.doubleValue = value }
		self.doubleValue = value.wrappedValue

		return self
	}

	/// Bind the text (foreground) color
	/// - Parameter color: The binding
	/// - Returns: self
	@discardableResult @inlinable
	func textColor(_ color: Bind<NSColor>) -> Self {
		color.register(self) { @MainActor [weak self] newValue in
			if self?.textColor != newValue {
				self?.textColor = newValue
			}
		}
		self.textColor = color.wrappedValue
		return self
	}

	/// Bind the background color
	/// - Parameter color: The binding
	/// - Returns: self
	@discardableResult @inlinable
	func backgroundColor(_ color: Bind<NSColor>) -> Self {
		color.register(self) { @MainActor [weak self] newValue in
			if self?.backgroundColor != newValue {
				self?.backgroundColor = newValue
			}
		}
		self.backgroundColor = color.wrappedValue
		return self
	}

	/// Bind to the control to indicate whether the text field has text
	/// - Parameter hasText: The binding
	/// - Returns: self
	@discardableResult
	func hasText(_ hasText: Bind<Bool>) -> Self {
		self.usingTextFieldStorage { $0.hasText = hasText }
		return self
	}

	/// Bind the editable state
	/// - Parameter isEditable: The state binding
	/// - Returns: self
	@discardableResult
	func isEditable(_ isEditable: Bind<Bool>) -> Self {
		isEditable.register(self) { @MainActor [weak self] newValue in
			if self?.isEditable != newValue {
				self?.isEditable = newValue
			}
		}
		self.isEditable = isEditable.wrappedValue
		return self
	}

	/// Bind the selectable state for the text field
	/// - Parameter isSelectable: The state binding
	/// - Returns: self
	@discardableResult
	func isSelectable(_ isSelectable: Bind<Bool>) -> Self {
		isSelectable.register(self) { @MainActor [weak self] newValue in
			if self?.isSelectable != newValue {
				self?.isSelectable = newValue
			}
		}
		self.isSelectable = isSelectable.wrappedValue
		return self
	}
}

// MARK: Actions

@MainActor
public extension NSTextField {
	/// A callback for when content changes
	/// - Parameter block: The block to call with the new value
	/// - Returns: self
	@discardableResult
	func onChange(_ block: @escaping (String) -> Void) -> Self {
		self.usingTextFieldStorage { storage in
			storage.onChange = block
		}
		return self
	}

	/// A callback for when the field starts editing.
	/// - Parameter block: The block to call with the new value
	/// - Returns: self
	///
	/// The value in the callback block is the value BEFORE the change
	@discardableResult
	func onBeginEditing(_ block: @escaping (String) -> Void) -> Self {
		self.usingTextFieldStorage { $0.onBeginEditing = block }
		return self
	}

	/// A callback for when the field becomes focused
	/// - Parameter block: The block to call with the new value
	/// - Returns: self
	@discardableResult
	func onEndEditing(_ block: @escaping (String) -> Void) -> Self {
		self.usingTextFieldStorage { storage in
			storage.onEndEditing = block
		}
		return self
	}
}

// MARK: - Private

@MainActor
fileprivate extension NSTextField {
	func usingTextFieldStorage(_ block: @escaping (TextFieldStorage) -> Void) {
		self.usingAssociatedValue(key: "__nstextfield_bond", initialValue: { TextFieldStorage(self) }, block)
	}

	enum ChangeType {
		case onChange
		case onBegin
		case onEnd
	}

	@MainActor
	class TextFieldStorage: NSObject, NSTextFieldDelegate, @unchecked Sendable {

		weak var control: NSTextField?

		var stringValue: Bind<String>?
		var hasText: Bind<Bool>?
		var doubleValue: Bind<Double>?

		var onChange: ((String) -> Void)?
		var onBeginEditing: ((String) -> Void)?
		var onEndEditing: ((String) -> Void)?

		var updateOnEndEditingOnly = false

		init(_ control: NSTextField) {
			self.control = control
			super.init()
			control.delegate = self
		}

		func controlTextDidBeginEditing(_ obj: Notification) {
			guard let current = self.control?.stringValue else {
				return
			}
			self.onBeginEditing?(current)
		}

		func controlTextDidChange(_ obj: Notification) {
			guard let current = self.control?.stringValue else {
				return
			}
			if !self.updateOnEndEditingOnly {
				self.reflectUpdatedText(current)
			}
		}

		func controlTextDidEndEditing(_ obj: Notification) {
			guard let current = self.control?.stringValue else {
				return
			}
			self.onEndEditing?(current)

			if updateOnEndEditingOnly {
				self.reflectUpdatedText(current)
			}
		}

		private func reflectUpdatedText(_ value: String) {
			guard let ctrl = self.control else { return }
			self.stringValue?.wrappedValue = value
			self.hasText?.wrappedValue = value.count > 0
			self.onChange?(value)
			self.doubleValue?.wrappedValue = ctrl.doubleValue
		}
	}
}

// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("default") {
	let text = Bind("Label 1")
	let password = Bind("")
	let doubleValue = Bind(20.0)
	VStack {
		VStack(spacing: 0) {
			NSTextField(label: text)
				.isSelectable(true)
			HStack {
				NSTextField()
					.content(text)
					.alignment(.center)
					.width(200)
					.onBeginEditing { value in
						Swift.print("onBeginEditing: \(value)")
					}
					.onChange { value in
						Swift.print("onChange: \(value)")
					}
					.onEndEditing { value in
						Swift.print("onEndEditing: \(value)")
					}
				NSButton(title: "Reset")
					.onAction { _ in text.wrappedValue = "Label 1" }
			}
			NSTextField(label: "Label 2")
				.font(.systemFont(ofSize: 18, weight: .medium))
				.textColor(.brown)
			NSSecureTextField(content: password)
				.bezelStyle(.roundedBezel)
				.onChange { Swift.print("password is '\($0)'") }
				.frame(width: 100)

			NSTextField(value: doubleValue, formatter: NumberFormatter {
				$0.minimumFractionDigits = 0
				$0.maximumFractionDigits = 8
			})

			NSTextField(string: "Fish and chips")
				.width(200)
				.onChange { value in
					Swift.print("onChange: \(value)")
				}
		}
		.onChange(text) { newValue in
			Swift.print("onChange detected -> '\(newValue)'")
		}

		VStack {
			for i in 0 ... 4 {
				NSTextField(label: "Label \(i)")
			}
		}
	}
}





#endif
