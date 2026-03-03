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
import os.log

@MainActor
extension NSMenuItem {
	/// Creates a palette style menu displaying user-selectable color tags that tint using the specified array of colors.
	/// - Parameters:
	///   - colors: The display colors for the menu items.
	///   - selectionMode: The selection mode for items in the palette
	///   - template: The image the system displays for the menu items.
	@inlinable
	public static func view(_ viewBuilder: () -> NSView) -> NSMenuItemView {
		NSMenuItemView(viewBuilder)
	}
}

/// A menu item that contains a selectable color palette
@MainActor
public class NSMenuItemView: NSMenuItem {
	/// Creates a menu item containing a view
	/// - Parameters:
	///   - viewBuilder: The block to create the menu item's view
	public init(_ viewBuilder: () -> NSView) {
		super.init(title: "", action: nil, keyEquivalent: "")
		self.view = viewBuilder()
	}
	
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		os_log("deinit: NSMenuItemView", log: logger, type: .debug)
	}
}

// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("basic palette") {
	VStack {
		NSPopUpButton()
			.menu(
				NSMenu(title: "title") {
					NSMenuItem(title: "Custom hue")
					NSMenuItem.separator()
					NSMenuItemView {
						HStack {
							let val = Bind(0.33)
							let color = Bind(NSColor(hue: val.wrappedValue, saturation: 1, brightness: 1, alpha: 1))

							NSTextField(label: "Hue:")
								.compressionResistancePriority(.required, for: .horizontal)
							Rectangle(cornerRadius: 4)
								.frame(dimension: 18)
								.fill(color: color)
								.shadow(offset: CGSize(width: 1, height: -1), color: .black.alpha(0.6), blurRadius: 0.5)

							NSSlider(val, range: 0.0 ... 1.0)
								.numberOfTickMarks(11, allowsTickMarkValuesOnly: true)
								.tickMarkPosition(.below)
								.onChange { newValue in
									color.wrappedValue = NSColor(hue: newValue, saturation: 1, brightness: 1, alpha: 1)
								}
								.controlSize(.small)
								.width(120, priority: .defaultHigh)
						}
						.padding(top: 4, left: 22, bottom: 4, right: 22)
					}
					NSMenuItem.separator()
					NSMenuItem(title: "Something else")
						.onAction { _ in
							Swift.print("Selected 'Something else'")
						}
				}
			)
	}
}

#endif
