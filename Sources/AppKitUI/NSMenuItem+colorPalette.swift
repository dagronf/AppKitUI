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
import os.log

@available(macOS 14.0, *)
@MainActor
public extension NSMenuItem {
	/// Creates a palette style menu displaying user-selectable color tags that tint using the specified array of colors.
	/// - Parameters:
	///   - colors: The display colors for the menu items.
	///   - selectionMode: The selection mode for items in the palette
	///   - template: The image the system displays for the menu items.
	@inlinable
	public static func colorPalette(
		_ colors: [NSColor],
		selectionMode: NSMenu.SelectionMode = .selectAny,
		template: NSImage? = nil
	) -> NSMenuItemColorPalette {
		NSMenuItemColorPalette(colors: colors, selectionMode: selectionMode, template: template)
	}

	/// Creates a palette style menu displaying user-selectable color tags that tint using the specified array of colors.
	/// - Parameters:
	///   - colors: The display items for the menu items.
	///   - selectionMode: The selection mode for items in the palette
	///   - template: The image the system displays for the menu items.
	@inlinable
	public static func colorPalette(
		_ items: [NSMenuItemColorPalette.Item],
		selectionMode: NSMenu.SelectionMode = .selectAny,
		template: NSImage? = nil
	) -> NSMenuItemColorPalette {
		NSMenuItemColorPalette(items, selectionMode: selectionMode, template: template)
	}
}

/// A menu item that contains a selectable color palette
@available(macOS 14.0, *)
@MainActor
public class NSMenuItemColorPalette: NSMenuItem {

	/// An item within a color palette
	public struct Item {
		let title: String
		let color: NSColor

		/// Create a color palette item
		/// - Parameters:
		///   - color: The color
		///   - title: The title
		public init(_ color: NSColor, _ title: String = "") {
			self.title = title
			self.color = color.makeCopy()
		}
	}

	/// Creates a palette style menu displaying user-selectable color tags that tint using the specified array of colors.
	/// - Parameters:
	///   - colors: The display colors for the menu items.
	///   - selectionMode: The selection mode for items in the palette
	///   - template: The image the system displays for the menu items.
	public convenience init(
		colors: [NSColor],
		selectionMode: NSMenu.SelectionMode = .selectAny,
		template: NSImage? = nil
	) {
		self.init(colors.map { NSMenuItemColorPalette.Item($0) }, selectionMode: selectionMode, template: template)
	}

	/// Creates a palette style menu displaying user-selectable color tags that tint using the specified array of colors.
	/// - Parameters:
	///   - items: The display items for the menu items.
	///   - selectionMode: The selection mode for items in the palette
	///   - template: The image the system displays for the menu items.
	public init(
		_ items: [NSMenuItemColorPalette.Item],
		selectionMode: NSMenu.SelectionMode = .selectAny,
		template: NSImage? = nil
	) {

		super.init(title: "", action: nil, keyEquivalent: "")

		let paletteMenu = NSMenu.palette(
			colors: items.map { $0.color },
			titles: items.map { $0.title },
			template: template,
			onSelectionChange: { @MainActor [weak self] menu in
				self?.onSelectionChange(menu)
			}
		)
		paletteMenu.selectionMode = selectionMode

		self.submenu = paletteMenu
	}
	
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		os_log("deinit: NSMenuItemColorPalette", log: logger, type: .debug)
	}

	// The palette menu
	private var paletteMenu: NSMenu { self.submenu! }
	// The current selections in the color palette
	private var currentSelectionIndexes: Set<Int> {
		let indexes = self.paletteMenu.selectedItems
			.map { self.paletteMenu.index(of: $0) }
			.filter { $0 >= 0 }
		return Set(indexes)
	}
	// Return the menu items at the specified index(es)
	private func items(at indexes: Set<Int>) -> [NSMenuItem] {
		indexes.compactMap { self.paletteMenu.item(at: $0) }
	}

	private var selectionBinding: Bind<Set<Int>>?
	private var onSelectionChangeBlock: ((Set<Int>) -> Void)?
}

// MARK: - Modifiers

@available(macOS 14.0, *)
@MainActor extension NSMenuItemColorPalette {

	/// The selection mode for the menu item
	@discardableResult
	public func selectionMode(_ mode: NSMenu.SelectionMode) -> Self {
		self.paletteMenu.selectionMode = mode
		return self
	}

