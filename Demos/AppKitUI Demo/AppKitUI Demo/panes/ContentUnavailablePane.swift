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

class ContentUnavailablePane: Pane {
	override func title() -> String { "Content Unavailable" }
	@MainActor
	override func make(model: Model) -> NSView {

		let network__ = NSImage(named: NSImage.networkName)!
			.size(width: 64, height: 64)
		let appIcon__ = NSImage(named: NSImage.everyoneName)!
			.isTemplate(true)
			.size(width: 48, height: 48)

		return VStack {
			HStack {
				AUIContentUnavailableView(title: NSLocalizedString("No selection", comment: ""))
					.identifier("1")
					.backgroundBorder(.tertiaryLabelColor, lineWidth: 1)
				AUIContentUnavailableView(title: NSLocalizedString("No selection", comment: ""))
					.description(NSLocalizedString("Select an item from the list on the left", comment: ""))
					.identifier("2")
					.backgroundBorder(.tertiaryLabelColor, lineWidth: 1)
			}
			HStack {
				AUIContentUnavailableView(title: "Empty Palette")
					.description("Add some colours to your new palette using the + button in the toolbar.")
					.image(appIcon__)
					.identifier("3")
					.backgroundBorder(.tertiaryLabelColor, lineWidth: 1)
				AUIContentUnavailableView(title: "No Internet")
					.identifier("4")
					.image(network__)
					.titleFont(.title1.bold)
					.description("Try checking the network cables, modem, and router or reconnecting to Wi-Fi.")
					.addButton(
						NSButton()
							.identifier("2")
							.title("Cancel everything")
							.onAction { _ in
								model.log("Pressed the cancel everything button")
							}
							.compressionResistancePriority(.defaultLow, for: .horizontal)
					)
					.addButton(
						NSButton()
							.identifier("1")
							.title("Try again")
							.onAction { _ in
								model.log("Pressed the try again button")
							}
							.isDefaultButton(true)
							.compressionResistancePriority(.defaultLow, for: .horizontal)
					)
					.equalWidths(["1", "2"])
					.backgroundBorder(.tertiaryLabelColor, lineWidth: 1)
			}
		}
		.equalSizes(["1", "2", "3", "4"])
		.padding()
	}
}

#if DEBUG
@available(macOS 14, *)
#Preview("ContentUnavailablePane") {
	ContentUnavailablePane().make(model: Model())
}
#endif
