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

class PDFPane: Pane {
	override func title() -> String { "PDF" }
	@MainActor
	override func make(model: Model) -> NSView {

		let fileURL = Bind<URL?>(nil)
		let scaleFactor = Bind(1.0)
		let showFileSelector = Bind(false)

		let minusImage = NSImage(named: "minus.magnifyingglass")!
			.isTemplate(true)
			.size(width: 22, height: 22)
		let oneImage = NSImage(named: "1.magnifyingglass")!
			.isTemplate(true)
			.size(width: 22, height: 22)
		let plusImage = NSImage(named: "plus.magnifyingglass")!
			.isTemplate(true)
			.size(width: 22, height: 22)

		return VStack(alignment: .leading) {
			HStack {
				NSButton(title: "Select a file") { _ in
					showFileSelector.toggle()
				}
				NSView {
					NSPathControl(fileURL: fileURL)
						.isHidden(fileURL.oneWayTransform { $0 == nil })
						.huggingPriority(.defaultLow, for: .horizontal)
					NSTextField(label: "No file selected")
						.textColor(.secondaryLabelColor)
						.isHidden(fileURL.oneWayTransform { $0 != nil })
						.huggingPriority(.defaultLow, for: .horizontal)
				}

				NSView.Spacer()

				NSButton(title: "Clear") { _ in
					fileURL.wrappedValue = nil
				}
				.isEnabled(fileURL.oneWayTransform { $0 != nil })
			}
			AUIPDFView()
				.fileURL(fileURL)
				.scaleFactor(scaleFactor, range: 0.25 ... 4)
			NSGridView {
				NSGridView.Row {
					NSTextField(label: "scale:")
					HStack {
						NSSlider(scaleFactor, range: 0.25 ... 4)
							.controlSize(.small)
							.isEnabled(fileURL != nil)
						
						NSButton.image(minusImage) { _ in
							let sc = max(0.25, min(4.0, scaleFactor.wrappedValue - 0.25))
							scaleFactor.wrappedValue = sc
						}
						.isEnabled(scaleFactor > 0.25)
						.isEnabled(fileURL != nil)

						NSButton.image(oneImage) { _ in
							scaleFactor.wrappedValue = 1.0
						}
						.isEnabled(scaleFactor != 1.0)
						.isEnabled(fileURL != nil)

						NSButton.image(plusImage) { _ in
							let sc = max(0.25, min(4.0, scaleFactor.wrappedValue + 0.25))
							scaleFactor.wrappedValue = sc
						}
						.isEnabled(scaleFactor < 4.0)
						.isEnabled(fileURL != nil)
					}
				}
				.rowAlignment(.lastBaseline)
			}
		}
		.hugging(.init(1), for: .horizontal)
		.fileImporter(
			isVisible: showFileSelector,
			allowedFileTypes: ["pdf"],
			allowsMultiple: false) { selected in
				fileURL.wrappedValue = selected.first
			}
		.padding()
	}
}

#if DEBUG
@available(macOS 14, *)
#Preview("Empty") {
	PDFPane().make(model: Model())
		.width(500)
		.padding(50)
}
#endif
