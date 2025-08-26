//
//  Model.swift
//  AppKitUI Demo
//
//  Created by Darren Ford on 17/7/2025.
//

import AppKit
import AppKitUI

@MainActor
class Model {

	let rootPanes: [Pane] = {
		var p = [
			ButtonPane(),
			FontPane(),
			PlainTextPane(),
			ComboButtonPane(),
			AUISwitchPane(),
			TokenPane(),
			ColorWellPane(),
			AlertsPane(),
			OpenSavePane(),
			DisclosurePane(),
			GridPane(),
			SearchPane(),
			SegmentedControlPane(),
			StepperPane(),
			TextFieldPane(),
			FlowPane(),
			SecureTextPane(),
			LicenseExamplePane(),
			ExtractExamplePane(),
			NVivoLicenseExamplePane(),
			VisualEffectPane(),
			ShadowsPane(),
			ShapesPane(),
			DockExamplePane(),
			FinanceSwatchPane(),
			ImageViewPane(),
			DelayedBindPane(),
			BindingsPane(),
			ColorSelectorPane()
		]
		if #available(macOS 11, *) {
			p.append(SwitchPane())
		}
		return p.sorted(by: { a, b in a.title() < b.title() })
	}()

	lazy var panes: Bind<[Pane]> = Bind(rootPanes)

	let selected = Bind(-1)

	// Logging
	var log: Logger = DumbLog()

	func log(_ content: Any) {
		self.log.log("\(content)")
	}
}

class DumbLog: Logger {
	func log(_ content: Any) {
		Swift.print(content)
	}
}
