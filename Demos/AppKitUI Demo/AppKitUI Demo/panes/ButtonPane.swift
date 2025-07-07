//
//  ButtonPane.swift
//  AppKitUI Demo
//
//  Created by Darren Ford on 17/7/2025.
//

import AppKit
import AppKitUI

class ButtonPane: Pane {
	override func title() -> String { "Buttons" }

	override func make(model: Model) -> NSView {
		ScrollView(borderType: .noBorder, fitHorizontally: true) {
			VStack {
				HStack {
					NSButton(title: "default")
					NSButton(title: "default")
						.bezelColor(.systemGreen)
					NSButton(title: "default")
						.keyEquivalent("\r")
				}
				.padding(2)

				HStack {
					NSButton(title: "is red button!")
						.isBordered(false)
						.image(NSImage(named: NSImage.quickLookTemplateName)!.isTemplate(true))
						.imagePosition(.imageLeft)
						.contentTintColor(.systemRed)
					NSButton(title: "is green button!")
						.isBordered(false)
						.image(NSImage(named: NSImage.quickLookTemplateName)!.isTemplate(true))
						.imagePosition(.imageLeft)
						.contentTintColor(.systemGreen)
				}

				HDivider()

				HStack {
					NSButton(title: "accessoryBar")
						.bezelStyle(.accessoryBar)
					NSButton(title: "badge")
						.bezelStyle(.badge)
					NSButton(title: "toolbar")
						.bezelStyle(.toolbar)
				}
				.padding(2)

				HDivider()

				HStack {
					NSButton(title: "flexiblepush\nflexiblepush")
						.bezelStyle(.flexiblePush)
					NSButton(title: "smallSquare\nsmallSquare")
						.bezelStyle(.smallSquare)
					NSButton(title: "texturedSquare\ntexturedSquare")
						.bezelStyle(.texturedSquare)
				}
				.padding(2)

				HDivider()

				HStack {
					NSButton(title: "circular")
						.bezelStyle(.circular)
					NSButton(title: "", type: .onOff)
						.bezelStyle(.disclosure)
					NSButton(title: "", type: .onOff)
						.bezelStyle(.pushDisclosure)
				}
				.padding(2)

				HDivider()

				HStack {
					NSButton(checkboxWithTitle: "checkbox off")
						.state(.off)
					NSButton(checkboxWithTitle: "checkbox mixed")
						.allowsMixedState(true)
						.state(.mixed)
					NSButton(checkboxWithTitle: "checkbox on")
						.state(.on)
				}

				HDivider()

				HStack {
					NSButton.link(title: "Visit Website") { _ in
						model.log("Visit website...")
					}
					NSButton.link(title: "Online Help") { _ in
						model.log("'Online Help' pressed")
					}
					.font(.title2.weight(.ultraLight))
					.toolTip("Online Help")
				}

				HStack {
					NSButton.link(title: "#jupiterone") { _ in
						model.log("Clicked JupiterOne")
					}
					.linkColor(.systemPurple)

					NSButton.link(title: "#jupiterone") { _ in
						model.log("Clicked JupiterOne (disabled)")
					}
					.linkColor(.systemPurple)
					.isEnabled(false)

					NSButton.link(title: "@usergroups") { _ in
						model.log("Clicked @usergroups")
					}
					.image(NSImage(named: NSImage.userGroupName)!.isTemplate(true))
					.imagePosition(.imageAbove)
					.contentTintColor(.systemYellow)
				}

				HDivider()

				HStack(spacing: 20) {
					NSButton.radioGroup()
						.items(["one", "two", "three"])
					NSButton.radioGroup(orientation: .horizontal)
						.items(["eight", "nine", "ten"])
				}
			}
			.padding()
		}
	}
}

#if DEBUG
@available(macOS 14, *)
#Preview("default") {
	ButtonPane().make(model: Model())
		.frame(width: 600, height: 500)
}
#endif
