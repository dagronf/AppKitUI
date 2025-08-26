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

class GridPane: Pane {
	override func title() -> String { "Grid" }
	@MainActor
	override func make(model: Model) -> NSView {
		NSView(layoutStyle: .centered) {
			let firstName = Bind("Caterpillar")
			let lastName = Bind("Jones")
			return VStack {
				NSGridView(columnSpacing: 2, rowSpacing: 8) {
					NSGridView.Row {
						NSTextField(labelWithString: "First Name:")
						NSTextField(labelWithString: "*")
							.textColor(.systemRed)
						NSTextField()
							.content(firstName)
							.width(200)
							.huggingPriority(.defaultLow, for: .horizontal)
							.compressionResistancePriority(.defaultLow, for: .horizontal)
							.onChange { newValue in
								Swift.print("Cell -> \(newValue)")
							}
					}
					NSGridView.Row {
						NSTextField(labelWithString: "Last Name:")
						NSTextField(labelWithString: "*")
							.textColor(.systemRed)
						NSTextField()
							.content(lastName)
							.width(200)
							.huggingPriority(.defaultLow, for: .horizontal)
							.compressionResistancePriority(.defaultLow, for: .horizontal)
					}

					NSGridView.Row {
						HDivider()
					}
					.mergeCells(0 ... 2)

					NSGridView.Row {
						NSTextField(labelWithString: "Email Address:")
						NSTextField(labelWithString: "*")
							.textColor(.systemRed)
						NSTextField()
							.width(200)
							.huggingPriority(.defaultLow, for: .horizontal)
							.compressionResistancePriority(.defaultLow, for: .horizontal)
					}
					NSGridView.Row {
						NSTextField(labelWithString: "Phone:")
						NSGridCell.emptyContentView
						NSTextField()
							.width(200)
							.huggingPriority(.defaultLow, for: .horizontal)
							.compressionResistancePriority(.defaultLow, for: .horizontal)
					}
					NSGridView.Row {
						NSTextField(labelWithString: "Fax:")
						NSGridCell.emptyContentView
						NSTextField()
							.width(200)
							.huggingPriority(.defaultLow, for: .horizontal)
							.compressionResistancePriority(.defaultLow, for: .horizontal)
					}

					NSGridView.Row {
						NSTextField(labelWithString: "Sector:")
						NSTextField(labelWithString: "*")
							.textColor(.systemRed)
						NSPopUpButton()
							.menuItems(["Astronomy", "University", "Wombles"])
							.huggingPriority(.init(10), for: .horizontal)
					}

					NSGridView.Row {
						NSGridCell.emptyContentView
						NSTextField(labelWithString: "*")
							.textColor(.systemRed)
						NSTextField(labelWithString: "indicates a required field")
					}

					NSGridView.Row {
						HDivider()
					}
					.mergeCells(0 ... 2)

					NSGridView.Row {
						NSButton.checkbox(title: "All cells merged")
					}
					.mergeCells(0 ... 2)
				}
				.rowAlignment(.firstBaseline)
				.columnAlignment(.trailing, forColumn: 0)
				.columnWidth(200, forColumn: 2)
				.cell(atColumnIndex: 0, rowIndex: 9, xPlacement: .center)

				HDivider()

				NSTextField(label: "NOTE: for macOS 10.13, you need to manually set the size of text fields within a grid cell, as autolayout doesn't seem to correctly set the size of a textfield within a grid cell")
					.font(.caption1)
					.textColor(.secondaryLabelColor)
					.huggingPriority(.init(10), for: .horizontal)
					.compressionResistancePriority(.init(10), for: .horizontal)
			}

			.onChange(firstName) { newValue in
				Swift.print(newValue)
			}
		}
	}
}

#if DEBUG
@available(macOS 14, *)
#Preview("Basic Grid") {
	GridPane().make(model: Model())
}
#endif
