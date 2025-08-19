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

		let showContractedBraille = Bind(false)
		let showEightDotBraille = Bind(false)

		return NSView(layoutStyle: .centered) {
			VStack(spacing: 16) {

				VStack {
					NSGridView {
						NSGridView.Row(rowAlignment: .firstBaseline) {
							NSTextField(label: "Braille Translation:")
								.font(.system.weight(.medium))
							NSPopUpButton()
								.menu {
									NSMenuItem(title: "English (Unified)")
									NSMenuItem(title: "United States")
								}
						}
						NSGridView.Row {
							NSGridCell.emptyContentView
							NSButton(checkboxWithTitle: "Show Contracted Braille")
								.state(showContractedBraille)

						}
						NSGridView.Row {
							NSGridCell.emptyContentView
							NSButton(checkboxWithTitle: "Show Eight Dot Braille")
								.state(showEightDotBraille)
						}
						NSGridView.Row(rowAlignment: .firstBaseline) {
							NSTextField(label: "Status Cells:")
								.font(.system.weight(.medium))
							NSButton(checkboxWithTitle: "Show General Display Status")
						}
						NSGridView.Row {
							NSGridCell.emptyContentView
							NSButton(checkboxWithTitle: "Show Text Style")
						}
						NSGridView.Row {
							NSGridCell.emptyContentView
							NSButton(checkboxWithTitle: "Show alert messages for duration")
						}
					}
					//.rowSpacing(8)
					.columnAlignment(.trailing, forColumn: 0)
					.columnSpacing(8)
					.rowAlignment(.firstBaseline)
					//.debugFrames(.systemYellow)
				}
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
