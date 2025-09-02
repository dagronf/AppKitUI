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

class DockExamplePane: Pane {
	override func title() -> String { "Dock example" }
	@MainActor
	override func make(model: Model) -> NSView {

		let dockSize = Bind(0.4)
		let docMagnification = Bind(0.75)
		let magnificationEnabled = Bind(true)
		let position = Bind(1)

		return VStack(alignment: .leading, spacing: 16) {
			HStack(spacing: 20) {
				VStack(alignment: .leading, spacing: 4) {
					NSTextField(label: "Size:")
						.huggingPriority(.init(1), for: .horizontal)
					NSSlider(dockSize, range: 0 ... 1)
						.numberOfTickMarks(2)
					HStack {
						NSTextField(label: "Small")
							.font(.caption2)
							.gravityArea(.leading)
						NSView.Spacer()
						NSTextField(label: "Large")
							.font(.caption2)
							.gravityArea(.trailing)
					}
				}
				.hugging(.init(10), for: .horizontal)

				VStack(alignment: .leading, spacing: 4) {
					NSButton.checkbox(title: "Magnification:")
						.state(magnificationEnabled)
						.huggingPriority(.init(1), for: .horizontal)
					NSSlider(docMagnification, range: 0 ... 1)
						.huggingPriority(.defaultLow, for: .horizontal)
						.numberOfTickMarks(2)
						.isEnabled(magnificationEnabled)
					HStack {
						NSTextField(label: "Small")
							.font(.caption2)
							.gravityArea(.leading)
						NSView.Spacer()
						NSTextField(label: "Large")
							.font(.caption2)
							.gravityArea(.trailing)
					}
				}
				.hugging(.init(10), for: .horizontal)
			}
			.distribution(.fillEqually)
			//.hugging(.init(10), for: .horizontal)

			NSBox {
				VStack(alignment: .leading) {
					HStack {
						NSTextField(label: "Position on screen")
							.gravityArea(.leading)
						NSView.Spacer()
						NSPopUpButton()
							.alignment(.right)
							.menuItems(["Left", "Bottom", "Right"])
							.gravityArea(.trailing)
							.selectedIndex(position)
					}
					.onChange(position) { newValue in
						let text = "Position on screen changed: \(newValue)"
						model.log(text)
					}

					HDivider()

					HStack {
						NSTextField(label: "Minimise windows using")
							.gravityArea(.trailing)
						NSView.Spacer()
						NSPopUpButton()
							.alignment(.right)
							.menuItems(["Genie Effect", "Scale Effect"])
							.gravityArea(.trailing)
					}

					HDivider()

					HStack {
						NSTextField(label: "Double-click a window's title bar to")
							.gravityArea(.trailing)
						NSView.Spacer()
						NSPopUpButton()
							.alignment(.right)
							.menu {
								NSMenuItem(title: "Fill")
								NSMenuItem(title: "Zoom")
								NSMenuItem(title: "Minimise")
								NSMenuItem.separator()
								NSMenuItem(title: "Do Nothing")
							}
							.gravityArea(.trailing)
					}

					HDivider()

					HStack {
						NSTextField(label: "Minimise windows into application icon")
							.gravityArea(.leading)
						NSView.Spacer()
						AUISwitch()
							.controlSize(.mini)
							.gravityArea(.trailing)
					}
				}
				.padding(8)
			}
			.formSemanticContent()
			.titlePosition(.noTitle)
			.huggingPriority(.defaultLow, for: .horizontal)
		}
		.hugging(.defaultHigh, for: .horizontal)
		//.debugFrames()
		.padding()
	}
}

#if DEBUG
@available(macOS 14, *)
#Preview("Basic") {
	DockExamplePane().make(model: Model())
}
#endif
