//
//  ButtonPane.swift
//  AppKitUI Demo
//
//  Created by Darren Ford on 17/7/2025.
//

import AppKit
import AppKitUI

private extension NSTextField {
	func gridStyle() -> Self {
		self
			.lineBreakMode(.byTruncatingTail)
			.truncatesLastVisibleLine(true)
			.compressionResistancePriority(.defaultLow, for: .horizontal)
			.huggingPriority(.init(50), for: .horizontal)
	}

	func gridTitleStyle() -> Self {
		self
			.font(.monospaced)
			.huggingPriority(.defaultHigh, for: .horizontal)
	}

	func fontSizeContent() -> Self {
		self
			.lineBreakMode(.byTruncatingTail)
			.compressionResistancePriority(.init(200), for: .horizontal)
	}
}

let phrases = [
	"Sphinx of black quartz judge my vow",
	"The quick brown fox jumps over the lazy dog",
	"Jaded zombies acted quaintly but kept driving their oxen forward",
	"Pack my box with five dozen liquor jugs"
]

class FontPane: Pane {
	override func title() -> String { "Fonts" }

	@MainActor
	override func make(model: Model) -> NSView {
		let sampleText = Bind(phrases[0])
		let selectedTab = Bind(1)
		return VStack(spacing: 20) {
			HStack(spacing: 8) {
				NSTextField(label: "Sample Text:")
					.font(.headline)
				NSComboBox(content: sampleText)
					.menuItems(phrases)
					.autocompletes(true)
					.huggingPriority(.defaultLow, for: .horizontal)
			}

			TabView(tabType: .topTabsBezelBorder, selectedTab: selectedTab) {
				NSTabView.Tab(label: "Defined Fonts") {
					definedFontsTab(sampleText)
				}
				NSTabView.Tab(label: "Font Weights") {
					fontWeightsTab(sampleText)
				}
				NSTabView.Tab(label: "Font Size") {
					fontSizesTab(sampleText)
				}
			}
		}
		.padding()
	}
}

@MainActor
private func definedFontsTab(_ _sampleText: Bind<String>) -> NSView {
	ScrollView(borderType: .noBorder, fitHorizontally: true) {
		NSGridView {

			NSGridView.Row {
				NSTextField(label: ".system")
					.gridTitleStyle()
				NSTextField(label: _sampleText)
					.font(.system)
					.gridStyle()
			}

			NSGridView.Row {
				NSTextField(label: ".systemSmall")
					.gridTitleStyle()
				NSTextField(label: _sampleText)
					.font(.systemSmall)
					.gridStyle()
			}

			NSGridView.Row {
				NSTextField(label: ".systemMini")
					.gridTitleStyle()
				NSTextField(label: _sampleText)
					.font(.systemMini)
					.gridStyle()
			}

			NSGridView.Row {
				NSTextField(label: ".body")
					.gridTitleStyle()
				NSTextField(label: _sampleText)
					.font(.body)
					.gridStyle()
			}

			NSGridView.Row {
				NSTextField(label: ".callout")
					.gridTitleStyle()
				NSTextField(label: _sampleText)
					.font(.callout)
					.gridStyle()
			}

			NSGridView.Row {
				NSTextField(label: ".caption1")
					.gridTitleStyle()
				NSTextField(label: _sampleText)
					.font(.caption1)
					.gridStyle()
			}

			NSGridView.Row {
				NSTextField(label: ".caption2")
					.gridTitleStyle()
				NSTextField(label: _sampleText)
					.font(.caption2)
					.gridStyle()
			}

			NSGridView.Row {
				NSTextField(label: ".footnote")
					.gridTitleStyle()
				NSTextField(label: _sampleText)
					.font(.footnote)
					.gridStyle()
			}

			NSGridView.Row {
				NSTextField(label: ".headline")
					.gridTitleStyle()
				NSTextField(label: _sampleText)
					.font(.headline)
					.gridStyle()
			}

			NSGridView.Row {
				NSTextField(label: ".subheadline")
					.gridTitleStyle()
				NSTextField(label: _sampleText)
					.font(.subheadline)
					.gridStyle()
			}

			NSGridView.Row {
				NSTextField(label: ".largeTitle")
					.gridTitleStyle()
				NSTextField(label: _sampleText)
					.font(.largeTitle)
					.gridStyle()
			}

			NSGridView.Row {
				NSTextField(label: ".title1")
					.gridTitleStyle()
				NSTextField(label: _sampleText)
					.font(.title1)
					.gridStyle()
			}

			NSGridView.Row {
				NSTextField(label: ".title2")
					.gridTitleStyle()
				NSTextField(label: _sampleText)
					.font(.title2)
					.gridStyle()
			}
			
			NSGridView.Row {
				NSTextField(label: ".title3")
					.gridTitleStyle()
				NSTextField(label: _sampleText)
					.font(.title3)
					.gridStyle()
			}

			NSGridView.Row {
				NSTextField(label: ".monospaced")
					.gridTitleStyle()
				NSTextField(label: _sampleText)
					.font(.monospaced)
					.gridStyle()
			}

			NSGridView.Row {
				NSTextField(label: ".monospacedDigit")
					.gridTitleStyle()
				NSTextField(label: _sampleText)
					.font(.monospacedDigit)
					.gridStyle()
			}
		}
		.rowAlignment(.firstBaseline)
		.columnWidth(150, forColumn: 0)
		.padding(8)
	}
}

