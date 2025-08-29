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

class ContainerPane: Pane {
	override func title() -> String { "Layout Container" }
	@MainActor
	override func make(model: Model) -> NSView {
		let select = Bind<Int?>(1)
		return ScrollView(borderType: .noBorder) {
			NSView(layoutStyle: .fill) {
				LayoutContainer {
					NSButton(title: "Reset all results")
					NSTextField(label: "Do the funky chicken")
					HStack {
						AUIColorSelector()
							.selection(select)
						NSButton()
							.image(NSImage(named: NSImage.stopProgressTemplateName)!)
							.imagePosition(.imageOnly)
							.isBordered(false)
							.onAction { _ in
								select.wrappedValue = nil
							}
					}
					NSTextField(link: URL(fileURLWithPath: "https://developer.apple.com/"), title: "Apple Developer")
					NSImageView(imageNamed: "NSToolbarBookmarks")
				}
				.debugFrames()

				// Top leading in the container
				.constraint(fromIndex: 0, attribute: .top, relatedBy: .equal, attribute: .top, constant: 20)
				.constraint(fromIndex: 0, attribute: .leading, relatedBy: .equal, attribute: .leading, constant: 20)

				.constraint(fromIndex: 1, attribute: .leading, relatedBy: .greaterThanOrEqual, toIndex: 0, attribute: .trailing, constant: 20)
				.constraint(fromIndex: 1, attribute: .top, relatedBy: .equal, toIndex: 0, attribute: .bottom, constant: 10, priority: .defaultHigh)
				.constraint(fromIndex: 1, attribute: .trailing, relatedBy: .equal, attribute: .trailing, constant: -40)

				.constraint(fromIndex: 2, attribute: .centerX, relatedBy: .equal, attribute: .centerX)
				.constraint(fromIndex: 2, attribute: .top, relatedBy: .equal, toIndex: 1, attribute: .bottom, constant: 20)
				.constraint(fromIndex: 2, attribute: .bottom, relatedBy: .equal, attribute: .bottom, constant: -20)

				// Bottom trailing in the parent
				.constraint(fromIndex: 3, attribute: .trailing, relatedBy: .equal, attribute: .trailing, constant: -4)
				.constraint(fromIndex: 3, attribute: .bottom, relatedBy: .equal, attribute: .bottom, constant: -4)

				// Centered in parent, leading edge to the trailing edge of the NSButton
				.constraint(fromIndex: 4, attribute: .centerY, relatedBy: .equal, attribute: .centerY)
				.constraint(fromIndex: 4, attribute: .leading, relatedBy: .equal, toIndex: 0, attribute: .trailing)

				.padding()
			}
		}
	}
}

#if DEBUG
@available(macOS 14, *)
#Preview("Basic") {
	ContainerPane().make(model: Model())
}
#endif
