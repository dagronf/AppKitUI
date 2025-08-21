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

class ShadowsPane: Pane {
	override func title() -> String { "Shadow Tests" }
	@MainActor
	override func make(model: Model) -> NSView {
		return NSView(layoutStyle: .centered) {
			VStack {
				VStack {
					for mode in [false, true] {
						NSVisualEffectView(isDarkMode: mode) {
							HStack(spacing: 20) {
								Rectangle()
									.fill(color: .systemRed)
									.stroke(.textColor, lineWidth: 0.5)
									.shadow(offset: CGSize(width: 1, height: -1), color: .textColor, blurRadius: 3)
									.frame(width: 50, height: 50)
									.overlay(NSView(layoutStyle: .centered) { NSTextField(label: "1").font(.title2) })
								Rectangle()
									.fill(color: .systemGreen)
									.stroke(.textColor, lineWidth: 0.5)
									.shadow(offset: CGSize(width: 0, height: 0), color: .textColor, blurRadius: 5)
									.frame(width: 50, height: 50)
									.overlay(NSView(layoutStyle: .centered) { NSTextField(label: "2").font(.title2) })
								Rectangle()
									.fill(color: .systemBlue)
									.stroke(.textColor, lineWidth: 0.5)
									.shadow(offset: CGSize(width: -2, height: 2), color: .textColor, blurRadius: 3)
									.frame(width: 50, height: 50)
									.overlay(NSView(layoutStyle: .centered) { NSTextField(label: "3").font(.title2) })
								Rectangle()
									.fill(color: .systemYellow)
									.stroke(.textColor, lineWidth: 0.5)
									.cornerRadius(5)
									.shadow(offset: CGSize(width: 0, height: 0), color: .textColor, blurRadius: 10)
									.frame(width: 50, height: 50)
									.overlay(NSView(layoutStyle: .centered) { NSTextField(label: "4").font(.title2) })
							}
							.padding()
							.backgroundBorder(.white, lineWidth: 1)
						}
					}
				}

				HStack(spacing: 20) {
					NSView()
						.backgroundFill(.systemRed)
						.shadow(offset: CGSize(width: 1, height: -1), color: .textColor, blurRadius: 3)
						.frame(width: 50, height: 50)
					NSView()
						.backgroundFill(.systemGreen)
						.shadow(offset: CGSize(width: 0, height: 0), color: .textColor, blurRadius: 5)
						.frame(width: 50, height: 50)
					NSView()
						.backgroundFill(.systemBlue)
						.shadow(offset: CGSize(width: -2, height: 2), color: .textColor, blurRadius: 3)
						.frame(width: 50, height: 50)
					NSView()
						.backgroundFill(.systemYellow)
						.backgroundCornerRadius(5)
						.shadow(offset: CGSize(width: 0, height: 0), color: .black, blurRadius: 10)
						.frame(width: 50, height: 50)
					NSView()
						.backgroundBorder(.textColor, lineWidth: 2)
						.backgroundFill(.quaternaryLabelColor)
						.frame(width: 50, height: 50)
					NSView()
						.backgroundBorder(DynamicColor(dark: .systemRed, light: .systemBlue), lineWidth: 2)
						.frame(width: 50, height: 50)
				}
				.padding()
			}
		}
	}
}

#if DEBUG
@available(macOS 14, *)
#Preview("Basic") {
	ShadowsPane().make(model: Model())
}
#endif
