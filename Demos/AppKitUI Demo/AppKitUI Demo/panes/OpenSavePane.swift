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

class OpenSavePane: Pane {
	override func title() -> String { "Open/Save" }
	@MainActor
	override func make(model: Model) -> NSView {
		let showMultiSelectOpenPanel = Bind(false)
		let showOneSelectOpenPanel = Bind(false)
		let selectedFiles = Bind<[URL]>([])

		let showExportPanel = Bind(false)
		let exportPanelSelectedType = Bind(1)

		return NSView(layoutStyle: .centered) {
			VStack {
				HStack {
					NSButton(title: "Select Multiple Image(s)…") { _ in
						showMultiSelectOpenPanel.wrappedValue = true
					}
					.fileImporter(
						isVisible: showMultiSelectOpenPanel,
						allowedFileTypes: ["public.jpeg"], //allowedContentTypes: [.image],
						allowsMultiple: true,
						message: "The title of the open panel 😀",
						openButtonTitle: "Do selection!")
					{ newValue in
						selectedFiles.wrappedValue = newValue
					}
					
					NSButton(title: "Select one Image…") { _ in
						showOneSelectOpenPanel.wrappedValue = true
					}
					.fileImporter(
						isVisible: showOneSelectOpenPanel,
						allowedFileTypes: ["public.jpeg"], //allowedContentTypes: [.image],
						allowsMultiple: false,
						accessoryViewBuilder: {
							NSView(layoutStyle: .centered) {
								VStack {
									HStack {
										NSButton(title: "one")
										NSButton(title: "two")
									}
									NSTextField(label: "This is a test of an accessory view")
								}
								.padding(8)
							}
						}
					) { newValue in
						selectedFiles.wrappedValue = newValue
					}

					NSButton(title: "Save File…") { _ in
						showExportPanel.wrappedValue = true
					}
					.fileExporter(
						isVisible: showExportPanel,
						allowedFileTypes: ["public.jpg", "public.png"], //allowedContentTypes: [.jpeg, .png],
						isExtensionHidden: false,
						accessoryViewBuilder: {
							NSView(layoutStyle: .centered) {
								HStack {
									NSTextField(label: "Format:")
										.font(.system.weight(.medium))
									NSPopUpButton()
										.style(.popsUp)
										.menuItems(["jpeg", "png"])
										.selectedIndex(exportPanelSelectedType)
								}
							}.padding()
						}
					) { url in
						selectedFiles.wrappedValue = [url]
					}
				}

				ScrollView {
					List(selectedFiles) { item in
						NSPathControl(fileURL: item)
							.huggingPriority(.defaultLow, for: .horizontal)
					}
					.usesAlternatingRowBackgroundColors(true)
				}
				.minWidth(500)
				.minHeight(200)
			}
		}
	}
}

#if DEBUG
@available(macOS 14, *)
#Preview("Open Save") {
	OpenSavePane().make(model: Model())
}
#endif
