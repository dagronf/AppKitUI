//
//  ButtonPane.swift
//  AppKitUI Demo
//
//  Created by Darren Ford on 17/7/2025.
//

import AppKit
import AppKitUI

@available(macOS 11, *)
class SwitchPane: Pane {
	override func title() -> String { "NSSwitch (10.15+)" }

	override func make(model: Model) -> NSView {

		let stateLarge = Bind(false)
		let stateRegular = Bind(false)
		let stateSmall = Bind(false)
		let stateMini = Bind(false)

		return ScrollView(borderType: .noBorder) {
			VStack {
				NSGridView(yPlacement: .center, rowSpacing: 12) {
					NSGridView.Row {
						NSGridCell.emptyContentView
						NSTextField(label: ".large")
							.font(.monospaced)
						NSTextField(label: ".regular")
							.font(.monospaced)
						NSTextField(label: ".small")
							.font(.monospaced)
						NSTextField(label: ".mini")
							.font(.monospaced)
					}

					NSGridView.Row {
						NSTextField(label: "NSSwitch")
							.font(.monospaced)
						VStack(spacing: 3) {
							NSSwitch()
								.state(stateLarge)
								.controlSize(.large)
							NSTextField(label: stateLarge.stateString())
								.font(.systemSmall).textColor(.secondaryLabelColor)
						}
						VStack(spacing: 3) {
							NSSwitch()
								.state(stateRegular)
								.controlSize(.regular)
							NSTextField(label: stateRegular.stateString())
								.font(.systemSmall).textColor(.secondaryLabelColor)
						}
						VStack(spacing: 3) {
							NSSwitch()
								.state(stateSmall)
								.controlSize(.small)
							NSTextField(label: stateSmall.stateString())
								.font(.systemSmall).textColor(.secondaryLabelColor)
						}
						VStack(spacing: 3) {
							NSSwitch()
								.state(stateMini)
								.controlSize(.mini)
							NSTextField(label: stateMini.stateString())
								.font(.systemSmall).textColor(.secondaryLabelColor)
						}
					}

					NSGridView.Row {
						NSTextField(label: "AUISwitch")
							.font(.monospaced)
						VStack(spacing: 3) {
							AUISwitch()
								.state(stateLarge)
								.controlSize(.large)
							NSTextField(label: stateLarge.stateString())
								.font(.systemSmall).textColor(.secondaryLabelColor)
						}
						VStack(spacing: 3) {
							AUISwitch()
								.state(stateRegular)
								.controlSize(.regular)
							NSTextField(label: stateRegular.stateString())
								.font(.systemSmall).textColor(.secondaryLabelColor)
						}
						VStack(spacing: 3) {
							AUISwitch()
								.state(stateSmall)
								.controlSize(.small)
							NSTextField(label: stateSmall.stateString())
								.font(.systemSmall).textColor(.secondaryLabelColor)
						}
						VStack(spacing: 3) {
							AUISwitch()
								.state(stateMini)
								.controlSize(.mini)
							NSTextField(label: stateMini.stateString())
								.font(.systemSmall).textColor(.secondaryLabelColor)
						}
					}
				}
				.columnAlignment(.trailing, forColumn: 0)
				.columnAlignment(.center, forColumns: 1 ... 4)
				.columnWidth(70, forColumns: 1 ... 4)
			}
			.padding()
		}
	}
}

#if DEBUG
@available(macOS 14, *)
#Preview("default") {
	SwitchPane().make(model: Model())
		//.frame(width: 320, height: 200)
}
#endif
