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

@MainActor
open class AUIScrollingTextView: ScrollableTextView {
	/// Create a scrolling text view
	/// - Parameter text: The text
	public init(text: Bind<String>) {
		super.init(frame: .zero)

		text.register(self) { @MainActor [weak self] newText in
			guard let `self` = self else { return }
			if self.textView.string != newText {
				self.textView.string = newText
			}
		}

		self.usingStorage { $0.text = text }

		self.textView.string = text.wrappedValue
		self.textView.isRichText = false
	}

	public init() {
		super.init(frame: .zero)
	}

	required public init?(coder: NSCoder) {
		fatalError()
	}
}

// MARK: - Modifiers

public extension AUIScrollingTextView {
	/// A Boolean that indicates whether the scroll view automatically hides its scroll bars when they are not needed.
	@discardableResult @inlinable
	func autohidesScrollers(_ hides: Bool) -> Self {
		self.scrollView.autohidesScrollers = hides
		return self
	}

	/// Is the text view editable
	@discardableResult @inlinable
	func isEditable(_ editable: Bool) -> Self {
		self.textView.isEditable = editable
		return self
	}

	/// Is the text view selectable?
	@discardableResult @inlinable
	func isSelectable(_ selectable: Bool) -> Self {
		self.textView.isSelectable = selectable
		return self
	}

	/// Set the font to use for display
	@discardableResult @inlinable
	func font(_ font: NSFont) -> Self {
		self.textView.font = font
		return self
	}

	/// Set whether the text view wraps text lines
	/// - Parameter wrapsLines: If true, wraps lines
	/// - Returns: self
	@discardableResult
	func wrapsLines(_ wrapsLines: Bool) -> Self {
		self.wrapText(wrapsLines)
		return self
	}
}

// MARK: - Bindings

@MainActor
public extension AUIScrollingTextView {
	/// Set whether the text view wraps text lines
	/// - Parameter wrapsLines: If true, wraps lines
	/// - Returns: self
	@discardableResult
	func wrapsLines(_ wrapsLines: Bind<Bool>) -> Self {
		wrapsLines.register(self) { @MainActor [weak self] newState in
			self?.wrapText(newState)
		}
		return self
	}

	/// Set if the text view is editable
	/// - Parameter isEditable: The editable state
	/// - Returns: self
	@discardableResult
	func isEditable(_ isEditable: Bind<Bool>) -> Self {
		isEditable.register(self) { @MainActor [weak self] isEditable in
			guard let `self` = self else { return }
			if self.textView.isEditable != isEditable {
				self.textView.isEditable = isEditable
			}
		}
		self.textView.isEditable = isEditable.wrappedValue
		return self
	}

	/// Set if the text view is selectable
	/// - Parameter isSelectable: The editable state
	/// - Returns: self
	@discardableResult
	func isSelectable(_ isSelectable: Bind<Bool>) -> Self {
		isSelectable.register(self) { @MainActor [weak self] isSelectable in
			guard let `self` = self else { return }
			if self.textView.isSelectable != isSelectable {
				self.textView.isSelectable = isSelectable
			}
		}
		self.textView.isSelectable = isSelectable.wrappedValue
		return self
	}

	/// The current text selection
	/// - Parameter selectedRange: The selected range
	/// - Returns: self
	@discardableResult
	func selectedRange(_ selectedRange: Bind<NSRange>) -> Self {
		selectedRange.register(self) { @MainActor [weak self] newRange in
			guard let `self` = self else { return }
			self.textView.selectedRanges = [NSValue(range: newRange)]
		}
		self.usingStorage { $0.selectedRange = selectedRange }
		return self
	}
}

// MARK: - Storage

@MainActor
private extension AUIScrollingTextView {
	@MainActor class Storage: NSObject, NSTextViewDelegate {
		weak var parent: AUIScrollingTextView?
		var text: Bind<String>?
		var selectedRange: Bind<NSRange>?

		init(_ parent: AUIScrollingTextView) {
			super.init()
			self.parent = parent
			parent.textView.delegate = self
		}

		@MainActor
		public func textDidChange(_ notification: Notification) {
			guard let parent = self.parent else { return }
			if let text = self.text {
				text.wrappedValue = parent.textView.string
			}
		}

		@MainActor
		public func textViewDidChangeSelection(_ notification: Notification) {
			guard let parent = self.parent else { return }
			if let s = self.selectedRange {
				let range = parent.textView.selectedRange()
				if range != s.wrappedValue {
					s.wrappedValue = range
				}
			}
		}
	}

	func usingStorage(_ block: @escaping (Storage) -> Void) {
		self.usingAssociatedValue(key: "__zascrollingtextview_bond", initialValue: { Storage(self) }, block)
	}
}

// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("default") {
	let text = Bind("This is a test")
	let selection = Bind(NSRange.empty)

	let isSelectable = Bind(true)
	let isEditable = Bind(true)
	let wraps = Bind(true)
	let selectionText = Bind("")

	VStack {
		Spacer()
			.height(20)
		HStack {
			AUIScrollingTextView(text: text)
				.font(.monospaced)
				.isSelectable(isSelectable)
				.isEditable(isEditable)
				.wrapsLines(wraps)
				.selectedRange(selection)
			VStack {
				NSButton.checkbox(title: "selectable")
					.state(isSelectable)
				NSButton.checkbox(title: "editable")
					.state(isEditable)
					.isEnabled(isSelectable)
				NSButton.checkbox(title: "wraps")
					.state(wraps)
				NSTextField(label: "")
					.content(selectionText)
				Spacer()
			}
			.alignment(.leading)
		}
		HStack {
			Spacer()
			NSButton(title: "selection") { [weak selection] _ in
				selection?.wrappedValue = NSRange(location: 6, length: 6)
			}
			.identifier("b2")
			NSButton(title: "reset") { [weak text] _ in
				text?.wrappedValue = "This is a test"
			}
			.identifier("b1")
		}
		.equalWidths(["b1", "b2"])

	}
	.onChange(text) { newValue in Swift.print(newValue) }
	.onChange(selection) { [weak selectionText] newValue in
		selectionText?.wrappedValue = "\(newValue)"
	}
	.padding()
}

#endif
