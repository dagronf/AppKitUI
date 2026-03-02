//
//  Copyright © 2026 Darren Ford. All rights reserved.
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

@MainActor
class DisclosurePane: Pane {

	let auiDisclosure = AUIDisclosureVC()
	let hidableVC = AUIHidableVC()

	override func title() -> String { "Disclosure Views" }
	@MainActor
	override func make(model: Model) -> NSView {
		VSplitView {
			VStack(alignment: .leading) {
				NSTextField(label: "AUIDisclosure")
					.font(.title2)
					.huggingPriority(.defaultLow, for: .horizontal)
				auiDisclosure.view
			}
			.padding(8)

			VStack(alignment: .leading) {
				NSTextField(label: "AUIHidableView")
					.font(.title2)
					.huggingPriority(.defaultLow, for: .horizontal)
				hidableVC.view
			}
			.padding(8)
		}
		.holdingPriority(.init(rawValue: 400), forItemAtIndex: 1)
	}
}

class AUIDisclosureVC: AUIViewController {

	let date = Bind(Date())
	let isVisible = Bind(true)

	override var body: NSView {
		ScrollView(borderType: .noBorder, fitHorizontally: true) {
			VStack(spacing: 2) {
				AUIDisclosure(title: "First one") {
					HStack {
						NSButton(title: "Wheeeee")
						Spacer()
						NSButton.checkbox(title: "Caterpillar and noodles")
					}
				}
				.font(.title3.weight(.semibold))
				.titleHeight(24)
				.state(isVisible)

				HDivider()

				AUIDisclosure(title: "Second one") {
					VStack {
						NSDatePicker(date: self.date, style: .clockAndCalendar)
							.elements([.yearMonthDay])
							.timeZone(TimeZone(identifier: "GMT")!)
					}
					.alignment(.leading)
				}
				.font(.title3.weight(.semibold))
				.titleHeight(24)

				Spacer()
			}
			.padding(8)
		}
	}
}

class AUIHidableVC: AUIViewController {

	let isVisible = Bind(true)
	let isVisible2 = Bind(false)

	override var body: NSView {
		ScrollView(borderType: .noBorder) {
			VStack {
				VStack(spacing: 0) {
					NSButton.checkbox(title: "is visible")
						.state(isVisible)
					AUIHidableView(isVisible: isVisible) {
						VStack {
							AUIImage(named: NSImage.homeTemplateName)
								.frame(dimension: 48)
							NSTextField(label: "Hi there")
								.width(100)
								.alignment(.center)
						}
					}
				}

				HDivider()

				NSButton.checkbox(title: "is visible 2")
					.state(isVisible2)
				AUIHidableView(
					isVisible: isVisible2,
					view:
						AUIRadioGroup()
						.items([
							"one item here",
							"second item here",
							"third? Groundbreaking",
							"fourth of nature",
							"i plead the fifth"
						])
						.padding(8)
				)

				HDivider()

				Spacer()
			}
			.padding(8)
		}
	}
}

#if DEBUG
@available(macOS 14, *)
#Preview("DisclosurePane") {
	DisclosurePane().make(model: Model())
}
#endif
