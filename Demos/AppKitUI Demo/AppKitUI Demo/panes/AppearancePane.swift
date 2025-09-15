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

class AppearancePane: Pane {
	override func title() -> String { "Appearance" }
	@MainActor
	override func make(model: Model) -> NSView {
		let b = Bind(true)
		let b2 = Bind(true)

		let d1 = DynamicColor(dark: .systemRed, light: .systemBlue)
		let d2 = DynamicColor(dark: .systemYellow, light: .systemGreen)

		return NSView(layoutStyle: .centered) {
			VStack {
				NSBox(title: "Standard dark/light mode changes") {
					HStack {
						NSView()
							.frame(dimension: 80)
							.backgroundFill(.textBackgroundColor)
							.backgroundBorder(.textColor, lineWidth: 0.5)
						Rectangle()
							.frame(dimension: 80)
							.fill(color: .textBackgroundColor)
							.stroke(.textColor, lineWidth: 0.5)
						VDivider()
						NSView()
							.frame(dimension: 80)
							.backgroundFill(d1)
							.backgroundBorder(d2, lineWidth: 4)
						Rectangle()
							.frame(dimension: 80)
							.fill(color: d1)
							.stroke(d2, lineWidth: 4)
					}
				}

				NSBox(title: "Attaching dark mode binding directly on each view") {
					VStack(alignment: .leading) {
						NSButton.checkbox(title: "Dark Mode")
							.state(b)
						HStack {
							NSView()
								.frame(dimension: 80)
								.backgroundFill(.textBackgroundColor)
								.backgroundBorder(.textColor, lineWidth: 0.5)
								.isDarkMode(b)
							Rectangle()
								.frame(dimension: 80)
								.fill(color: .textBackgroundColor)
								.stroke(.textColor, lineWidth: 0.5)
								.isDarkMode(b)
							VDivider()
							NSView()
								.frame(dimension: 80)
								.backgroundFill(d1)
								.backgroundBorder(d2, lineWidth: 4)
								.isDarkMode(b)
							Rectangle()
								.frame(dimension: 80)
								.fill(color: d1)
								.stroke(d2, lineWidth: 4)
								.isDarkMode(b)
						}
					}
				}

				NSBox(title: "Attaching dark mode binding on the containing stack") {
					VStack(alignment: .leading) {
						NSButton.checkbox(title: "Dark Mode")
							.state(b2)
						HStack {
							NSView()
								.frame(dimension: 80)
								.backgroundFill(.textBackgroundColor)
								.backgroundBorder(.textColor, lineWidth: 0.5)
							Rectangle()
								.frame(dimension: 80)
								.fill(color: .textBackgroundColor)
								.stroke(.textColor, lineWidth: 0.5)
							VDivider()
							NSView()
								.frame(dimension: 80)
								.backgroundFill(d1)
								.backgroundBorder(d2, lineWidth: 4)
							Rectangle()
								.frame(dimension: 80)
								.fill(color: d1)
								.stroke(d2, lineWidth: 4)
						}
						.isDarkMode(b2)
					}
				}
			}
		}
	}
}

#if DEBUG
@available(macOS 14, *)
#Preview("Empty") {
	AppearancePane().make(model: Model())
		.padding(30)
}
#endif
