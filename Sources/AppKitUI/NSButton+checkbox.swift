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

import AppKit.NSButton

// `NSButton` checkbox extensions

@MainActor
public extension NSButton {
	/// Create a checkbox with no title
	/// - Parameter onAction: The action to call when the checkbox state changes
	/// - Returns: A checkbox
	public static func checkbox(onAction: ((NSControl.StateValue) -> Void)? = nil) -> AUICheckbox {
		AUICheckbox(onAction: onAction)
	}

	/// Create a checkbox with no title
	/// - Parameters:
	///   - title: The text appearing on the checkbox
	///   - onAction: The action to call when the checkbox state changes
	/// - Returns: A checkbox
	public static func checkbox(title: String, onAction: ((NSControl.StateValue) -> Void)? = nil) -> AUICheckbox {
		AUICheckbox(title: title, onAction: onAction)
	}
}

// MARK: - Checkbox creation


/// An checkbox that supports adding a description field below the checkbox text.
@MainActor
public class AUICheckbox: NSButton {
	/// Create a checkbox with a title and an optional action
	/// - Parameters:
	///   - title: The title
	///   - onAction: The block to call when the checkbox changes state
	public init(title: String, onAction: ((NSControl.StateValue) -> Void)? = nil) {
		super.init(frame: .zero)
		self.setButtonType(.switch)
		self.title = title
		if let onAction {
			self.onAction(onAction)
		}
	}

	/// Create a checkbox with no title
	/// - Parameter onAction: The block to call when the checkbox changes state
	public convenience init(onAction: ((NSControl.StateValue) -> Void)? = nil) {
		self.init(title: "", onAction: onAction)
		self.hidesTitle(true)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	/// Add styled description text underneath the checkbox, leading aligned to the text of the checkbox
	/// - Parameter msg: The message to display
	/// - Returns: self
	///
	/// Note that this method returns a new view, so make sure you call any NSButton- specific
	/// methods before calling this one
	@discardableResult
	public func descriptionText(_ msg: String) -> NSView {
		let descriptionField = NSTextField(label: msg)
			.font(.systemSmall)
			.textColor(.secondaryLabelColor)
			.huggingPriority(.defaultLow, for: .horizontal)
			.compressionResistancePriority(.init(1), for: .horizontal)
			.compressionResistancePriority(.defaultHigh, for: .vertical)

		let result = VStack(alignment: .leading, spacing: 4) {
			self
			descriptionField
		}
		.hugging(.init(10), for: .horizontal)

		result.addConstraint(
			NSLayoutConstraint(
				item: descriptionField, attribute: .leading,
				relatedBy: .equal,
				toItem: self, attribute: .leading,
				multiplier: 1, constant: 20
			)
		)

		return result
	}
}

// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("default") {
	let isEnabled = Bind(true)
	VStack(alignment: .leading) {
		NSButton.checkbox(title: "This is the first checkbox")
		NSButton.checkbox(title: "This is a disabled checkbox")
			.isEnabled(false)

		HDivider()

		NSButton.checkbox(title: "Automatic prominence while speaking")
			.huggingPriority(.defaultLow, for: .horizontal)
			.descriptionText("During Group FaceTime calls, the tile of the person speaking will automatically become larger.")
		NSButton.checkbox(title: "FaceTime Live Photos")
			.huggingPriority(.defaultLow, for: .horizontal)
			.descriptionText("Allow Live Photos to be captured during video calls.")
		NSButton.checkbox(title: "Live Captions")
			.huggingPriority(.defaultLow, for: .horizontal)
			.descriptionText("Your Mac will use on-device intelligence to automatically display captions in FaceTime. Accuracy of Live Captions may vary and should not be relied upon in high-risk emergency situations.")

		HDivider()

		HStack(spacing: 12) {
			AUICheckbox(title: "This title is hidden")
				.hidesTitle(true)
				.onAction { _ in
					Swift.print("Clicked the checkbox with the hidden title")
				}
			NSTextField(label: "←")
			NSTextField(label: "This checkbox has hidden its title")
		}

		HDivider()

		HStack {
			NSButton.checkbox(title: "This is an optionally enabled checkbox")
				.isEnabled(isEnabled)
			AUISwitch()
				.state(isEnabled)
				.controlSize(.mini)
		}
	}
	.debugFrames()
}

#endif