	/// The image of the menu item that indicates an “on” state.
	@discardableResult
	public func onStateImage(_ image: NSImage?) -> Self {
		self.paletteMenu.items.forEach { $0.onStateImage = image }
		return self
	}

	/// The image of the menu item that indicates an “off” state.
	@discardableResult
	public func offStateImage(_ image: NSImage?) -> Self {
		self.paletteMenu.items.forEach { $0.offStateImage = image }
		return self
	}
}

// MARK: - Actions

@available(macOS 14.0, *)
@MainActor extension NSMenuItemColorPalette {
	/// A callback block for when the selection changes
	/// - Parameter block: The block to call
	/// - Returns: self
	@discardableResult
	public func onSelectionChange(_ block: @escaping (Set<Int>) -> Void) -> Self {
		self.onSelectionChangeBlock = block
		return self
	}
}

// MARK: - Bindings

@available(macOS 14.0, *)
@MainActor extension NSMenuItemColorPalette {
	/// Bind the color palette selection
	/// - Parameter selection: The selection binding
	/// - Returns: self
	@discardableResult
	public func selection(_ selection: Bind<Set<Int>>) -> Self {
		self.selectionBinding = selection

		selection.register(self) { @MainActor [weak self] newSelections in
			guard let `self` = self else { return }
			if newSelections == self.currentSelectionIndexes { return }
			let sels = self.paletteMenu.items
				.enumerated()
				.filter { newSelections.contains($0.offset) }
				.map { $0.element }
			self.paletteMenu.selectedItems = sels

			// If the binding changes from _outside_ the control (eg. a reset button sets the selection to empty),
			// make sure we reflect this change to the user's `onSelectionChange` callback
			self.onSelectionChangeBlock?(newSelections)
		}

		self.paletteMenu.selectedItems = self.items(at: selection.wrappedValue)

		return self
	}
}

// MARK: - Private

@available(macOS 14.0, *)
@MainActor
extension NSMenuItemColorPalette {
	// Called when the _user_ changes the selection via the control
	private func onSelectionChange(_ menu: NSMenu) {
		// Get the new selection from the control
		let selection = self.currentSelectionIndexes

		// If the selection binding exists, pass the new selection
		self.selectionBinding?.wrappedValue = selection

		// If the selection change block exists, pass the new selection
		self.onSelectionChangeBlock?(selection)
	}
}

// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("basic palette") {
	let selected = Bind(Set(arrayLiteral: 2)) { n in Swift.print(".binding: \(n)") }
	let selected2 = Bind(Set<Int>()) { n in Swift.print(".binding2: \(n)") }
	VStack {
		HStack {
			NSPopUpButton()
				.menu(
					NSMenu(title: "title") {
						NSMenuItem(title: "Select multiple items")

						NSMenuItemColorPalette(colors: [.systemRed, .systemGreen, .systemBlue, .systemBrown, .black, .white])
							.selection(selected)
							.onSelectionChange { newSelection in
								Swift.print(".onSelectionChange: \(newSelection)")
							}

						NSMenuItem(title: "Select a single item")

						NSMenuItem.colorPalette(
							[.systemRed, .systemGreen, .systemBlue, .systemBrown, .black, .white],
							template: NSImage(systemSymbolName: "lightbulb.fill")!
						)
						.selectionMode(.selectOne)
						.selection(selected2)
						.onSelectionChange { newSelection in
							Swift.print(".onSelectionChange2: \(newSelection)")
						}

						NSMenuItem(title: "Fourth one")

						NSMenuItem.colorPalette([.systemRed, .systemGreen, .systemBlue, .systemBrown, .black, .white])
							.onStateImage(NSImage(systemSymbolName: "lightswitch.on")!)
							.offStateImage(NSImage(systemSymbolName: "lightswitch.off")!)
							.selection(selected2)
							.onSelectionChange { newSelection in
								Swift.print(".onSelectionChange2: \(newSelection)")
							}
					}
				)
			NSButton(title: "Reset selection") { _ in
				selected.wrappedValue = Set()
			}
			.isEnabled(selected.oneWayTransform { $0.count > 0 } )
		}
	}
}

@available(macOS 14, *)
#Preview("color palette") {
	VStack {
	}
}

#endif
