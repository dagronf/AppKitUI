//
//  ButtonPane.swift
//  AppKitUI Demo
//
//  Created by Darren Ford on 17/7/2025.
//

import AppKit
import AppKitUI

class BindingsPane: Pane {
	override func title() -> String { "Bindings" }

	override func make(model: Model) -> NSView {

		let showSomethingValue = Bind(true)
		let hideSomethingValue = showSomethingValue.twoWayTransform(BindTransformers.BoolInverted())

		return VStack(alignment: .leading) {
			NSBox(title: "Basic binding tansformer testing") {
				VStack(alignment: .leading, spacing: 16) {
					NSTextField(label: "These controls should reflect the opposite of each other")

					HDivider()

					HStack {
						AUISwitch()
							.state(showSomethingValue)
						NSTextField(label: "This is the original value")
							.compressionResistancePriority(.defaultHigh, for: .horizontal)
							.onClickGesture {
								// Make this text behave like the checkbox text
								showSomethingValue.toggle()
							}
					}

					NSButton.checkbox(title: "This checkbox should reflect the opposite of the switch value")
						.state(hideSomethingValue)
				}
				.padding(8)
			}
			NSView.Spacer()
		}
		.padding(28)
	}
}

#if DEBUG
@available(macOS 14, *)
#Preview("default") {
	BindingsPane().make(model: Model())
}
#endif
