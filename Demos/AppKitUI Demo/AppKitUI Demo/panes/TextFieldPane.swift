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
import AppKitUI

class TextFieldPane: Pane {
	override func title() -> String { "Text Fields" }
	@MainActor
	override func make(model: Model) -> NSView {
		return ScrollView(borderType: .noBorder) {
			VStack {
				NSBox(title: "Labels") {
					LabelFields().body
						.padding(4)
				}
				.huggingPriority(.init(10), for: .horizontal)

				NSBox(title: "Edit fields") {
					EditFields().body
						.padding(4)
				}
				.huggingPriority(.init(10), for: .horizontal)
			}
			.padding()
		}
	}
}

struct LabelFields: AUIViewBodyGenerator {
	let text = "The quick brown fox jumps over the lazy dog"
	var body: NSView {
		NSGridView {
			NSGridView.Row {
				NSTextField(label: "Basic label:")
					.font(.system.weight(.semibold))
				NSTextField(label: text)
					.compressionResistancePriority(.defaultLow, for: .horizontal)
					.lineBreakMode(.byTruncatingTail)
					.huggingPriority(.init(10), for: .horizontal)
			}
			NSGridView.Row {
				NSTextField(label: "Selectable text:")
					.font(.system.weight(.semibold))
				NSTextField(label: text)
					.compressionResistancePriority(.defaultLow, for: .horizontal)
					.lineBreakMode(.byTruncatingMiddle)
					.isSelectable(true)
					.huggingPriority(.init(10), for: .horizontal)
			}
			NSGridView.Row {
				NSTextField(label: "Custom font:")
					.font(.system.weight(.semibold))
				NSTextField(label: text)
					.huggingPriority(.init(10), for: .horizontal)
					.compressionResistancePriority(.defaultLow, for: .horizontal)
					.font(.title2.weight(.bold).italic)
					.textColor(.systemPurple)
					.drawsBackground(true)
					.backgroundColor(.systemYellow)
					.wraps(true)
					.lineBreakMode(.byWordWrapping)
					.truncatesLastVisibleLine(false)
			}
		}
		.columnAlignment(.trailing, forColumn: 0)
		.rowAlignment(.firstBaseline)
	}
}

struct EditFields: AUIViewBodyGenerator {
	let text = Bind("The quick brown fox jumps over the lazy dog")
	let text2 = Bind("")
	var body: NSView {
		NSGridView {
			NSGridView.Row {
				NSTextField(label: "Basic edit field:")
					.font(.system.weight(.semibold))
				NSTextField(content: text)
					.isScrollable(true)
			}

			NSGridView.Row {
				NSTextField(label: "Disabled:")
					.font(.system.weight(.semibold))
				NSTextField(content: text)
					.isEnabled(false)
			}

			NSGridView.Row {
				NSTextField(label: "Rounded bezel:")
					.font(.system.weight(.semibold))
				NSTextField(content: text)
					.bezelStyle(.roundedBezel)
					.isScrollable(true)
			}

			NSGridView.Row {
				NSTextField(label: "Placeholder:")
					.font(.system.weight(.semibold))
				NSTextField(content: text2)
					.placeholder("Enter some text")
					.isScrollable(true)
			}
		}
		.columnAlignment(.trailing, forColumn: 0)
		.rowAlignment(.firstBaseline)
	}
}

#if DEBUG
@available(macOS 14, *)
#Preview("Basic") {
	TextFieldPane().make(model: Model())
}
#endif
