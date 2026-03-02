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

class MenuPane: Pane {
	override func title() -> String { "Menu examples" }
	@MainActor
	override func make(model: Model) -> NSView {
		NSView(layoutStyle: .centered) {
			VStack(spacing: 12) {
				makeColorPaletteMenuItemSingleSelection(model: model)
				makeColorPaletteMenuItemMultipleSelection(model: model)
				HDivider()
				makeViewMenuItem(model: model)
			}
			.equalWidths(["popup1", "popup2"])
		}
	}
}

@MainActor
func makeColorPaletteMenuItemSingleSelection(model: Model) -> NSView {
	if #available(macOS 14.0, *) {
		let selected = Bind(Set<Int>()) { n in Swift.print(".binding: \(n)") }
		return HStack {
			NSPopUpButton()
				.menu(
					NSMenu(title: "title") {
						NSMenuItem(title: "Single select color")
						NSMenuItem.sectionHeader("Single selection")

						NSMenuItem.palette([.systemRed, .systemGreen, .systemBlue, .systemYellow], selectionMode: .selectOne)
							.onStateImage(NSImage(systemSymbolName: "lightswitch.on")!)
							.offStateImage(NSImage(systemSymbolName: "lightswitch.off")!)
							.selection(selected)
							.onSelectionChange { newSelection in
								model.log("Second palette changed selection to \(newSelection)")
							}
					}
				)
				.identifier("popup1")

			NSTextField(content: selected.oneWayTransform { "\($0)" })
				.font(.monospaced)
				.width(150)

			NSButton(title: "Reset") { _ in
				selected.wrappedValue = Set()
			}
		}
	}
	else {
		return NSView.empty
	}
}

@MainActor
func makeColorPaletteMenuItemMultipleSelection(model: Model) -> NSView {
	if #available(macOS 14.0, *) {
		let selected = Bind(Set(arrayLiteral: 2)) { n in Swift.print(".binding: \(n)") }
		return HStack {
			NSPopUpButton()
				.menu(
					NSMenu(title: "title") {
						NSMenuItem(title: "Multiple select color")
						NSMenuItem.sectionHeader("Multiple selection")
						NSMenuItem.palette([.systemRed, .systemGreen, .systemBlue, .systemYellow])
							.selection(selected)
							.onSelectionChange { newSelection in
								model.log("First palette changed selection to \(newSelection)")
							}
					}
				)
				.identifier("popup2")

			NSTextField(content: selected.oneWayTransform { "\($0)" })
				.font(.monospaced)
				.width(150)

			NSButton(title: "Reset") { _ in
				selected.wrappedValue = Set()
			}
		}
	}
	else {
		return NSView.empty
	}
}

@MainActor
func makeViewMenuItem(model: Model) -> NSView {
	let val = Bind(0.33)
	let color = Bind(NSColor(hue: val.wrappedValue, saturation: 1, brightness: 1, alpha: 1))
	return NSPopUpButton()
		.menu(
			NSMenu(title: "title") {
				NSMenuItem(title: "Custom hue")
				NSMenuItem.separator()
				NSMenuItem.view {
					HStack {
						NSTextField(label: "Hue:")
							.compressionResistancePriority(.required, for: .horizontal)
						Rectangle(cornerRadius: 4)
							.frame(dimension: 18)
							.fill(color: color)
							.shadow(offset: CGSize(width: 1, height: -1), color: .black.alpha(0.6), blurRadius: 0.5)

						NSSlider(val, range: 0.0 ... 1.0)
							.numberOfTickMarks(9, allowsTickMarkValuesOnly: true)
							.tickMarkPosition(.below)
							.onChange { newValue in
								color.wrappedValue = NSColor(hue: newValue, saturation: 1, brightness: 1, alpha: 1)
							}
							.controlSize(.small)
							.width(120, priority: .defaultHigh)

						NSButton.image(NSImage(named: NSImage.refreshTemplateName)!)
							.bezelStyle(.circular)
							.isBordered(true)
							.onAction { _ in
								val.wrappedValue = 0.33
								color.wrappedValue = NSColor(hue: 0.33, saturation: 1, brightness: 1, alpha: 1)
							}
					}
					.padding(top: 4, left: 24, bottom: 4, right: 20)
				}
				NSMenuItem.separator()
				NSMenuItem(title: "Something else")
					.onAction { _ in
						Swift.print("Selected 'Something else'")
					}
			}
		)
}

#if DEBUG
@available(macOS 14, *)
#Preview("Empty") {
	MenuPane().make(model: Model())
}
#endif
