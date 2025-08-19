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
		return ScrollView(borderType: .noBorder) {
			VStack(spacing: 20) {
				HStack {
					AUIRectangle()
						.fillColor(.systemRed)
						.overlay {
							NSButton()
								.padding()
						}
					AUIRectangle()
						.fillColor(.systemGreen)
						.overlay {
							NSButton()
								.padding()
						}
					AUIRectangle()
						.fillColor(.systemBlue)
						.overlay {
							NSButton()
								.padding()
						}
					AUIRectangle()
						.fillColor(.quaternaryLabelColor)
						.overlay {
							NSButton()
								.padding()
						}
				}

				HStack {
					AUIRectangle()
						.fillColor(.systemRed)
						.cornerRadius(4)
						.stroke(.textColor, lineWidth: 2)
						.overlay {
							NSButton()
								.padding()
						}
					AUIRectangle()
						.fillColor(.systemGreen)
						.cornerRadius(8)
						.stroke(.textColor, lineWidth: 4)
						.overlay {
							NSButton()
								.padding()
						}
					AUIRectangle()
						.fillColor(.systemBlue)
						.cornerRadius(12)
						.stroke(.textColor, lineWidth: 6)
						.overlay {
							NSButton()
								.padding()
						}
					AUIRectangle()
						.fillColor(.quaternaryLabelColor)
						.cornerRadius(16)
						.stroke(.textColor, lineWidth: 8)
						.overlay {
							NSButton()
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
						AUICapsule()
							.fillColor(.systemOrange)
							.stroke(.textColor, lineWidth: 4)
							.overlay(
								NSButton()
									.padding()
							)

						AUICapsule()
							.fillColor(.quaternaryLabelColor)
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
								AUICapsule()
									.fillColor(.systemOrange)
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
							AUICapsule()
								.fillColor(.quaternaryLabelColor)
								.stroke(.tertiaryLabelColor, lineWidth: 1)
						)
					}
				}
				.columnAlignment(.trailing, forColumn: 0)
				.rowPlacement(.center, forRowIndex: 0)
				.rowPlacement(.center, forRowIndex: 1)
				.huggingPriority(.defaultHigh, for: .horizontal)
			}
			.padding()
		}
	}
}

#if DEBUG
@available(macOS 14, *)
#Preview("Basic") {
	ShapesPane().make(model: Model())
}
#endif
