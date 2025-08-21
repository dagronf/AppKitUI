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

class ShapesPane: Pane {
	override func title() -> String { "Shapes" }
	@MainActor
	override func make(model: Model) -> NSView {

		let color = Bind(NSColor.systemBlue)

		return ScrollView(borderType: .noBorder) {
			VStack(spacing: 20) {
				HStack {
					Rectangle()
						.fill(color: .systemRed)
						.overlay {
							NSButton() { _ in Swift.print("pressed red") }
								.padding()
						}
					Rectangle()
						.fill(color: .systemGreen)
						.overlay {
							NSButton() { _ in Swift.print("pressed green") }
								.padding()
						}
					Rectangle()
						.fill(color: .systemBlue)
						.overlay {
							NSButton() { _ in Swift.print("pressed blue") }
								.padding()
						}
					Rectangle()
						.fill(color: .quaternaryLabelColor)
						.overlay {
							NSButton() { _ in Swift.print("pressed white") }
								.padding()
						}
				}

				HStack {
					Rectangle()
						.fill(.color(.systemRed))
						.cornerRadius(4)
						.stroke(.textColor, lineWidth: 2)
						.overlay {
							NSButton(title: "red")
								.padding()
						}
					Rectangle()
						.fill(color: .systemGreen)
						.cornerRadius(8)
						.stroke(.textColor, lineWidth: 4)
						.overlay {
							NSButton(title: "green")
								.padding()
						}
					Rectangle()
						.fill(color: .systemBlue)
						.cornerRadius(12)
						.stroke(.textColor, lineWidth: 6)
						.overlay {
							NSButton(title: "blue")
								.padding()
						}
					Rectangle()
						.cornerRadius(16)
						.stroke(.textColor, lineWidth: 8)
						.overlay {
							NSButton(title: "none")
								.padding()
						}
				}

				HStack {
					Rectangle()
						.fill(.gradient(colors: [.red, .green, .blue], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1)))
						.cornerRadius(4)
						.stroke(.textColor, lineWidth: 2)
						.overlay {
							NSButton()
								.padding()
						}
					Rectangle()
						.fill(.gradient(colors: [.red, .green, .blue], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 0)))
						.cornerRadius(8)
						.stroke(.textColor, lineWidth: 4)
						.overlay {
							NSButton()
								.padding()
						}
					Rectangle()
						.fill(.gradient(colors: [.red, .green, .blue], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 0, y: 0)))
						.cornerRadius(12)
						.stroke(.textColor, lineWidth: 6)
						.overlay {
							NSButton()
								.padding()
						}
					Rectangle()
						.fill(.gradient(colors: [.red, .green, .blue], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 1)))
						.cornerRadius(16)
						.stroke(.textColor, lineWidth: 8)
						.overlay {
							NSButton()
								.padding()
						}
				}

				HStack {
					Rectangle()
						.fill(.gradient(color: .red))
						.cornerRadius(4)
						.stroke(.textColor, lineWidth: 2)
						.overlay {
							NSButton()
								.padding()
						}
					Rectangle()
						.fill(.gradient(color: .green))
						.cornerRadius(8)
						.stroke(.textColor, lineWidth: 4)
						.overlay {
							NSButton()
								.padding()
						}
					Rectangle()
						.fill(.gradient(color: .blue))
						.cornerRadius(12)
						.stroke(.textColor, lineWidth: 6)
						.overlay {
							NSButton()
								.padding()
						}
				}

				HStack {
					Capsule()
						.fill(.gradient(color: .systemPurple))
						.stroke(.textColor, lineWidth: 2)
						.overlay {
							NSButton()
								.padding()
						}
					Capsule()
						.fill(.gradient(color: .green))
						.stroke(.textColor, lineWidth: 4)
						.overlay {
							NSButton()
								.padding()
						}
					Capsule()
						.fill(.gradient(color: .yellow))
						.stroke(.textColor, lineWidth: 4)
						.overlay {
							NSButton()
								.padding()
						}

					Capsule()
						.fill(.gradient(color: .blue))
						.stroke(.textColor, lineWidth: 6)
						.overlay {
							NSButton()
								.padding()
						}
				}

				HStack {
					Rectangle()
						.fill(.image(NSImage(named: NSImage.colorPanelName)))
						.overlay {
							NSButton() { _ in Swift.print("pressed image 1") }
								.padding()
						}

					Rectangle()
						.fill(.image(NSImage(named: NSImage.colorPanelName), contentsGravity: .resizeAspect))
						.overlay {
							NSButton() { _ in Swift.print("pressed image 2") }
								.padding()
						}

					Rectangle()
						.fill(.image(NSImage(named: NSImage.colorPanelName), contentsGravity: .resizeAspectFill))
						.overlay {
							NSButton() { _ in Swift.print("pressed image 3") }
								.padding()
						}
				}

				HDivider()

				HStack {
					HStack {
						NSImageView(imageNamed: NSImage.userName)
						VStack(alignment: .leading, spacing: 2) {
							NSTextField(label: "Distance")
								.font(.headline)
							NSTextField(label: "12.5 MI")
								.font(.body)
						}
						VDivider()
						VStack(alignment: .leading, spacing: 2) {
							NSTextField(label: "Training Effort")
								.font(.headline)
							NSTextField(label: "Moderate")
								.font(.body)
						}
					}
					.padding(12)
					.background(
						NSVisualEffectView()
							.material(.sidebar)
							.backgroundCornerRadius(8)
							.backgroundBorder(.textColor, lineWidth: 1)
					)
				}

				HDivider()

				NSGridView(columnSpacing: 12) {
					NSGridView.Row {
						NSTextField(label: "using overlay:")
						Capsule()
							.fill(color: .systemOrange)
							.stroke(.textColor, lineWidth: 4)
							.overlay(
								NSButton()
									.padding()
							)

						Capsule()
							.fill(color: .quaternaryLabelColor)
							.stroke(.tertiaryLabelColor, lineWidth: 1)
							.overlay {
								HStack {
									VStack(alignment: .leading, spacing: 2) {
										NSTextField(label: "Distance")
											.font(.headline)
										NSTextField(label: "12.5 MI")
											.font(.body)
									}
									VDivider()
									VStack(alignment: .leading, spacing: 2) {
										NSTextField(label: "Training Effort")
											.font(.headline)
										NSTextField(label: "Moderate")
											.font(.body)
									}
								}
								.padding(top: 4, left: 20, bottom: 4, right: 20)
							}
					}

					NSGridView.Row {
						NSTextField(label: "using background:")

						NSButton()
							.padding()
							.background(
								Capsule()
									.fill(color: .systemOrange)
									.stroke(.textColor, lineWidth: 4)
							)

						HStack {
							VStack(alignment: .leading, spacing: 2) {
								NSTextField(label: "Distance")
									.font(.headline)
								NSTextField(label: "12.5 MI")
									.font(.body)
							}
							VDivider()
							VStack(alignment: .leading, spacing: 2) {
								NSTextField(label: "Training Effort")
									.font(.headline)
								NSTextField(label: "Moderate")
									.font(.body)
							}
						}
						.padding(top: 4, left: 20, bottom: 4, right: 20)
						.background(
							Capsule()
								.fill(color: .quaternaryLabelColor)
								.stroke(.tertiaryLabelColor, lineWidth: 1)
						)
					}
				}
				.columnAlignment(.trailing, forColumn: 0)
				.rowPlacement(.center, forRowIndex: 0)
				.rowPlacement(.center, forRowIndex: 1)
				.huggingPriority(.defaultHigh, for: .horizontal)

				HDivider()


				HStack {
					NSButton(title: "Solid background")
						.isBordered(false)
						.font(.body.bold)
						.padding(8)
						.background(
							Capsule()
								.fill(color: .systemPink)
						)
					NSButton(title: "Gradient background")
						.isBordered(false)
						.font(.body.bold)
						.padding(8)
						.background(
							Capsule()
								.fill(.gradient(color: .systemPink))
						)

					NSButton(title: "Color background")
						.isBordered(false)
						.font(.body.bold)
						.padding(8)
						.background(
							Capsule()
								.fill(color: color)
						)

					NSColorWell()
						.color(color)
				}

				Rectangle(cornerRadius: 16)
					.huggingPriority(.defaultLow, for: .horizontal)
					.compressionResistancePriority(.init(10), for: .horizontal)
					.fill(.checkerboard(color1: .red.alpha(0.2), color2: .blue.alpha(0.2), dimension: 16))
					.stroke(.secondaryLabelColor, lineWidth: 1)
					.height(50)
			}
			.padding()
		}
	}
}

#if DEBUG
@available(macOS 14, *)
#Preview("Basic", traits: .fixedLayout(width: 600, height: 1200)) {
	ShapesPane().make(model: Model())
}
#endif
