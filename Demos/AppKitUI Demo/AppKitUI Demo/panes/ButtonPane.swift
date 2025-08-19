//
//  ButtonPane.swift
//  AppKitUI Demo
//
//  Created by Darren Ford on 17/7/2025.
//

import AppKit
import AppKitUI

@MainActor
func StyledHeader(label: String) -> NSTextField {
	NSTextField(label: "\(label):")
		.font(.body.weight(.semibold))
}

class ButtonPane: Pane {
	override func title() -> String { "Buttons" }

	override func make(model: Model) -> NSView {
		let checkBindingState = Bind(NSControl.StateValue.off)
		let image = NSImage(named: NSImage.homeTemplateName)!

		return ScrollView(borderType: .noBorder, fitHorizontally: true) {

			VStack {
				NSGridView(columnSpacing: 8, rowSpacing: 12) {
					NSGridView.Row {
						StyledHeader(label: "Button Styles")
						Flow(minimumLineSpacing: 4, minimumInteritemSpacing: 6) {
							NSButton(title: "push")
								.toolTip("push")
								.bezelStyle(.push)
							NSButton(title: "flexible\nPush")
								.toolTip("flexiblePush")
								.bezelStyle(.flexiblePush)
							NSButton(title: "accessoryBar")
								.toolTip("accessoryBar")
								.bezelStyle(.accessoryBar)
							NSButton(title: "accessoryBarAction")
								.toolTip("accessoryBarAction")
								.bezelStyle(.accessoryBarAction)
							NSButton(title: "badge")
								.toolTip("badge")
								.bezelStyle(.badge)
							NSButton(title: "toolbar")
								.toolTip("toolbar")
								.bezelStyle(.toolbar)
							NSButton(title: "help")
								.toolTip("help")
								.imagePosition(.imageOnly)
								.bezelStyle(.helpButton)
							NSButton(title: "smallSquare")
								.toolTip("smallSquare")
								.bezelStyle(.smallSquare)
							NSButton(title: "circular")
								.toolTip("circular")
								.bezelStyle(.circular)
							NSButton(title: "disclosure")
								.toolTip("disclosure")
								.imagePosition(.imageOnly)
								.bezelStyle(.disclosure)
								.buttonType(.onOff)
							NSButton(title: "pushDisclosure")
								.toolTip("pushDisclosure")
								.imagePosition(.imageOnly)
								.bezelStyle(.pushDisclosure)
								.buttonType(.onOff)
						}
						.padding(8)
						.backgroundBorder(.textColor.withAlphaComponent(0.1), lineWidth: 1)
						.backgroundCornerRadius(8)
					}

					NSGridView.Row {
						StyledHeader(label: "Button image")
						Flow(minimumLineSpacing: 4, minimumInteritemSpacing: 6) {
							NSButton(title: "leading")
								.bezelStyle(.push)
								.image(image)
								.imagePosition(.imageLeading)
							NSButton(title: "above")
								.bezelStyle(.flexiblePush)
								.image(image)
								.imagePosition(.imageAbove)
							NSButton(title: "below")
								.bezelStyle(.flexiblePush)
								.image(image)
								.imagePosition(.imageBelow)
							NSButton(title: "trailing")
								.bezelStyle(.push)
								.image(image)
								.imagePosition(.imageTrailing)
							NSButton(title: "no image")
								.bezelStyle(.push)
								.image(image)
								.imagePosition(.noImage)
							NSButton(title: "image only")
								.bezelStyle(.push)
								.image(image)
								.imagePosition(.imageOnly)
							NSButton(title: "image overlaps")
								.bezelStyle(.push)
								.image(image)
								.imagePosition(.imageOverlaps)
						}
						.padding(8)
						.backgroundBorder(.textColor.withAlphaComponent(0.1), lineWidth: 1)
						.backgroundCornerRadius(8)
					}


					NSGridView.Row {
						StyledHeader(label: "Bezel Colors")
						HStack {
							NSButton(title: "default")
							NSButton(title: "default")
								.bezelColor(.systemGreen)
							NSButton(title: "default")
								.keyEquivalent("\r")
							NSView()
						}
					}

					NSGridView.Row {
						StyledHeader(label: "Image Buttons")
						HStack {
							NSButton(title: "is red button!")
								.isBordered(false)
								.image(NSImage(named: NSImage.quickLookTemplateName)!.isTemplate(true))
								.imagePosition(.imageLeft)
								.contentTintColor(.systemRed)
								.onAction { state in model.log("Clicked red button (state='\(state.stateString)')") }
							NSButton(title: "is green button!")
								.isBordered(false)
								.image(NSImage(named: NSImage.quickLookTemplateName)!.isTemplate(true))
								.imagePosition(.imageLeft)
								.contentTintColor(.systemGreen)
								.onAction { state in model.log("Clicked green button (state='\(state.stateString)')") }
							NSButton(title: "is green button!")
								.isBordered(false)
								.image(NSImage(named: NSImage.quickLookTemplateName)!.isTemplate(true))
								.imagePosition(.imageOnly)
								.contentTintColor(.systemBlue)
								.onAction { state in model.log("Clicked blue button (state='\(state.stateString)')") }
						}
					}

					NSGridView.Row {
						StyledHeader(label: "Flexible heights")
						HStack {
							NSButton(title: "flexiblepush\nflexiblepush")
								.bezelStyle(.flexiblePush)
							NSButton(title: "smallSquare\nsmallSquare")
								.bezelStyle(.smallSquare)
							NSButton(title: "texturedSquare\ntexturedSquare")
								.bezelStyle(.texturedSquare)
						}
					}

					NSGridView.Row {
						StyledHeader(label: "Checkbox")
						VStack {
							HStack {
								NSButton(checkboxWithTitle: "checkbox off")
									.state(.off)
								NSButton(checkboxWithTitle: "checkbox mixed")
									.allowsMixedState(true)
									.state(.mixed)
								NSButton(checkboxWithTitle: "checkbox on")
									.state(.on)
							}
							HStack {
								NSButton(checkboxWithTitle: "checkbox off")
									.state(.off)
									.isEnabled(false)
								NSButton(checkboxWithTitle: "checkbox mixed")
									.allowsMixedState(true)
									.isEnabled(false)
									.state(.mixed)
								NSButton(checkboxWithTitle: "checkbox on")
									.isEnabled(false)
									.state(.on)
							}
						}
					}

					NSGridView.Row {
						StyledHeader(label: "Checkbox Binding")
						HStack {
							NSButton(checkboxWithTitle: "Check 1")
								.allowsMixedState(true)
								.state(checkBindingState)
							NSButton(checkboxWithTitle: "Check 2")
								.allowsMixedState(true)
								.state(checkBindingState)
							NSTextField(label: checkBindingState.stringRepresentation())
								.font(.body.italic)
								.textColor(.secondaryLabelColor)
						}
					}

					NSGridView.Row {
						StyledHeader(label: "Link Buttons")
						VStack(alignment: .leading, spacing: 0) {
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
						}
					}

					NSGridView.Row {
						StyledHeader(label: "Radio Buttons")
						HStack(spacing: 20) {
							NSButton.radioGroup()
								.items(["one", "two", "three"])
							NSButton.radioGroup(orientation: .horizontal)
								.items(["eight", "nine", "ten"])
						}
					}
				}
				.rowAlignment(.firstBaseline)
				.columnAlignment(.trailing, forColumn: 0)

				.rowAlignment(.none, forRowIndex: 0)
				.rowPlacement(.top, forRowIndex: 0)
				.rowAlignment(.none, forRowIndex: 1)
				.rowPlacement(.top, forRowIndex: 1)
			}
			.padding()
			//.debugFrames()
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
