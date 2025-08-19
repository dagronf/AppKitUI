//
//  Copyright © 2025 Darren Ford. All rights reserved.
//
//  MIT license
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
//  documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial
//  portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
//  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
//  OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
//  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import AppKit
import AppKitUI




class NVivoLicenseExamplePane: Pane {
	override func title() -> String { "NVivo Example" }
	@MainActor
	override func make(model: Model) -> NSView {

		return NSView(layoutStyle: .centered) {
			let firstName = Bind("")
			let lastName = Bind("")
			let department = Bind("")
			let emailAddress = Bind("")
			let jobTitle = Bind("")
			let organization = Bind("")
			let phone = Bind("")
			let cityName = Bind("")
			let faxNumber = Bind("")
			let countryName = Bind("")
			let stateName = Bind("")
			let reasonForNVivo = Bind("")

			let licenseKey = Bind("")
			let installationKey = Bind("")
			let activationKey = Bind("")

			let sector = Bind(["Commercial", "Education", "Government", "Health", "Not for profit", "Other"])
			let sectorSelection = Bind(-1)

			let industry = Bind([
				"Central/Federal Government",
				"Defense/Military/Aerospace",
				"Health",
				"Local Government",
				"Public Safety",
				"Regulatory Bodies",
				"Security",
				"State Government",
				"State Owned Enterprise",
				"Other"
			])
			let industrySelection = Bind(-1)


			return VStack(alignment: .leading, spacing: 8) {

				NSTextField(label: "You must activate your license before you can use this app. Pleate enter your detals below and click 'Activate'.")
					.compressionResistancePriority(.defaultLow, for: .horizontal)

				HDivider()

				HStack(spacing: 12) {
					NSTextField(label: "Active via:")
					NSPopUpButton()
						.menu(NSMenu(title: "popup") {
							NSMenuItem(title: "Internet") { _ in }
							NSMenuItem(title: "Phone") { _ in }
						})
						.isEnabled(false)
					NSTextField(label: "To automatically activate this app via the Internet, enter your details below and click 'Activate'.")
						.compressionResistancePriority(.defaultLow, for: .horizontal)
				}

				HDivider()

				NSTextField(label: "The form must be completed in Western character sets.")

				HStack(spacing: 20) {
					VStack {
						NSGridView(columnSpacing: 2) {
							NSGridView.Row {
								NSTextField(label: "First Name:")
									.huggingPriority(.required, for: .horizontal)
								NSTextField(labelWithString: "*").textColor(.systemRed)
								NSTextField(content: firstName)
									.placeholder("Required")
							}
							NSGridView.Row {
								NSTextField(label: "Last Name:")
									.huggingPriority(.required, for: .horizontal)
								NSTextField(labelWithString: "*").textColor(.systemRed)
								NSTextField(content: lastName)
									.placeholder("Required")
							}
							NSGridView.Row {
								NSTextField(label: "Email Address:")
									.huggingPriority(.required, for: .horizontal)
								NSTextField(labelWithString: "*").textColor(.systemRed)
								NSTextField(content: emailAddress)
									.placeholder("Required")
							}
							NSGridView.Row {
								NSTextField(label: "Phone:")
									.huggingPriority(.required, for: .horizontal)
								NSGridCell.emptyContentView
								NSTextField(content: phone)
							}
							NSGridView.Row {
								NSTextField(label: "Fax:")
									.huggingPriority(.required, for: .horizontal)
								NSGridCell.emptyContentView
								NSTextField(content: faxNumber)
							}
							NSGridView.Row {
								NSTextField(label: "Sector:")
									.huggingPriority(.required, for: .horizontal)
								NSGridCell.emptyContentView
								NSPopUpButton()
									.menuItems(sector)
									.selectedIndex(sectorSelection)
									.huggingPriority(.init(10), for: .horizontal)
							}
							NSGridView.Row {
								NSTextField(label: "Industry:")
									.huggingPriority(.required, for: .horizontal)
								NSGridCell.emptyContentView
								NSPopUpButton()
									.menuItems(industry)
									.selectedIndex(industrySelection)
									.huggingPriority(.init(10), for: .horizontal)
							}
							NSGridView.Row {
								NSGridCell.emptyContentView
								HStack {
									NSTextField(labelWithString: "*").textColor(.systemRed)
									NSTextField(label: "indicates a required field")
								}
							}
							.mergeCells(1 ... 2)
						}
						.identifier("col1")
						.rowAlignment(.firstBaseline)
						.columnAlignment(.trailing, forColumn: 0)
						NSView()
					}

					VStack {
						NSGridView(columnSpacing: 2) {
							NSGridView.Row {
								NSTextField(label: "Job Title:")
									.huggingPriority(.required, for: .horizontal)
								NSGridCell.emptyContentView
								NSTextField(content: jobTitle)
									.placeholder("Required")
							}
							NSGridView.Row {
								NSTextField(label: "Department:")
									.huggingPriority(.required, for: .horizontal)
								NSGridCell.emptyContentView
								NSTextField(content: department)
							}
							NSGridView.Row {
								NSTextField(label: "Organization:")
									.huggingPriority(.required, for: .horizontal)
								NSGridCell.emptyContentView
								NSTextField(content: organization)
							}
							NSGridView.Row {
								NSTextField(label: "City:")
									.huggingPriority(.required, for: .horizontal)
								NSGridCell.emptyContentView
								NSTextField(content: cityName)
							}
							NSGridView.Row {
								NSTextField(label: "Country:")
									.huggingPriority(.required, for: .horizontal)
								NSGridCell.emptyContentView
								NSTextField(content: countryName)
							}
							NSGridView.Row {
								NSTextField(label: "State:")
									.huggingPriority(.required, for: .horizontal)
								NSGridCell.emptyContentView
								NSTextField(content: stateName)
							}
							NSGridView.Row {
								NSTextField(label: "How did you hear about NVivo?")
									.compressionResistancePriority(.init(1), for: .horizontal)
									.alignment(.right)
								NSGridCell.emptyContentView
								NSTextField(content: reasonForNVivo)
							}
						}
						.identifier("col2")
						.rowAlignment(.firstBaseline)
						.columnAlignment(.trailing, forColumn: 0)
					}
					NSView()
				}
				.equalWidths(["col1", "col2"])

				NSGridView(columnSpacing: 2) {
					NSGridView.Row {
						NSTextField(label: "License Key:")
						NSTextField(content: licenseKey)
					}
					NSGridView.Row {
						NSTextField(label: "Installation Key:")
						HStack {
							NSTextField(content: installationKey)
							NSButton(title: "Generate Installation Key")
						}
					}
					NSGridView.Row {
						NSTextField(label: "Activation Key:")
						NSTextField(content: activationKey)
					}
				}
				.rowAlignment(.firstBaseline)
				.columnAlignment(.trailing, forColumn: 0)

				HDivider()

				HStack {
					NSButton()
						.bezelStyle(.helpButton)
						.imagePosition(.imageOnly)
						.gravityArea(.leading)
					NSButton(title: "Cancel")
						.gravityArea(.leading)

					NSButton(title: "Replace License Key")
						.gravityArea(.trailing)
					NSButton(title: "Send")
						.isEnabled(false)
						.gravityArea(.trailing)
					NSButton(title: "Activate")
						.isDefaultButton(true)
						.gravityArea(.trailing)
				}
				.hugging(.init(1), for: .horizontal)
			}
		}
		.padding()
	}
}

#if DEBUG
@available(macOS 14, *)
#Preview("NVivo Registration Example", traits: .fixedLayout(width: 700, height: 400)) {
	NVivoLicenseExamplePane().make(model: Model())
		.padding()
}
#endif
