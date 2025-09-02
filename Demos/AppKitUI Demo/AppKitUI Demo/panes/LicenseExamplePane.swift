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
	override func title() -> String { NSLocalizedString("License Example", comment: "") }
	@MainActor
	override func make(model: Model) -> NSView {
		let licenseKey = Bind("YTMG3-N6DKC-DKB77-7M9GH-8HVX7")
		let isLicenseKeyActivated = Bind(true)

		let imageActivated = NSImage(named: "checkmark.circle.fill")!
		let imageNotActivated = NSImage(named: "xmark.square.fill")!
		let activationState = Bind<NSImage?>(imageActivated)

		return NSView(layoutStyle: .centered) {

			NSBox {
				VStack(spacing: 32) {
					NSImageView(image: NSApplication.shared.applicationIconImage)

					VStack(spacing: 8) {
						HStack {
							NSTextField(label: NSLocalizedString("License Key:", comment: ""))
								.font(.system.weight(.medium))
							NSTextField(content: licenseKey)
								.roundedBezel()
								.isScrollable(true)
								.isEditable(isLicenseKeyActivated.toggled())
								.isSelectable(true)
								.font(.monospaced.size(14))
								.compressionResistancePriority(.required, for: .horizontal)
								.width(275)
							NSImageView(image: activationState)
								.frame(width: 16, height: 16)
						}
						.onChange(isLicenseKeyActivated, { newValue in
							// Listen for changes in the activation state and reflect in the image
							activationState.wrappedValue = newValue ? imageActivated : imageNotActivated
						})

						HStack {
							NSButton(title: NSLocalizedString("Deactivate", comment: ""))
								.identifier("deactivate")
								.isEnabled(isLicenseKeyActivated)
								.onAction { _ in isLicenseKeyActivated.wrappedValue = false }
								.gravityArea(.trailing)
							NSButton(title: NSLocalizedString("Activate", comment: ""))
								.identifier("activate")
								.isEnabled(isLicenseKeyActivated.toggled())
								.onAction { _ in isLicenseKeyActivated.wrappedValue = true }
								.gravityArea(.trailing)
						}
						.equalWidths(["deactivate", "activate"])
						.hugging(.init(10), for: .horizontal)
					}

					HStack {
						NSButton(title: NSLocalizedString("􀎬 Customer Portal", comment: ""))
							.isBordered(false)
							.onAction { _ in
								model.log("LicenseKey: Clicked 'Customer Portal'")
							}
							.gravityArea(.leading)

						NSButton(title: NSLocalizedString("Online Store 􁽇", comment: ""))
							.isBordered(false)
							.onAction { _ in
								model.log("LicenseKey: Clicked 'Online Store'")
							}
							.gravityArea(.trailing)
					}
					.hugging(.init(10), for: .horizontal)
				}
				.hugging(.defaultHigh, for: .horizontal)
				.padding(20)
			}
		}
	}
}

#if DEBUG
@available(macOS 14, *)
#Preview("Basic") {
	LicenseExamplePane().make(model: Model())
		.width(500)
		//.debugFrames(.systemRed.withAlphaComponent(0.3))
}
#endif
