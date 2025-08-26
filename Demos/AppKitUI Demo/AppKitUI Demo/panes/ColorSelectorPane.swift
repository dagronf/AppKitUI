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

class ColorSelectorPane: Pane {
	override func title() -> String { "Color Selector" }
	@MainActor
	override func make(model: Model) -> NSView {

		let singleSelect = Bind<Int?>(0)
		let multiselect = Bind(Set([0, 2, 4, 6]))
		let rgbselect = Bind<Int?>(nil)
		let isEnabled = Bind(true)

		let editableColors = Bind([
			NSColor(red: 0.969, green: 0.552, blue: 0.379, alpha: 1.000),
			NSColor(red: 0.919, green: 0.130, blue: 0.392, alpha: 1.000),
			NSColor(red: 0.391, green: 0.054, blue: 0.373, alpha: 1.000),
			NSColor(red: 0.050, green: 0.069, blue: 0.392, alpha: 1.000),
		])

		let largeExample: NSView = {
			if #available(macOS 11.0, *) {
				AUIColorSelector()
					.controlSize(.large)
			}
			else {
				NSView()
			}
		}()

		let menuColors = Bind(Set([1, 4]))

		return ScrollView(borderType: .noBorder) {
			NSView(layoutStyle: .centered) {
				NSGridView(rowSpacing: 12) {
					NSGridView.Row {
						NSTextField(label: "Single selection:")
						HStack {
							AUIColorSelector()
								.selection(singleSelect)
								.onSelectionChange {
									model.log("Single selection is now \($0)")
								}
							NSButton()
								.image(NSImage(named: NSImage.stopProgressTemplateName)!)
								.imagePosition(.imageOnly)
								.isBordered(false)
								.onAction { _ in
									singleSelect.wrappedValue = nil
								}
						}
						NSTextField(content: singleSelect.debugString() )
							.width(200)
					}

					NSGridView.Row {
						NSTextField(label: "Multiple selection:")
						HStack {
							AUIColorSelector()
								.allowsMultipleSelection(true)
								.selections(multiselect)
								.onSelectionChange {
									model.log("Multiple selection is now \($0)")
								}
							NSButton(title: "Reset")
								.bezelStyle(.accessoryBar)
								.controlSize(.small)
								.onAction { _ in
									multiselect.wrappedValue = Set()
								}
						}
						NSTextField(content: multiselect.debugString())
							.width(200)
					}

					NSGridView.Row {
						NSTextField(label: "Color selection:")
						HStack {
							AUIColorSelector()
								.selection(rgbselect)
								.colors([.systemRed, .systemGreen, .systemBlue])
								.onSelectionChange {
									model.log("Color selection is now \($0)")
								}
							NSButton()
								.image(NSImage(named: NSImage.stopProgressTemplateName)!)
								.imagePosition(.imageOnly)
								.isBordered(false)
								.onAction { _ in
									rgbselect.wrappedValue = nil
								}
						}
						NSTextField(content: rgbselect.debugString())
							.width(200)
					}

					NSGridView.Row {
						NSTextField(label: "Enabled:")
						VStack(alignment: .leading) {
							VStack {
								AUIColorSelector()
									.isEnabled(isEnabled)
								AUIColorSelector()
									.allowsMultipleSelection(true)
									.isEnabled(isEnabled)
							}
							NSButton(checkboxWithTitle: "Enable the control")
								.state(isEnabled)
						}
						NSGridCell.emptyContentView
					}
					.rowAlignment(.firstBaseline)

					NSGridView.Row {
						NSTextField(label: "Color changing:")
						VStack(alignment: .leading) {
							AUIColorSelector()
								.colors(editableColors)
							NSButton(title: "Reverse colors")
								.onAction { _ in
									editableColors.wrappedValue = editableColors.wrappedValue.reversed()
								}
						}
						NSGridCell.emptyContentView
					}

					NSGridView.Row {
						NSTextField(label: "Control size:")

						NSBox {
							NSGridView {
								NSGridView.Row {
									NSTextField(label: "large:")
										.font(.subheadline)
										.textColor(.secondaryLabelColor)
									largeExample
								}

								NSGridView.Row {
									HDivider()
								}
								.mergeCells(0 ... 1)

								NSGridView.Row {
									NSTextField(label: "regular:")
										.font(.subheadline)
										.textColor(.secondaryLabelColor)
									AUIColorSelector()
										.controlSize(.regular)
								}

								NSGridView.Row {
									HDivider()
								}
								.mergeCells(0 ... 1)

								NSGridView.Row {
									NSTextField(label: "small:")
										.font(.subheadline)
										.textColor(.secondaryLabelColor)
									AUIColorSelector()
										.controlSize(.small)
								}

								NSGridView.Row {
									HDivider()
								}
								.mergeCells(0 ... 1)

								NSGridView.Row {
									NSTextField(label: "mini:")
										.font(.subheadline)
										.textColor(.secondaryLabelColor)
									AUIColorSelector()
										.controlSize(.mini)
								}
							}
							.rowAlignment(.firstBaseline)
							.columnAlignment(.trailing, forColumn: 0)
							.padding(4)
						}

						NSGridCell.emptyContentView
					}

					NSGridView.Row {
						NSTextField(label: "In menu:")
						NSButton()
							.onActionMenu(
								NSMenu {
									NSMenuItem(title: "Move to Bin")
									NSMenuItem(title: "Eject")
									NSMenuItem.separator()
									NSMenuItem()
										.view {
											HStack(spacing: 12) {
												NSButton()
													.image(NSImage(named: NSImage.stopProgressTemplateName)!)
													.imagePosition(.imageOnly)
													.isBordered(false)
													.onAction { _ in
														menuColors.wrappedValue = Set()
													}
												AUIColorSelector()
													.colors([.systemRed, .systemYellow, .systemOrange, .systemGreen, .systemPurple, .systemBlue])
													.allowsMultipleSelection(true)
													.selections(menuColors)
											}
											.padding(12)
										}
									NSMenuItem(title: "Tags…")
										.onAction { _ in
											Swift.print("Tags menu")
										}
								}
							)
						NSGridCell.emptyContentView
					}
				}
				.columnSpacing(12)
				.rowAlignment(.firstBaseline)
				.columnAlignment(.trailing, forColumn: 0)
			}
			.padding()
		}
		//.debugFrames()
	}
}

#if DEBUG
@available(macOS 14, *)
#Preview("Empty") {
	ColorSelectorPane().make(model: Model())
}
#endif
