//
//  Copyright © 2026 Darren Ford. All rights reserved.
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

class AUISwitchPane: Pane {
	override func title() -> String { NSLocalizedString("NSSwitch (10.11+)", comment: "") }

	override func make(model: Model) -> NSView {

		let state = Bind(false)
		let enabled = Bind(true)

		return VStack(alignment: .leading) {
			NSTextField(label: NSLocalizedString("This is an NSSwitch equivalent that supports back to 10.11", comment: ""))

			HDivider()

			VStack(alignment: .leading, spacing: 20) {
				HStack {
					NSButton.checkbox(title: NSLocalizedString("Enabled", comment: ""))
						.state(enabled)
					NSButton.checkbox(title: NSLocalizedString("State", comment: ""))
						.state(state)
				}

				HStack {
					NSView(layoutStyle: .fill) {
						if #available(macOS 10.15, *) {
							AUISwitch()
								.state(state)
								.controlSize(.regular)
								.isEnabled(enabled)
						}
						else {
							NSView.empty
						}
					}
					AUISwitch()
						.state(state)
						.controlSize(.regular)
						.isEnabled(enabled)
					AUISwitch()
						.state(state)
						.controlSize(.small)
						.isEnabled(enabled)
					AUISwitch()
						.state(state)
						.controlSize(.mini)
						.isEnabled(enabled)
					NSView.Spacer()
				}
			}
			NSView.Spacer()
		}
		.padding(28)
	}
}

#if DEBUG
@available(macOS 14, *)
#Preview("default") {
	AUISwitchPane().make(model: Model())
		//.frame(width: 320, height: 200)
}
#endif
