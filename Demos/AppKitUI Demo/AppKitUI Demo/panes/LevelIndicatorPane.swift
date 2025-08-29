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

class LevelIndicatorPane: Pane {
	override func title() -> String { "Level Indicators" }
	@MainActor
	override func make(model: Model) -> NSView {
		let value1 = Bind(2.0)
		let value2 = Bind(66.0)
		let value3 = Bind(7.0)
		let value4 = Bind(7.0)

		return NSView(layoutStyle: .centered) {
			NSGridView(columnSpacing: 12, rowSpacing: 12) {
				NSGridView.Row {
					NSTextField(label: "Rating:")
						.font(.headline)
					VStack {
						NSLevelIndicator(style: .rating, value: value1, range: 0 ... 5)
							.isEditable(true)
							.width(200)
						NSLevelIndicator(style: .rating, value: value1, range: 0 ... 5)
							.isEditable(true)
							.ratingImage(NSImage(named: NSImage.quickLookTemplateName)!)
							.width(200)
						NSSlider(value1, range: 0 ... 5)
							.numberOfTickMarks(6)
					}
				}

				NSGridView.Row {
					HDivider()
				}
				.mergeCells(0 ... 1)

				NSGridView.Row {
					NSTextField(label: "Continuous:")
						.font(.headline)
					VStack {
						NSLevelIndicator(style: .continuousCapacity, value: value2, range: 0 ... 100)
							.isEditable(true)
							.fillColor(.systemGreen)
							.warning(80, color: .systemYellow)
							.critical(90, color: .systemRed)
							.width(200)
						NSSlider(value2, range: 0 ... 100)
					}
				}

				NSGridView.Row {
					HDivider()
				}
				.mergeCells(0 ... 1)

				NSGridView.Row {
					NSTextField(label: "Discrete:")
						.font(.headline)
					VStack {
						NSLevelIndicator(style: .discreteCapacity, value: value3, range: 0 ... 10)
							.isEditable(true)
							.numberOfTickMarks(13)
							.numberOfMajorTickMarks(3)
							.fillColor(.systemGreen)
							.warning(6, color: .systemYellow)
							.critical(9, color: .systemRed)
							.width(200)
						NSSlider(value3, range: 0 ... 10)
							.numberOfTickMarks(11)
					}
				}

				NSGridView.Row {
					HDivider()
				}
				.mergeCells(0 ... 1)

				NSGridView.Row {
					NSTextField(label: "Relevancy:")
						.font(.headline)
					VStack {
						NSLevelIndicator(style: .relevancy, value: value4, range: 0 ... 10)
						NSSlider(value4, range: 0 ... 10)
					}
				}
			}
			.rowAlignment(.firstBaseline)
			.columnAlignment(.trailing, forColumn: 0)
		}
	}
}

#if DEBUG
@available(macOS 14, *)
#Preview("Basic") {
	LevelIndicatorPane().make(model: Model())
}
#endif
