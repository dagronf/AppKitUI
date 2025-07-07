//
//  ButtonPane.swift
//  AppKitUI Demo
//
//  Created by Darren Ford on 17/7/2025.
//

import AppKit
import AppKitUI

class AUISwitchPane: Pane {
	override func title() -> String { "NSSwitch (10.11+)" }

	override func make(model: Model) -> NSView {

		let state = Bind(false)
		let enabled = Bind(true)

		return VStack(alignment: .leading) {
			NSTextField(label: "This is an NSSwitch equivalent that supports back to 10.11")

			HDivider()

			VStack(alignment: .leading) {
				HStack {
					NSButton.checkbox(title: "Enabled")
						.state(enabled)
					NSButton.checkbox(title: "State")
						.state(state)
				}

				HStack {
					NSView(layoutStyle: .fill) {
						if #available(macOS 10.15, *) {
							AUISwitch()
								.state(state)
								.controlSize(.regular)
								.isEnabled(enabled)
						}
						else {
							NSView.empty
						}
					}
					AUISwitch()
						.state(state)
						.controlSize(.regular)
						.isEnabled(enabled)
					AUISwitch()
						.state(state)
						.controlSize(.small)
						.isEnabled(enabled)
					AUISwitch()
						.state(state)
						.controlSize(.mini)
						.isEnabled(enabled)
					NSView.Spacer()
				}
			}
			NSView.Spacer()
		}
		.padding(28)
	}
}

#if DEBUG
@available(macOS 14, *)
#Preview("default") {
	AUISwitchPane().make(model: Model())
		//.frame(width: 320, height: 200)
}
#endif
