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

class BasicViewSizingPane: Pane {
	override func title() -> String { "onFrameChange handling" }
	@MainActor
	override func make(model: Model) -> NSView {

		return ScrollView(borderType: .noBorder) {
			VStack {
				NSBox(title: "onFrameChange tester") {
					buildContent()
						.padding(8)
				}
				.padding()
				.huggingPriority(.init(1), for: .horizontal)
				.identifier("1")

				NSView.Spacer()
			}
			.padding()
			.huggingPriority(.init(1), for: .horizontal)
		}
		.identifier("2")
		.equalWidths(["1", "2"])
	}
}

@MainActor
private func buildContent() -> NSView {
	let allString = Bind("")
	let selected = Bind(0)
	return VSplitView(dividerStyle: .thin) {

		AUIRadioGroup()
			.item(title: "all", description: "The callback is called for all frame changes")
			.item(title: "debounce (500ms)", description: "Updates when there have been no changes for the specified time period")
			.item(title: "throttle (500ms)", description: "Updates only once for the specified time period")
			.selectedIndex(selected)
			.identifier("1")
			.width(250, priority: .defaultLow)
			.padding(8)

		AUIViewSwitcher(selectedViewIndex: selected) {

			for which in [DelayingCallType.none, DelayingCallType.debounce(0.5), DelayingCallType.throttle(0.5)] {
				NSView(layoutStyle: .centered) {
					NSTextField(label: allString)
						.alignment(.center)
						.font(.monospacedDigit)
						.huggingPriority(.init(1), for: .horizontal)
						.padding()
				}
				.backgroundFill(.quaternaryLabelColor)
				.backgroundBorder(.tertiaryLabelColor, lineWidth: 0.5)
				.backgroundCornerRadius(8)
				.huggingPriority(.init(10), for: .horizontal)
				.onFrameChange(delayType: which) { frame in
					allString.wrappedValue = "\(frame)"
				}
			}
		}
		.padding(8)
		.identifier("2")
	}
	.equalHeights(["1", "2"])
	.huggingPriority(.init(1), for: .horizontal)
}

#if DEBUG
@available(macOS 14, *)
#Preview("Basic") {
	BasicViewSizingPane().make(model: Model())
}
#endif
