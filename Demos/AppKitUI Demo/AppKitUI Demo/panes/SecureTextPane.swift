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

class SecureTextPane: Pane {
	override func title() -> String { "Secure Text Field" }
	@MainActor
	override func make(model: Model) -> NSView {
		let password1 = Bind("")
		let password2 = Bind("")
		return NSView(layoutStyle: .centered) {
			NSGridView {
				NSGridView.Row(rowAlignment: .firstBaseline) {
					NSTextField(label: "Basic password:")
					NSSecureTextField(content: password1)
						.onChange { Swift.print("password1 is '\($0)'") }
						.bezelStyle(.roundedBezel)
						.width(200)
					NSImageView(imageNamed: NSImage.goRightTemplateName)
						.huggingPriority(.required, for: .horizontal)
					NSTextField(content: password1)
						.isEnabled(false)
						.placeholder("<no password>")
						.width(200)
				}
				
				NSGridView.Row(rowAlignment: .firstBaseline) {
					NSTextField(label: "No echo:")
					NSSecureTextField(content: password2)
						.echoesBullets(false)
						.onChange { Swift.print("password2 is '\($0)'") }
						.width(200)
					NSImageView(imageNamed: NSImage.goRightTemplateName)
					NSTextField(content: password2)
						.isEnabled(false)
						.placeholder("<no password>")
						.width(200)
				}
			}
			.columnAlignment(.trailing, forColumn: 0)
		}
		.debugFrames()
	}
}

#if DEBUG
@available(macOS 14, *)
#Preview("Basic") {
	SecureTextPane().make(model: Model())
}
#endif
