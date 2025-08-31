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

class SubscriptionExamplePane: Pane {
	override func title() -> String { "Subscription Example" }
	@MainActor
	override func make(model: Model) -> NSView {
		let selected = Bind(0)
		return NSView(layoutStyle: .centered) {
			VStack {
				build(
					index: 0,
					selected: selected,
					content:
						VStack(alignment: .leading, spacing: 4) {
							NSTextField(label: "Monthly")
								.font(.title3.weight(.medium))
							HStack(alignment: .firstBaseline, spacing: 4) {
								NSTextField(label: "$1.99")
									.font(.title1.bold)
								NSTextField(label: "/month")
									.font(.caption2)
									.textColor(.secondaryLabelColor)
							}
						}
				)

				build(
					index: 1,
					selected: selected,
					content:
						VStack(alignment: .leading, spacing: 4) {
							NSTextField(label: "Yearly")
								.font(.title3.weight(.medium))
							HStack(alignment: .firstBaseline, spacing: 4) {
								NSTextField(label: "$14.99")
									.font(.title1.bold)
								NSTextField(label: "/year")
									.font(.caption2)
									.textColor(.secondaryLabelColor)
							}
						}
				)

				build(
					index: 2,
					selected: selected,
					content:
						HStack {
							VStack(alignment: .leading, spacing: 4) {
								NSTextField(label: "Lifetime")
									.font(.title3.weight(.medium))
								HStack(alignment: .firstBaseline, spacing: 4) {
									NSTextField(label: "$29.99")
										.font(.title1.bold)
								}
							}
							.gravityArea(.leading)

							NSTextField(label: "Save 25%")
								.font(.headline)
								.padding(top: 4, left: 8, bottom: 4, right: 8)
								.backgroundCornerRadius(8)
								.backgroundFill(.systemRed)
								.gravityArea(.trailing)
							NSTextField(label: "Popular")
								.font(.headline)
								.padding(top: 4, left: 8, bottom: 4, right: 8)
								.background(
									Rectangle(cornerRadius: 8)
										.fill(.color(.systemBlue))
								)
								.gravityArea(.trailing)
						}
				)
			}
		}
	}
}

@MainActor
func build(index: Int, selected: Bind<Int>, content: NSView) -> NSView {

	let isButtonSelected = selected.oneWayTransform { $0 == index }

	return NSView {
		Rectangle(cornerRadius: 8)
			.stroke(.systemGray, lineWidth: 2)
			.isHidden(isButtonSelected)

		Rectangle(cornerRadius: 8)
			.stroke(.standardAccentColor, lineWidth: 4)
			.fill(color: .standardAccentColor.alpha(0.2))
			.isHidden(isButtonSelected.toggled())

		content
			.padding()

		AUITransparentButton()
			.buttonType(.radio)
			.focusRingBounds { bounds in
				NSBezierPath(roundedRect: bounds, xRadius: 8, yRadius: 8)
			}
			.onAction { _ in
				selected.wrappedValue = index
				Swift.print("asdfasfd")
			}
	}
	.frame(width: 350, height: 100)
}



#if DEBUG
@available(macOS 14, *)
#Preview("Subscription example") {
	SubscriptionExamplePane().make(model: Model())
}

#endif
