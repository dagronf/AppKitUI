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

class MenuPane: Pane {
	override func title() -> String { "Menu examples" }
	@MainActor
	override func make(model: Model) -> NSView {
		
		if #available(macOS 14.0, *) {
			let selected = Bind(Set(arrayLiteral: 2)) { n in Swift.print(".binding: \(n)") }
			let selected2 = Bind(Set<Int>()) { n in Swift.print(".binding2: \(n)") }

			return NSView(layoutStyle: .centered) {
				VStack {
					HStack {
						NSPopUpButton()
							.menu(
								NSMenu(title: "title") {
									NSMenuItem(title: "Color palette menu item examples")
									NSMenuItem.sectionHeader("Multiple selection")
									NSMenuItem.colorPalette([.systemRed, .systemGreen, .systemBlue, .systemYellow])
										.selection(selected)
										.onSelectionChange { newSelection in
											model.log("First palette changed selection to \(newSelection)")
										}

									NSMenuItem.sectionHeader("Single selection")

									NSMenuItem.colorPalette([.systemRed, .systemGreen, .systemBlue, .systemYellow], selectionMode: .selectOne)
										.onStateImage(NSImage(systemSymbolName: "lightswitch.on")!)
										.offStateImage(NSImage(systemSymbolName: "lightswitch.off")!)
										.selection(selected2)
										.onSelectionChange { newSelection in
											model.log("Second palette changed selection to \(newSelection)")
										}
								}
							)
						NSButton(title: "Reset selection") { _ in
							selected.wrappedValue = Set()
							selected2.wrappedValue = Set()
						}
						.isEnabled(selected.oneWayTransform { $0.count > 0 } )
					}
				}
			}
		}
		else {
			return NSView.empty
		}
	}
}

#if DEBUG
@available(macOS 14, *)
#Preview("Empty") {
	MenuPane().make(model: Model())
}
#endif
