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

private let ellipsisImage = NSImage(named: "ellipsis")!
	.isTemplate(true)

class FinanceSwatchPane: Pane {
	override func title() -> String { "Finance Swatch Example" }
	@MainActor
	override func make(model: Model) -> NSView {

		let creditcardImage = NSImage(named: "creditcard")!
			.isTemplate(true)
		let arrowLeftRightImage = NSImage(named: "arrow.left.arrow.right")!
			.isTemplate(true)
		let buildingColumnsImage = NSImage(named: "building.columns")!
			.isTemplate(true)
		let buildingImage = NSImage(named: "building.2")!
			.isTemplate(true)

		return ScrollView(borderType: .noBorder) {
			Flow {
				buildSwatch(model: model, typeImage: creditcardImage, type: "Transfer via Card Number", value: "$1200")
				buildSwatch(model: model, typeImage: arrowLeftRightImage, type: "Transfer other banks", value: "$245")
				buildSwatch(model: model, typeImage: buildingColumnsImage, type: "Transfer same bank", value: "$1500")
				buildSwatch(model: model, typeImage: buildingImage, type: "Transfer via PayPal", value: "$800")
			}
			.padding()
			.debugFrames()
		}
	}
}

@MainActor
func buildSwatch(model: Model, typeImage: NSImage, type: String, value: String) -> NSView {
	return NSView(layoutStyle: .fill) {
		VStack(alignment: .leading, spacing: 16) {
			HStack {
				NSImageView(image: typeImage)
					.gravityArea(.leading)
					.contentTintColor(.textColor)
					.imageScaling(.scaleProportionallyUpOrDown)
					.frame(width: 20, height: 20)

				NSView.Spacer()

				NSButton()
					.image(ellipsisImage)
					.imagePosition(.imageOnly)
					.contentTintColor(.textColor)
					.isBordered(false)
					.frame(width: 20, height: 20)
					.imageScaling(.scaleProportionallyUpOrDown)
					.onActionMenu(
						NSMenu {
							NSMenuItem(title: "Mark completed") { _ in model.log("first menu item") }
							NSMenuItem(title: "Delay for two weeks") { _ in model.log("second menu item") }
							NSMenuItem.separator()
							NSMenuItem(title: "Pay online…") { _ in model.log("third menu item") }
						}
					)
					.accessibilityTitle("More options")
					.gravityArea(.trailing)
			}
			NSTextField(label: type)
				.compressionResistancePriority(.defaultLow, for: .horizontal)
				.textColor(.secondaryLabelColor)
				.height(40)
			NSTextField(label: value)
				.font(.title3.weight(.semibold))
		}
		.padding(12)
	}
	.width(130)
	.background(
		Rectangle(cornerRadius: 8)
			.fill(.color(darkColor: NSColor(calibratedWhite: 0.17, alpha: 1), lightColor: .white))
			.stroke(.textColor, lineWidth: 0.5)
			.shadow(offset: CGSize(width: 1, height: -1), color: .black.withAlphaComponent(0.5), blurRadius: 3)
	)
	.padding(4)
}




#if DEBUG
@available(macOS 14, *)
#Preview("Basic") {
	FinanceSwatchPane().make(model: Model())
}
#endif
