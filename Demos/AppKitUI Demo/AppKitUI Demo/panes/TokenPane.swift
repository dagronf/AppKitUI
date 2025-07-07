//
//  ButtonPane.swift
//  AppKitUI Demo
//
//  Created by Darren Ford on 17/7/2025.
//

import AppKit
import AppKitUI


class TokenPane: Pane {
	override func title() -> String { "NSTokenField" }

	@MainActor
	override func make(model: Model) -> NSView {
		let tokenField = Bind<[String]>(["red", "green", "blue", "cyan", "magenta", "yellow"])
		let tokenField3 = Bind<[String]>(["Australia", "Isle of Man", "Wallis & Futuna"])
		let autocompleteValues = allCountries().sorted(by: <)
		let emailTokens = Bind<[String]>(["caterpillar@womble.com", "flutterby@womble.com"])

		return ScrollView(borderType: .noBorder) {
			VStack {
				NSBox(title: "TokenField update on end editing only") {
					VStack {
						AUITokenField(content: tokenField)
							.wraps(true)
							.lineBreakMode(.byWordWrapping)
							.truncatesLastVisibleLine(false)
							.huggingPriority(.init(1), for: .horizontal)
							.compressionResistancePriority(.defaultLow, for: .horizontal)

						HStack(alignment: .firstBaseline) {
							NSTextField(label: "Tokens:")
								.font(.system.bold)
							NSTextField(label: tokenField.stringValue())
								.huggingPriority(.init(1), for: .horizontal)
								.compressionResistancePriority(.defaultLow, for: .horizontal)
						}
					}
				}
				.huggingPriority(.init(1), for: .horizontal)

				NSBox(title: "TokenField with completions (English country names)") {
					VStack {
						AUITokenField(content: tokenField3)
							.wraps(true)
							.lineBreakMode(.byWordWrapping)
							.truncatesLastVisibleLine(false)
							.completions { str in autocompleteValues.filter { $0.localizedCaseInsensitiveContains(str) } }
							.huggingPriority(.init(1), for: .horizontal)
							.compressionResistancePriority(.defaultLow, for: .horizontal)

						HStack(alignment: .firstBaseline) {
							NSTextField(label: "Tokens:")
								.font(.system.bold)
							
							NSTextField(label: tokenField3.stringValue())
								.huggingPriority(.init(1), for: .horizontal)
								.compressionResistancePriority(.defaultLow, for: .horizontal)
						}
					}
				}
				.huggingPriority(.init(1), for: .horizontal)

				NSBox(title: "TokenField with menus") {
					VStack {
						AUITokenField(content: emailTokens)
							.wraps(true)
							.lineBreakMode(.byWordWrapping)
							.truncatesLastVisibleLine(false)
							.hasMenuForToken { _ in true }
							.menuForToken { token in
								NSMenu(title: "email actions") {
									NSMenuItem(title: "Send email…") { _ in
										let alert = NSAlert()
										alert.messageText = "Sending email to '\(token)'"
										alert.runModal()
									}
									NSMenuItem(title: "Send file…") { _ in
										let alert = NSAlert()
										alert.messageText = "Sending file to '\(token)'"
										alert.runModal()
									}
									NSMenuItem.separator()
									NSMenuItem(title: "Delete contact…") { _ in
										let alert = NSAlert()
										alert.messageText = "Deleting contact '\(token)'"
										alert.runModal()
									}
								}
							}

							.huggingPriority(.init(1), for: .horizontal)
							.compressionResistancePriority(.defaultLow, for: .horizontal)

						HStack(alignment: .firstBaseline) {
							NSTextField(label: "Tokens:")
								.font(.system.bold)

							NSTextField(label: emailTokens.stringValue())
								.huggingPriority(.init(1), for: .horizontal)
								.compressionResistancePriority(.defaultLow, for: .horizontal)
						}
					}
				}
				.huggingPriority(.init(1), for: .horizontal)
			}
			.distribution(.fill)
		}
		.huggingPriority(.init(1), for: .horizontal)
		.padding()
	}
}

#if DEBUG
@available(macOS 14, *)
#Preview("default") {
	TokenPane().make(model: Model())
		.frame(width: 640, height: 480)
}
#endif


private func allCountries() -> [String] {
	let bg = NSLocale.current as NSLocale
	return NSLocale.isoCountryCodes.compactMap { bg.displayName(forKey: .countryCode, value: $0) }
}
