//
//  EmptyPane.swift
//  AppKitUI Demo
//
//  Created by Darren Ford on 17/7/2025.
//

import AppKit
import AppKitUI

class AlertsPane: Pane {
	override func title() -> String { NSLocalizedString("Alerts", comment: "") }
	@MainActor
	override func make(model: Model) -> NSView {

		@Bindable var asr = false
		@Bindable var asr2 = false
		@Bindable var sheet1 = false
		@Bindable var popover1 = false
		@Bindable var progressValue = 0.2

		@Bindable var count = 0
		@Bindable var suppressionState = true

		return NSView(layoutStyle: .centered) {
			VStack {
				NSButton(title: NSLocalizedString("Display a critical alert", comment: "")) { _ in
					asr = true
				}
				NSButton(title: NSLocalizedString("Display an informational alert", comment: "")) { _ in
					asr2 = true
				}

				VDivider()

				NSButton(title: NSLocalizedString("Display a sheet", comment: "")) { _ in
					sheet1 = true
				}

				VDivider()

				NSButton(title: NSLocalizedString("Display a popover", comment: "")) { _ in
					popover1 = true
				}
				.popover(title: "Wheee!", isVisible: $popover1, preferredEdge: .maxY, behaviour: .semitransient) {
					Popover1(progressValue: $progressValue, popover1: $popover1).body
				}
			}

			.alert(isVisible: $asr) {
				NSAlert(style: .critical)
					.messageText(NSLocalizedString("Delete the document?", comment: ""))
					.informativeText(NSLocalizedString("Are you sure you would like to delete the document?", comment: ""))
					.buttons([NSLocalizedString("Delete", comment: ""), NSLocalizedString("Cancel", comment: "")])
					.suppressionState($suppressionState)
			} onDismissed: { result in
				model.log(result)
			}

			.onChange($suppressionState) { newValue in
				model.log("Suppression state = \(newValue)")
			}

			.alert(isVisible: $asr2) {
				NSAlert(style: .informational)
					.messageText("The request was successful")
					.icon(NSImage(named: NSImage.userGroupName)!)
					.buttons(["OK"])
					.accessoryView {
						VStack {
							NSTextField(label: "This is the accessory view")
							NSTextField(label: "\(count)")
						}
						.translatesAutoresizingMaskIntoConstraints(true)
						.debugFrame()
					}
			} onDismissed: { @MainActor result in
				count += 1
				model.log(result)
			}

			.sheet(isVisible: $sheet1, frameAutosaveName: "sheet-1-store") {
				Sheet1(count: $count, sheet1: $sheet1).body
			}
		}
	}
}

@MainActor
struct Popover1: AUIViewBodyGenerator {
	let progressValue: Bind<Double>
	let popover1: Bind<Bool>
	var body: NSView {
		NSView(layoutStyle: .fill) {
			VStack {
				HStack {
					//NSImageView(systemSymbolName: "tortoise")
					NSImageView(imageNamed: "NSTouchBarVolumeDownTemplate")

					NSSlider(progressValue, range: 0 ... 1)
						.width(200)
					//NSImageView(systemSymbolName: "hare")
					NSImageView(imageNamed: "NSTouchBarVolumeUpTemplate")
				}
				NSButton(title: "Close") { _ in
					popover1.wrappedValue = false
				}
			}
		}
		.padding()
	}
}

@MainActor
struct Sheet1: AUIViewBodyGenerator {
	let count: Bind<Int>
	let sheet1: Bind<Bool>
	var body: NSView {
		VStack {
			NSTextField(label: "This is a sheet view")
				.huggingPriority(.init(1), for: .horizontal)
			NSTextField(label: "\(count.wrappedValue)")
				.huggingPriority(.init(1), for: .horizontal)
			NSView.Spacer()
			NSButton(title: "Dismiss") { _ in
				sheet1.wrappedValue = false
			}
		}
		.padding()
		.hugging(.init(1), for: .horizontal)
	}
}

#if DEBUG
@available(macOS 14, *)
#Preview("Empty") {
	AlertsPane().make(model: Model())
}

@available(macOS 14, *)
#Preview("Popover1", traits: .sizeThatFitsLayout) {
	Popover1(progressValue: Bind(0.2), popover1: Bind(false)).body
		.debugFrame()
}

@available(macOS 14, *)
#Preview("Sheet1", traits: .sizeThatFitsLayout) {
	Sheet1(count: Bind(0), sheet1: Bind(false)).body
		.debugFrame()
}

#endif
