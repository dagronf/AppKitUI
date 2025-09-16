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

class SimpleDropPane: Pane {
	override func title() -> String { "Basic Drop" }
	@MainActor
	override func make(model: Model) -> NSView {
		NSView(layoutStyle: .centered) {
			NSGridView(yPlacement: .center) {
				NSGridView.Row {
					let droppable = Bind(false)
					let droppableColor = droppable.oneWayTransform { $0 ? NSColor.systemGreen : NSColor.systemGray }

					NSTextField(label: "Drop a file:")
						.font(.headline)
					Rectangle(cornerRadius: 8)
						.fill(color: droppableColor)
						.frame(dimension: 64)

						.overlay(
							AUIDropView()
								.isDroppable(droppable)
								.registeredTypes([.fileURL])
								.onDragEntered { sender in
									return .link
								}
								.onDragPrepareForDragOperation { sender in
									return true
								}
								.onDragPerformOperation { sender in
									let furl = sender.files()
									Swift.print("drag operation -> \(furl)")
									return true
								}
						)
				}
			}
		}
	}
}

#if DEBUG
@available(macOS 14, *)
#Preview("Empty") {
	SimpleDropPane().make(model: Model())
}
#endif
