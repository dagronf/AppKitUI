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

class DelayedBindPane: Pane {
	override func title() -> String { "Delayed Bind" }
	@MainActor
	override func make(model: Model) -> NSView {

		let standardValueFormatter = NumberFormatter {
			$0.minimum = 0
			$0.maximum = 100
		}
		let standardValue = Bind(20.0)
		let delayedValue = Bind(20.0, delayType: .debounce(0.5))
		let throttledValue = Bind(20.0, delayType: .throttle(0.5))

		return NSView(layoutStyle: .centered) {

			NSGridView(rowSpacing: 8) {

				NSGridView.Row {
					NSTextField(label: "Standard (no delay): ")
						.font(.headline)
					NumberStepperView(value: standardValue, formatter: standardValueFormatter, increment: 1)
						.width(50)
					NSImageView(imageNamed: NSImage.goRightTemplateName)
					VStack(alignment: .trailing, spacing: 2) {
						NSTextField(value: standardValue, formatter: standardValueFormatter)
							.width(70)
							.alignment(.right)
							.bezelStyle(.roundedBezel)
							.isEditable(false)
						NSTextField(label: "Standard")
							.font(.caption2)
							.textColor(.tertiaryLabelColor)
					}
				}

				NSGridView.Row {
					HDivider()
				}
				.mergeCells(0 ... 3)

				NSGridView.Row {
					VStack(alignment: .leading, spacing: 4) {
						NSTextField(label: "Debounced bind (0.5 sec):")
							.font(.headline)
						NSTextField(label: "Value updates only when no further changes occur in the binding for a specified time.")
							.compressionResistancePriority(.init(1), for: .horizontal)
							.font(.caption2)
							.textColor(.secondaryLabelColor)
					}
					NumberStepperView(value: delayedValue, formatter: standardValueFormatter, increment: 1)
						.width(50)
					NSImageView(imageNamed: NSImage.goRightTemplateName)
					VStack(alignment: .trailing, spacing: 2) {
						NSTextField(value: delayedValue, formatter: standardValueFormatter)
							.width(70)
							.alignment(.right)
							.bezelStyle(.roundedBezel)
							.isEditable(false)
						NSTextField(label: "Debounced")
							.font(.caption2)
							.textColor(.tertiaryLabelColor)
					}
				}

				NSGridView.Row {
					HDivider()
				}
				.mergeCells(0 ... 3)

				NSGridView.Row {
					VStack(alignment: .leading, spacing: 4) {
						NSTextField(label: "Throttled bind (0.5 sec):")
							.font(.headline)
						NSTextField(label: "Values are throttled through the binding.")
							.compressionResistancePriority(.init(1), for: .horizontal)
							.font(.caption2)
							.textColor(.secondaryLabelColor)
					}
					NumberStepperView(value: throttledValue, formatter: standardValueFormatter, increment: 1)
						.width(50)
					NSImageView(imageNamed: NSImage.goRightTemplateName)
					VStack(alignment: .trailing, spacing: 2) {
						NSTextField(value: throttledValue, formatter: standardValueFormatter)
							.width(70)
							.alignment(.right)
							.bezelStyle(.roundedBezel)
							.isEditable(false)
						NSTextField(label: "Throttled")
							.font(.caption2)
							.textColor(.tertiaryLabelColor)
					}
				}
			}
			.rowAlignment(.firstBaseline)
			.columnWidth(30, forColumn: 2)
			.columnAlignment(.center, forColumn: 2)
			.padding(30)
			.background(
				NSVisualEffectView()
					.isEmphasized(true)
					.cornerRadius(16)
					.backgroundBorder(.textColor, lineWidth: 1)
			)
		}
	}
}

#if DEBUG
@available(macOS 14, *)
#Preview("Basic") {
	DelayedBindPane().make(model: Model())
}
#endif
