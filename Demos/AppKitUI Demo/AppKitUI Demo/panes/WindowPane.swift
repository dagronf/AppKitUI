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

class WindowPane: Pane {
	override func title() -> String { "Window content" }
	@MainActor
	override func make(model: Model) -> NSView {
		let isWindowVisible = Bind(false)
		let visibleCount = Bind(0)
		let title = Bind("this window")

		let tempWindow = AUIWindow(isVisible: isWindowVisible)
			.title(title)
			.toolbarStyle(.expanded)
			.frameAutosaveName("temporary-window-pane")
			.content {
				NSTextField(label: "which and what \(visibleCount.wrappedValue)")
			}
			.onOpen {
				model.log("temp window did open")
			}
			.onClose {
				model.log("temp window did close")
				visibleCount.wrappedValue += 1
			}

		return VStack {
			HStack {
				NSButton(title: "which", type: .onOff)
					.state(isWindowVisible)
				NSTextField(content: title)
				NSTextField(value: visibleCount)
			}
		}
		.padding()
		.window(tempWindow)
	}
}

#if DEBUG
@available(macOS 14, *)
#Preview("Windows") {
	WindowPane().make(model: Model())
}
#endif
