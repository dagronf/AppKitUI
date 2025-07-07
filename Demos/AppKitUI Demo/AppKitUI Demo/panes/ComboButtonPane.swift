//
//  EmptyPane.swift
//  AppKitUI Demo
//
//  Created by Darren Ford on 17/7/2025.
//

import AppKit
import AppKitUI

class ComboButtonPane: Pane {
	override func title() -> String { "Combo Buttons" }
	@MainActor
	override func make(model: Model) -> NSView {
		let title = Bind("Title")
		let _debugImage = NSImage(named: NSImage.colorPanelName)!

		return VStack {
			HStack {
				AUIComboButton(title: "This has an attached menu") { _ in
					model.log("activated!")
				}
				.menu(
					NSMenu(title: "title") {
						NSMenuItem(title: "first")
							.image(systemSymbolName: "0.circle")
							.onAction { _ in model.log("Selected the first one") }
						NSMenuItem(title: "second")
							.image(systemSymbolName: "1.circle")
							.onAction { _ in model.log("Selected the second one") }
					}
				)

				AUIComboButton(title: "Wheeee!") { _ in
					model.log("activated!")
				}
				.isEnabled(false)
			}

			HStack {
				AUIComboButton(title: "No menu", style: .unified) { _ in
					model.log("No menu activated!")
				}

				AUIComboButton(title: "Has a menu", style: .unified) { _ in
					model.log("activated!")
				}
				.menu {
					NSMenuItem(title: "first")
						.image(systemSymbolName: "0.circle")
						.onAction { _ in model.log("selected 'first'") }
					NSMenuItem(title: "second")
						.image(systemSymbolName: "1.circle")
						.onAction { _ in model.log("selected 'second'") }
				}

				AUIComboButton(title: "Disabled", style: .unified) { _ in
					model.log("activated!")
				}
				.isEnabled(false)
			}

			HStack {
				{
					if #available(macOS 11, *) {
						AUIComboButton(title: "Image!")
							.controlSize(.large)
							.image(_debugImage)
							.onAction { _ in
								model.log("large activated!")
							}
					}
					else {
						NSView.empty
					}
				}()
				AUIComboButton(title: "Image!")
					.image(_debugImage)
					.onAction { _ in
						model.log("regular activated!")
					}
				AUIComboButton(title: "Image!")
					.controlSize(.small)
					.font(.systemSmall)
					.image(_debugImage)
					.onAction { _ in
						model.log("small activated!")
					}
				AUIComboButton(title: "Image!")
					.controlSize(.mini)
					.font(.systemMini)
					.image(_debugImage)
					.onAction { _ in
						model.log("mini activated!")
					}
			}

			HStack {
				NSTextField(label: title)
					.isEditable(true)
					.isBezeled(true)
					.width(150)
				AUIComboButton(title: "")
					.title(title)
			}

		}
		.padding()
	}
}

#if DEBUG
@available(macOS 14, *)
#Preview("Default") {
	ComboButtonPane().make(model: Model())
}
#endif
