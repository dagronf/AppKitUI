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

/// `NSButton` checkbox extensions

// MARK: - Checkbox creation

@MainActor
public extension NSButton {
	/// Create a checkbox button
	/// - Parameters:
	///   - title: The checkbox title
	///   - onAction: The action block to call when the action is performed on the block
	convenience init(checkboxWithTitle title: String, onAction: ((NSControl.StateValue) -> Void)? = nil) {
		self.init(checkboxWithTitle: title, target: nil, action: nil)
		if let onAction {
			self.usingButtonStorage { $0.action = onAction }
		}
	}

	/// Create a checkbox button
	/// - Parameters:
	///   - title: The checkbox title
	///   - onAction: The action block to call when the action is performed on the block
	/// - Returns: A new checkbox button
	static func checkbox(title: String, onAction: ((NSControl.StateValue) -> Void)? = nil) -> NSButton {
		let button = NSButton(checkboxWithTitle: title)
		if let onAction {
			button.usingButtonStorage { $0.action = onAction }
		}
		return button
	}
}

// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("default") {
	let isEnabled = Bind(true)
	VStack(alignment: .leading) {
		NSButton(checkboxWithTitle: "This is the first checkbox")
		NSButton(checkboxWithTitle: "This is a disabled checkbox")
			.isEnabled(false)

		HDivider()

		HStack(spacing: 12) {
			NSButton(checkboxWithTitle: "This title is hidden")
				.hidesTitle(true)
				.onAction { _ in
					Swift.print("Clicked the checkbox with the hidden title")
				}
			NSTextField(label: "←")
			NSTextField(label: "This checkbox has hidden its title")
		}

		HDivider()

		HStack {
			NSButton(checkboxWithTitle: "This is an optionally enabled checkbox")
				.isEnabled(isEnabled)
			AUISwitch()
				.state(isEnabled)
				.controlSize(.mini)
		}
	}
}

#endif

