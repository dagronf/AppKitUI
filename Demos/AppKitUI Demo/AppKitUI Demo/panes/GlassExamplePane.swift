//
//  Copyright © 2026 Darren Ford. All rights reserved.
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

class GlassExamplePane: Pane {
	override func title() -> String { "Glass demo" }
	@MainActor
	override func make(model: Model) -> NSView {
		ScrollView(borderType: .noBorder, fitHorizontally: true) {
			VStack(spacing: 16) {
				VStack {
					NSTextField(label: "Glass effect wrapping an HStack of buttons")
						.font(.headline)
					GlassEffect {
						HStack {
							NSButton.image(.named(NSImage.touchBarGoBackTemplateName), imageScaling: .scaleProportionallyUpOrDown)
								.frame(dimension: 22)
								.onAction { state in model.log("Clicked go left") }
							NSButton.image(.named(NSImage.touchBarAudioInputTemplateName), imageScaling: .scaleProportionallyUpOrDown)
								.frame(dimension: 22)
								.onAction { state in model.log("Clicked auto input") }
							NSButton.image(.named(NSImage.touchBarGoForwardTemplateName), imageScaling: .scaleProportionallyUpOrDown)
								.frame(dimension: 22)
								.onAction { state in model.log("Clicked go right") }
						}
						.padding(12)
					}
				}

				HDivider()

				VStack {
					NSTextField(label: "HStack containins buttons with Glass effect")
						.font(.headline)
					HStack {
						NSButton.image(.named(NSImage.touchBarGoBackTemplateName), imageScaling: .scaleProportionallyUpOrDown)
							.frame(dimension: 22)
							.onAction { state in model.log("Clicked go left") }
							.glassEffect()
						NSButton.image(.named(NSImage.touchBarAudioInputTemplateName), imageScaling: .scaleProportionallyUpOrDown)
							.frame(dimension: 22)
							.onAction { state in model.log("Clicked auto input") }
							.glassEffect()
						NSButton.image(.named(NSImage.touchBarGoForwardTemplateName), imageScaling: .scaleProportionallyUpOrDown)
							.frame(dimension: 22)
							.onAction { state in model.log("Clicked go right") }
							.glassEffect()
					}
					.padding(12)
				}

				HDivider()

				VStack {
					NSTextField(label: "Glass effect group containing 3 'glass' buttons")
						.font(.headline)
					GlassEffectContainer {
						HStack {
							NSButton.image(.named(NSImage.touchBarGoBackTemplateName), imageScaling: .scaleProportionallyUpOrDown)
								.frame(dimension: 22)
								.onAction { state in model.log("Clicked go left") }
								.glassEffect()
							NSButton.image(.named(NSImage.touchBarAudioInputTemplateName), imageScaling: .scaleProportionallyUpOrDown)
								.frame(dimension: 22)
								.onAction { state in model.log("Clicked auto input") }
								.glassEffect()
							NSButton.image(.named(NSImage.touchBarGoForwardTemplateName), imageScaling: .scaleProportionallyUpOrDown)
								.frame(dimension: 22)
								.onAction { state in model.log("Clicked go right") }
								.glassEffect()
						}
						.padding(12)
					}
				}

				HDivider()

				VStack {
					NSTextField(label: "Glass effect group (spacing: 30)")
						.font(.headline)
					GlassEffectContainer(spacing: 30) {
						HStack {
							NSButton.image(.named(NSImage.touchBarGoBackTemplateName), imageScaling: .scaleProportionallyUpOrDown)
								.frame(dimension: 22)
								.onAction { state in model.log("Clicked go left") }
								.glassEffect()
							NSButton.image(.named(NSImage.touchBarAudioInputTemplateName), imageScaling: .scaleProportionallyUpOrDown)
								.frame(dimension: 22)
								.onAction { state in model.log("Clicked auto input") }
								.glassEffect()
							NSButton.image(.named(NSImage.touchBarGoForwardTemplateName), imageScaling: .scaleProportionallyUpOrDown)
								.frame(dimension: 22)
								.onAction { state in model.log("Clicked go right") }
								.glassEffect()
						}
						.padding(12)
					}
				}
			}
			.padding()
			.debugFrames()
		}
	}
}

#if DEBUG
@available(macOS 14, *)
#Preview("basic") {
	GlassExamplePane().make(model: Model())
}
#endif
