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

class ImageViewPane: Pane {
	override func title() -> String { "Image Views" }
	@MainActor
	override func make(model: Model) -> NSView {
		let image = Bind<NSImage?>(nil)

		let toggleImages = [NSImage(named: NSImage.colorPanelName)!, NSImage(named: NSImage.cautionName)!]
		let toggleImage = Bind<NSImage?>(toggleImages[0])

		let showMarchingAnts = Bind(true)

		return NSView(layoutStyle: .centered) {
			VStack(spacing: 12) {
				VStack {
					HStack(spacing: 20) {
						NSImageView()
							.image(image)
							.isEditable(true)
							.frame(width: 100, height: 100)
							.onChange(image) { _ in
								Swift.print("Image did change...")
							}
							.padding(8)
							.background(
								Rectangle(cornerRadius: 12)
									.fill(color: .quaternaryLabelColor)
									.stroke(.tertiaryLabelColor, lineWidth: 3)
									.strokeLineDashPattern([5, 5])
									.marchingAnts(showMarchingAnts)
							)
							.onClickGesture(numberOfClicksRequired: 2) {
								Swift.print("User clicked on the image...")
							}

						AUISwitch()
							.state(showMarchingAnts)
					}


					NSTextField(label: "Drop an image onto the image view")
						.font(.caption2)
						.textColor(.secondaryLabelColor)
				}


				HDivider()

				VStack {
					HStack(spacing: 20) {
						NSImageView()
							.frameStyle(.grayBezel)
							.image(toggleImage)
							.imageScaling(.scaleProportionallyUpOrDown)
							.frame(width: 64, height: 64, priority: .required)
						AUISwitch()
							.onAction { @MainActor newState in
								toggleImage.wrappedValue = newState == .on ? toggleImages[1] : toggleImages[0]
							}
					}
					NSTextField(label: "Change the toggle to change the image")
						.font(.caption2)
						.textColor(.secondaryLabelColor)
				}
			}
		}
	}
}

#if DEBUG
@available(macOS 14, *)
#Preview("Basic") {
	ImageViewPane().make(model: Model())
}
#endif
