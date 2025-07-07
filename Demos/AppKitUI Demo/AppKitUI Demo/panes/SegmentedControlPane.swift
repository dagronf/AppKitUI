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

@MainActor private let _dropDownImage = NSImage(named: "NSDropDownIndicatorTemplate")!
@MainActor private let _segmentImage = NSImage(named: "NSToolbarPrintItemImage")!



class SegmentedControlPane: Pane {
	override func title() -> String { "Segment Controls" }
	@MainActor
	override func make(model: Model) -> NSView {
		let selIndex = Bind(1)
		let enabledSegments = Bind(Set([0, 1, 3]))

		return ScrollView(borderType: .noBorder) {
			VStack(spacing: 12) {
				NSSegmentedControl()
					.segments(["one", "two", "three"])
					.selectedIndex(selIndex)
					.onSelectionChange {
						model.log("NSSegmentedControl change: \($0)")
					}

				NSSegmentedControl()
					.trackingMode(.selectAny)
					.segments(["cat", "dog", "caterpillar", "noodles"])
					.onSelectionsChange { sele in
						model.log("Selections = \(sele)")
					}

				HStack {
					NSSegmentedControl()
						.style(.capsule)
						.segments(["cat", "dog", "caterpillar", "noodles"])
						.enabledIndexes(enabledSegments)
						.onSelectionsChange { sele in
							model.log("capsule = \(sele)")
						}
					NSButton(title: "Only enable segment 2")
						.controlSize(.small)
						.onAction { _ in
							enabledSegments.wrappedValue = [2]
						}
				}

				NSSegmentedControl(distribution: .fillEqually) {
					NSSegmentedControl.Segment(
						title: "Colors",
						image: NSImage(named: NSImage.colorPanelName),
						imageScaling: .scaleProportionallyDown,
						toolTip: "Colors segment"
					)
					NSSegmentedControl.Segment(
						title: "Machine",
						image: NSImage(named: NSImage.computerName),
						imageScaling: .scaleProportionallyDown,
						toolTip: "Machine segment",
						menu: NSMenu(title: "wheee") {
							NSMenuItem(title: "First") { item in
								model.log("'\(item.title)' selected")
							}
							NSMenuItem(title: "Second") { item in
								model.log("'\(item.title)' selected")
							}
						},
						showsMenuIndicator: true
					)
					NSSegmentedControl.Segment(
						title: "Everyone else",
						image: NSImage(named: NSImage.everyoneName),
						imageScaling: .scaleProportionallyDown,
						toolTip: "Everyone else segment"
					)
				}

				HDivider()

				HStack {
					{
						if #available(macOS 11, *) {
							NSSegmentedControl()
								.controlSize(.large)
								.trackingMode(.momentary)
								.segments(["Thingy", ""])
								.image(_segmentImage, imageScaling: .scaleProportionallyDown, forSegmentIndex: 0)
								.image(_dropDownImage, imageScaling: .scaleProportionallyDown, forSegmentIndex: 1)
								.menu(
									NSMenu(title: "One") {
										NSMenuItem(title: "fish")
									},
									forSegment: 1
								)
								.onSelectionChange { value in
									model.log("newvalue -> \(value)")
								}
						}
						else {
							NSView.empty
						}
					}()

					NSSegmentedControl()
						.trackingMode(.momentary)
						.segments(["Thingy", ""])
						.image(_segmentImage, imageScaling: .scaleProportionallyDown, forSegmentIndex: 0)
						.image(_dropDownImage, imageScaling: .scaleProportionallyDown, forSegmentIndex: 1)
						.menu(
							NSMenu(title: "One") {
								NSMenuItem(title: "fish")
							},
							forSegment: 1
						)
					NSSegmentedControl()
						.controlSize(.small)
						.trackingMode(.momentary)
						.font(.caption1)
						.segments(["Thingy", ""])
						.image(_segmentImage, imageScaling: .scaleProportionallyDown, forSegmentIndex: 0)
						.image(_dropDownImage, imageScaling: .scaleProportionallyDown, forSegmentIndex: 1)
						.menu(
							NSMenu(title: "One") {
								NSMenuItem(title: "fish")
							},
							forSegment: 1
						)

					NSSegmentedControl()
						.controlSize(.mini)
						.trackingMode(.momentary)
						.font(.footnote)
						.segments(["Thingy", ""])
						.image(_segmentImage, imageScaling: .scaleProportionallyDown, forSegmentIndex: 0)
						.image(_dropDownImage, imageScaling: .scaleProportionallyDown, forSegmentIndex: 1)
						.menu(
							NSMenu(title: "One") {
								NSMenuItem(title: "fish")
							},
							forSegment: 1
						)
				}
			}
		}
	}
}

#if DEBUG
@available(macOS 14, *)
#Preview("Basic Segmented Controls") {
	SegmentedControlPane().make(model: Model())
}
#endif
