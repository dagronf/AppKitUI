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
public extension NSButton {
	/// Create a button that looks like a link
	/// - Parameters:
	///   - title: The button title
	///   - onAction: The action to perform when the link is pressed
	/// - Returns: self
	static func link(title: String, onAction: @escaping (NSControl.StateValue) -> Void) -> AUILinkButton {
		AUILinkButton(frame: .zero)
			.translatesAutoresizingMaskIntoConstraints(false)
			.title(title)
			.onAction(onAction)
	}
}

/// An NSButton that resembles a link
@MainActor
public class AUILinkButton: NSButton {
	/// The text font
	public override var font: NSFont? {
		get { super.font }
		set {
			super.font = newValue
			self.updateAppearance()
		}
	}

	/// Set the color for the link
	public var linkColor: NSColor = NSColor.standardAccentColor {
		didSet {
			self.updateAppearance()
		}
	}

	/// Set the title for the link
	public override var title: String {
		get { super.title }
		set {
			super.title = newValue
			self.updateAppearance()
		}
	}

	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		self.setupLinkAppearance()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.setupLinkAppearance()
	}

	override public func awakeFromNib() {
		super.awakeFromNib()
		self.setupLinkAppearance()
	}

	private func setupLinkAppearance() {
		// Remove button styling
		self.isBordered = false

		// Set button type to momentary change for proper click behavior
		self.setButtonType(.momentaryChange)

		// Reflect the appearance settings
		self.updateAppearance()
	}

	/// A Boolean value that indicates whether the receiver reacts to mouse events.
	public override var isEnabled: Bool {
		get { super.isEnabled }
		set {
			super.isEnabled = newValue
			self.window?.invalidateCursorRects(for: self)
		}
	}

	override public func resetCursorRects() {
		super.resetCursorRects()
		if self.isEnabled {
			// Add a cursor rect for the entire bounds of the button
			// using the pointingHand cursor.
			self.addCursorRect(bounds, cursor: NSCursor.pointingHand)
		}
	}

	fileprivate func updateAppearance() {
		let font = self.font ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)

		let attributes: [NSAttributedString.Key: Any] = [
			.foregroundColor: self.linkColor,
			.font: font,
			.underlineStyle: NSUnderlineStyle.single.rawValue,
		]

		if let title = self.title as String? {
			let attributedTitle = NSAttributedString(string: title, attributes: attributes)
			self.attributedTitle = attributedTitle
		}
	}
}

// MARK: - Modifiers

@MainActor
public extension AUILinkButton {
	/// The font used to draw text in the receiver’s cell.
	/// - Parameter font: The font
	/// - Returns: self
	@discardableResult
	@objc override public func font(_ font: NSFont) -> Self {
		self.font = font
		return self
	}

	/// Set the title for the button
	/// - Parameter title: The title
	/// - Returns: self
	@discardableResult
	@objc public override func title(_ title: String) -> Self {
		self.title = title
		return self
	}

	/// Set the color for the link
	/// - Parameter value: The link color
	/// - Returns: self
	@discardableResult @inlinable
	func linkColor(_ value: NSColor) -> Self {
		self.linkColor = value
		return self
	}
}

// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("default") {
	NSGridView() {
		NSGridView.Row(rowAlignment: .firstBaseline) {
			NSTextField(label: "Basic:")
				.font(.system.weight(.medium))
			HStack(spacing: 2) {
				NSButton.link(title: "#first") { _ in
					Swift.print("first pressed")
				}
				NSButton.link(title: "#second") { _ in
					Swift.print("second pressed")
				}
				NSButton.link(title: "#third") { _ in
					Swift.print("third pressed")
				}
				.isEnabled(false)
			}
		}

		NSGridView.Row(rowAlignment: .firstBaseline) {
			NSTextField(label: "Custom text style:")
				.font(.system.weight(.medium))
			HStack {
				NSButton.link(title: "@third") { _ in
					Swift.print("third pressed")
				}
				.font(.systemFont(ofSize: 18).italic.weight(.heavy))
				NSButton.link(title: "Online Help") { _ in
					Swift.print("'Online Help' pressed")
				}
				.font(.title2.weight(.thin))
				.toolTip("Online Help")
			}
		}

		NSGridView.Row(rowAlignment: .firstBaseline) {
			NSTextField(label: "Custom link color:")
				.font(.system.weight(.medium))
			HStack(spacing: 2) {
				NSButton.link(title: "Website") { _ in
					Swift.print("User clicked 'Website'")
				}
				.linkColor(.systemBlue)
				.toolTip("This is a tooltip for the website link")

				NSButton.link(title: "Something else") { _ in
					Swift.print("User clicked 'Something else'")
				}
				.linkColor(.systemGreen)
				.toolTip("This is a tooltip for the something else link")
			}
		}
	}
	.columnAlignment(.trailing, forColumn: 0)
}

#endif
