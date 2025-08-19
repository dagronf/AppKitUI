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

class LicenseExamplePane: Pane {
	override func title() -> String { "License Example" }
	@MainActor
	override func make(model: Model) -> NSView {
		let licenseKey = Bind("YTMG3-N6DKC-DKB77-7M9GH-8HVX7")
		let isLicenseKeyActivated = Bind(true)

		return NSView(layoutStyle: .centered) {
			VStack {
				NSImageView(image: NSApplication.shared.applicationIconImage)
					.padding(12)

				VStack {
					HStack {
						NSTextField(label: "License Key:")
							.font(.system.weight(.medium))
						NSTextField(content: licenseKey)
							.roundedBezel()
							.font(.monospaced)
							.compressionResistancePriority(.required, for: .horizontal)
					}
					.hugging(.init(10), for: .horizontal)

					HStack {
						NSButton(title: "Deactivate")
							.identifier("deactivate")
							.isEnabled(isLicenseKeyActivated)
							.onAction { _ in isLicenseKeyActivated.wrappedValue = false }
							.gravityArea(.trailing)
						NSButton(title: "Activate")
							.identifier("activate")
							.isEnabled(isLicenseKeyActivated.toggled())
							.onAction { _ in isLicenseKeyActivated.wrappedValue = true }
							.gravityArea(.trailing)
					}
					.equalWidths(["deactivate", "activate"])
					.hugging(.init(10), for: .horizontal)
				}
				.padding(12)

				NSView()
					.huggingPriority(.defaultLow, for: .vertical)

				HStack {
					NSButton(title: "􀎬 Customer Portal")
						.isBordered(false)
						.onAction { _ in
							model.log("LicenseKey: Clicked 'Customer Portal'")
						}
						.gravityArea(.leading)

					NSButton(title: "Online Store 􁽇")
						.isBordered(false)
						.onAction { _ in
							model.log("LicenseKey: Clicked 'Online Store'")
						}
						.gravityArea(.trailing)
				}
				.hugging(.init(10), for: .horizontal)

				.padding(12)
			}
			.minWidth(400)
		}
	}
}

#if DEBUG
@available(macOS 14, *)
#Preview("Basic") { //}, traits: .fixedLayout(width: 600, height: 400)) {
	LicenseExamplePane().make(model: Model())
		.width(500)
		.debugFrames(.systemRed.withAlphaComponent(0.3))
}
#endif
