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

class PageControlPane: Pane {
	override func title() -> String { "Page Control" }
	@MainActor
	override func make(model: Model) -> NSView {
		let c0 = Bind(5)
		let c1 = Bind(2)
		let d1 = c1.twoWayTransform(BindTransformers.IntToDouble())
		let c2 = Bind(1)
		return ScrollView(borderType: .noBorder) {
			NSView(layoutStyle: .centered) {
				VStack {
					NSGridView {
						NSGridView.Row {
							NSTextField(labelWithString: "pages")
							NSTextField(labelWithString: "window")
							NSTextField(labelWithString: "control")
							NSTextField(labelWithString: "value")
						}
						NSGridView.Row {
							NSTextField(labelWithString: "7")
							NSTextField(labelWithString: "7")
							VStack {
								AUIPageControl(numberOfPages: 7, windowSize: 7, currentPage: c0)
									.onSelectedPageChange { newPage in
										model.log("page control selection is now \(newPage)")
									}

								AUIPageControl(pageIndicatorSize: CGSize(width: 16, height: 16), numberOfPages: 7, windowSize: 7, currentPage: c0)
									.isKeyboardNavigable(true)
									.pageIndicatorTintColor(.systemOrange)
									.currentPageIndicatorTintColor(.systemGreen)
							}
							NSTextField(value: c0)
								.alignment(.right)
						}
						NSGridView.Row {
							NSTextField(labelWithString: "10")
							NSTextField(labelWithString: "7")
							AUIPageControl(numberOfPages: 10, windowSize: 7)
								.currentPage(c1)
							HStack {
								NSTextField(value: c1)
									.alignment(.right)
									.width(50)
								NSStepper(value: d1, range: 0 ... 9)
							}
						}
						NSGridView.Row {
							NSTextField(labelWithString: "2")
							NSTextField(labelWithString: "2")
							AUIPageControl(numberOfPages: 2, windowSize: 2, currentPage: c2)
							NSTextField(value: c2)
								.alignment(.right)
						}
					}
					.columnAlignment(.center, forColumns: 0 ... 2)
					.columnWidth(80, forColumn: 3)
				}
			}
		}
	}
}

#if DEBUG
@available(macOS 14, *)
#Preview("page control") {
	PageControlPane().make(model: Model())
}
#endif
