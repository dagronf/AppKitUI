//
//  Pane.swift
//  AppKitUI Demo
//
//  Created by Darren Ford on 17/7/2025.
//

import AppKit
import AppKitUI

class ColorWellPane: Pane {
	override func title() -> String { "Color Wells" }
	@MainActor override func make(model: Model) -> NSView {

		let color1 = Bind(NSColor.red)
		let color2 = Bind(NSColor.green)
		let color3 = Bind(NSColor.blue)

		return NSView(layoutStyle: .centered) {
			NSGridView(columnSpacing: 16) {
				NSGridView.Row(rowAlignment: .firstBaseline) {
					NSTextField(label: "Style").font(.title2)
					NSTextField(label: "Bordered").font(.title2)
					NSTextField(label: "No border").font(.title2)
					NSTextField(label: "Disabled").font(.title2)
				}
				NSGridView.Row(rowAlignment: .firstBaseline) {
					NSTextField(label: ".default").font(.monospaced.size(14))
					NSColorWell()
						.color(color1)
						.isBordered(true)
						.frame(width: 60, height: 26)
					NSColorWell()
						.color(color1)
						.isBordered(false)
						.frame(width: 60, height: 26)
					NSColorWell()
						.color(color1)
						.isBordered(false)
						.frame(width: 60, height: 26)
						.isEnabled(false)
				}

				NSGridView.Row(rowAlignment: .firstBaseline) {
					NSTextField(label: ".minimal").font(.monospaced.size(14))
					NSColorWell(colorWellStyle: .minimal)
						.color(color2)
						.isBordered(true)
						.frame(width: 60, height: 26)
					NSColorWell(colorWellStyle: .minimal)
						.color(color2)
						.isBordered(false)
						.frame(width: 60, height: 26)
					NSColorWell(colorWellStyle: .minimal)
						.color(color2)
						.isBordered(false)
						.frame(width: 60, height: 26)
						.isEnabled(false)
				}

				NSGridView.Row(rowAlignment: .firstBaseline) {
					NSTextField(label: ".expanded").font(.monospaced.size(14))
					NSColorWell(colorWellStyle: .expanded)
						.color(color3)
						.isBordered(true)
						.frame(width: 60, height: 26)
					NSColorWell(colorWellStyle: .expanded)
						.color(color3)
						.isBordered(false)
						.frame(width: 60, height: 26)
					NSColorWell(colorWellStyle: .expanded)
						.color(color3)
						.isBordered(false)
						.frame(width: 60, height: 26)
						.isEnabled(false)
				}
			}
		}
		.padding()
	}
}

#if DEBUG
@available(macOS 14, *)
#Preview("Default") {
	ColorWellPane().make(model: Model())
}
#endif
