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

extension NSApplication {
	func isDarkMode() -> Bool {
		if #available(macOS 10.14, *) {
			return NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
		}
		return false
	}
}

class VisualEffectPane: Pane {
	override func title() -> String { "Visual Effect" }
	@MainActor
	override func make(model: Model) -> NSView {

		let imleft = NSImage(named: "chevron.left")!
			.isTemplate(true)
		let imright = NSImage(named: "chevron.right")!
			.isTemplate(true)
		let imcycle = NSImage(named: "figure.outdoor.cycle")!
			.isTemplate(true)
		let imavatar = NSImage(named: "avatar")!

		let lightMode = NSImage(named: "sun")!.isTemplate(true)
		let darkMode  = NSImage(named: "moon")!.isTemplate(true)
		let imageBinding = Bind<NSImage?>(NSApp.isDarkMode() ? darkMode : lightMode)

		let isPopoverVisible = Bind(false)

		return NSView(layoutStyle: .centered) {

			return VStack(spacing: 20) {
				HStack {
					NSVisualEffectView.lightMode {
						NSTextField(label: "Aqua style (light mode)")
							.padding()
					}

					NSVisualEffectView.darkMode {
						NSTextField(label: "Dark Aqua style (dark mode)")
							.padding()
					}
				}

				HStack {
					NSVisualEffectView(material: .popover) {
						NSTextField(label: "Material = .popover")
							.padding()
					}
					.debugFrame()

					NSVisualEffectView(material: .sidebar) {
						NSTextField(label: "Material = .sidebar")
							.padding()
					}
				}

				HDivider()

				HStack {
					NSVisualEffectView() {
						HStack(spacing: 10) {
							CircularAvatarView()
								.avatarImage(imavatar)
								.frame(width: 38, height: 38)
								.shadow(offset: CGSize(width: 1, height: -1), color: .black.withAlphaComponent(0.7), blurRadius: 3)
								.popover(isVisible: isPopoverVisible, preferredEdge: .minY) {
									CircularAvatarView()
										.avatarImage(imavatar)
										.frame(width: 128, height: 128)
										.padding()
								}
								.onClickGesture {
									isPopoverVisible.wrappedValue = true
								}
							VStack(alignment: .leading, spacing: 2) {
								NSTextField(label: "Distance")
									.font(.headline)
								NSTextField(label: "12.5 MI")
									.font(.body)
							}
							VDivider()
							VStack(alignment: .leading, spacing: 2) {
								NSTextField(label: "Training Effort")
									.font(.headline)
								NSTextField(label: "Moderate")
									.font(.body)
							}
						}
						.padding(8)
					}
					.backgroundCornerRadius(12)
					.backgroundBorder(.quaternaryLabelColor, lineWidth: 0.5)
					.identifier("vs1")

					NSVisualEffectView() {
						HStack {
							NSButton()
								.isBordered(false)
								.image(imleft)
								.imageScaling(.scaleProportionallyDown)
								.imagePosition(.imageOnly)
								.frame(width: 8, height: 8)
								.onAction { _ in model.log("Pressed Backward") }
							VStack(spacing: 0) {
								NSImageView(image: imcycle)
									.imageScaling(.scaleProportionallyUpOrDown)
									.frame(width: 28, height: 28)
								NSTextField(label: "Cycling")
									.font(.footnote.weight(.semibold))
							}
							NSButton()
								.isBordered(false)
								.image(imright)
								.imageScaling(.scaleProportionallyDown)
								.imagePosition(.imageOnly)
								.frame(width: 8, height: 8)
								.onAction { _ in model.log("Pressed Forward") }
						}
						.padding(8)
					}
					.backgroundCornerRadius(12)
					.backgroundBorder(.quaternaryLabelColor, lineWidth: 0.5)
					.identifier("vs2")

					NSImageView()
						.image(imageBinding)
						.onAppearanceChange {
							imageBinding.wrappedValue = NSApp.isDarkMode() ? darkMode : lightMode
						}
						.padding(8)
						.identifier("vs3")
						.background(
							NSVisualEffectView()
								.cornerRadius(12)
								.border(.quaternaryLabelColor, lineWidth: 0.5)
						)
				}
				.equalHeights(["vs1", "vs2", "vs3"])
			}

		}
	}
}

#if DEBUG
@available(macOS 14, *)
#Preview("Standard") {
	VisualEffectPane().make(model: Model())
}
#endif
