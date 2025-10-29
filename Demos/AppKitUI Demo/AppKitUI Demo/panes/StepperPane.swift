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

class StepperPane: Pane {
	override func title() -> String { "NSStepper" }
	@MainActor
	override func make(model: Model) -> NSView {
		let value = Bind<Double>(20)

		let enabled = Bind(false)

		let nf = NumberFormatter {
			$0.minimum = 0
			$0.maximum = 100
		}
		let nfValue = Bind(20.0) { newValue in
			model.log("value is now '\(nf.string(for: newValue) ?? "<>")'")
		}

		let nf2 = NumberFormatter {
			$0.minimum = -1
			$0.maximum = 1
			$0.minimumFractionDigits = 0
			$0.maximumFractionDigits = 4
		}
		let nf2Value = Bind(0.5) { newValue in
			model.log("nf2Value is now '\(nf2.string(for: newValue) ?? "<>")'")
		}

		let nf3 = NumberFormatter {
			$0.minimum = -10
			$0.maximum = 10
			$0.minimumFractionDigits = 3
			$0.maximumFractionDigits = 3
		}
		let nf3Value = Bind(0.0) { newValue in
			model.log("nf3Value is now '\(nf3.string(for: newValue) ?? "<>")'")
		}

		let intStepper = Bind(1)
		let mappedDoubleStepper = intStepper.twoWayTransform(BindTransformers.IntToDouble())

		return NSView(layoutStyle: .centered) {
			VStack(spacing: 20) {

				NSGridView {
					NSGridView.Row {
						NSGridCell.emptyContentView
						NSTextField(label: "stepper")
							.textColor(.tertiaryLabelColor)
							.font(.systemSmall)
						NSTextField(label: "raw value")
							.textColor(.tertiaryLabelColor)
							.font(.systemSmall)
						NSTextField(label: "reset")
							.textColor(.tertiaryLabelColor)
							.font(.systemSmall)
					}

					NSGridView.Row {
						NSGridCell.emptyContentView
						HDivider()
						HDivider()
						HDivider()
					}

					NSGridView.Row(rowAlignment: .firstBaseline) {
						NSTextField(label: "My groovy stepper (0…100):")
							.font(.monospacedDigit)
						HStack(spacing: 2) {
							NSTextField(value: value, formatter: NumberFormatter())
								.alignment(.right)
								.width(50)
								.onChange { newText in
									model.log("NSTextField -> \(newText)")
								}
							NSStepper(value: value, range: 0 ... 100, increment: 1)
								.onChange {
									model.log("NSStepper -> \($0)")
								}
						}
						NSTextField(label: "")
							.width(50)
							.alignment(.right)
							.content(value.formattedString(NumberFormatter()))

						NSButton.image(NSImage(named: NSImage.refreshTemplateName)!) { _ in
							value.wrappedValue = 20
						}
						.toolTip("Reset the value back to its initial value")
						.huggingPriority(.defaultLow, for: .horizontal)
						.gridCell(xPlacement: .center, yPlacement: .center)
					}
				}

				HDivider()

				VStack {
					HStack {
						NumberStepperView(value: nfValue, formatter: nf, increment: 1)
							.width(100)

						NSButton(title: "Reset") { _ in
							value.wrappedValue = 99
						}

						NSTextField(label: "")
							.textColor(.tertiaryLabelColor)
							.font(.systemSmall)
							.width(50)
							.content(nfValue.formattedString(nf))
					}

					HStack {
						NumberStepperView(value: nf2Value, formatter: nf2, increment: 0.05)
							.bezelStyle(.roundedBezel)
							.width(100)

						NSButton(title: "Reset") { _ in
							nf2Value.wrappedValue = 200
						}
						NSTextField(label: "")
							.textColor(.tertiaryLabelColor)
							.font(.systemSmall)
							.width(50)
							.content(nf2Value.formattedString(nf2))
					}

					HStack {
						NumberStepperView(value: nf3Value, formatter: nf3, increment: 0.05)
							.isEnabled(enabled)
							.isBezeled(false)
							.drawsBackground(false)
							.spacing(4)
							.withEmbeddedTextControl {
								$0.font(.monospacedDigit.size(24).weight(.medium))
							}
						NSButton.checkbox(title: "Enable")
							.state(enabled)
					}

					HStack {
						NSTextField(value: intStepper)
							.alignment(.right)
						NSStepper(value: mappedDoubleStepper, range: 0 ... 20)
					}
				}
			}
			.padding()
		}
	}
}

#if DEBUG
@available(macOS 14, *)
#Preview("Basic Stepper") {
	StepperPane().make(model: Model())
}
#endif