@MainActor
private func fontWeightsTab(_ _sampleText: Bind<String>) -> NSView {
	ScrollView(borderType: .noBorder, fitHorizontally: true) {
		NSGridView {
			NSGridView.Row {
				NSTextField(label: ".ultraLight")
					.gridTitleStyle()
				NSTextField(label: _sampleText)
					.font(.system.weight(.ultraLight))
					.gridStyle()
			}
			NSGridView.Row {
				NSTextField(label: ".thin")
					.gridTitleStyle()
				NSTextField(label: _sampleText)
					.font(.system.weight(.thin))
					.gridStyle()
			}
			NSGridView.Row {
				NSTextField(label: ".light")
					.gridTitleStyle()
				NSTextField(label: _sampleText)
					.font(.system.weight(.light))
					.gridStyle()
			}
			NSGridView.Row {
				NSTextField(label: ".regular")
					.gridTitleStyle()
				NSTextField(label: _sampleText)
					.font(.system.weight(.regular))
					.gridStyle()
			}
			NSGridView.Row {
				NSTextField(label: ".medium")
					.gridTitleStyle()
				NSTextField(label: _sampleText)
					.font(.system.weight(.medium))
					.gridStyle()
			}
			NSGridView.Row {
				NSTextField(label: ".semibold")
					.gridTitleStyle()
				NSTextField(label: _sampleText)
					.font(.system.weight(.semibold))
					.gridStyle()
			}
			NSGridView.Row {
				NSTextField(label: ".bold")
					.gridTitleStyle()
				NSTextField(label: _sampleText)
					.font(.system.weight(.bold))
					.gridStyle()
			}
			NSGridView.Row {
				NSTextField(label: ".heavy")
					.gridTitleStyle()
				NSTextField(label: _sampleText)
					.font(.system.weight(.heavy))
					.gridStyle()
			}
			NSGridView.Row {
				NSTextField(label: ".black")
					.gridTitleStyle()
				NSTextField(label: _sampleText)
					.font(.system.weight(.black))
					.gridStyle()
			}
		}
		.rowAlignment(.firstBaseline)
		.columnWidth(150, forColumn: 0)
		.padding(8)
	}
}

@MainActor
private func fontSizesTab(_ _sampleText: Bind<String>) -> NSView {
	ScrollView(borderType: .noBorder, fitHorizontally: true) {
		NSGridView(yPlacement: .center) {
			NSGridView.Row {
				NSTextField(label: "9")
					.font(.monospaced)
				NSTextField(label: _sampleText)
					.font(.system.size(9))
					.fontSizeContent()
			}
			NSGridView.Row {
				NSTextField(label: "11")
					.font(.monospaced)
				NSTextField(label: _sampleText)
					.font(.system.size(11))
					.fontSizeContent()
			}
			NSGridView.Row {
				NSTextField(label: "13")
					.font(.monospaced)
				NSTextField(label: _sampleText)
					.font(.system.size(13))
					.fontSizeContent()
			}
			NSGridView.Row {
				NSTextField(label: "16")
					.font(.monospaced)
				NSTextField(label: _sampleText)
					.font(.system.size(16))
					.fontSizeContent()
			}
			NSGridView.Row {
				NSTextField(label: "24")
					.font(.monospaced)
				NSTextField(label: _sampleText)
					.font(.system.size(24))
					.fontSizeContent()
			}
			NSGridView.Row {
				NSTextField(label: "48")
					.font(.monospaced)
				NSTextField(label: _sampleText)
					.font(.system.size(48))
					.fontSizeContent()
			}
			NSGridView.Row {
				NSTextField(label: "96")
					.font(.monospaced)
				NSTextField(label: _sampleText)
					.font(.system.size(96))
					.fontSizeContent()
			}
		}
		.rowAlignment(.firstBaseline)
		.columnWidth(30, forColumn: 0)
	}
}

#if DEBUG
@available(macOS 14, *)
#Preview("default") {
	FontPane().make(model: Model())
		.frame(width: 640, height: 430)
		.padding(top: 38, left: 20, bottom: 20, right: 20)
}
#endif
