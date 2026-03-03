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

@available(macOS 14.0, *)
@MainActor
extension NSMenuItem {
	/// Creates a palette style menu displaying user-selectable color tags that tint using the specified array of colors.
	/// - Parameters:
	///   - colors: The display colors for the menu items.
	///   - selectionMode: The selection mode for items in the palette
	///   - template: The image the system displays for the menu items.
	@inlinable
	public static func palette(
		_ colors: [NSColor],
		selectionMode: NSMenu.SelectionMode = .selectAny,
		template: NSImage? = nil
	) -> NSMenuItemPalette {
		NSMenuItemPalette(colors: colors, selectionMode: selectionMode, template: template)
	}

	/// Creates a palette style menu displaying user-selectable color tags that tint using the specified array of colors.
	/// - Parameters:
	///   - colors: The display items for the menu items.
	///   - selectionMode: The selection mode for items in the palette
	///   - template: The image the system displays for the menu items.
	@inlinable
	public static func palette(
		_ items: [NSMenuItemPalette.ColorItem],
		selectionMode: NSMenu.SelectionMode = .selectAny,
		template: NSImage? = nil
	) -> NSMenuItemPalette {
		NSMenuItemPalette(items, selectionMode: selectionMode, template: template)
	}

	/// Creates a palette style menu displaying user-selectable color tags that tint using the specified array of colors.
	/// - Parameters:
	///   - icons: The display colors for the menu items.
	///   - selectionMode: The selection mode for items in the palette
	@inlinable
	public static func palette(
		_ icons: [NSMenuItemPalette.IconItem],
		selectionMode: NSMenu.SelectionMode = .selectAny
	) -> NSMenuItemPalette {
		NSMenuItemPalette(icons, selectionMode: selectionMode)
	}
}

/// A menu item that contains a selectable color palette
@available(macOS 14.0, *)
@MainActor
public class NSMenuItemPalette: NSMenuItem {

	/// An item within a color palette
	public struct ColorItem {
		let title: String
		let color: NSColor

		/// Create a color palette item
		/// - Parameters:
		///   - color: The color
		///   - title: The title
		public init(_ color: NSColor, title: String = "") {
			self.title = title
			self.color = color.makeCopy()
		}

		@inlinable
		public static func color(_ color: NSColor, title: String = "") -> ColorItem {
			ColorItem(color, title: title)
		}
	}

	/// An icon within the palette
	public struct IconItem {
		let title: String
		let image: NSImage

		/// Create a color palette item
		/// - Parameters:
		///   - color: The color
		///   - title: The title
		public init(_ image: NSImage, title: String = "") {
			self.title = title
			self.image = image.makeCopy()
		}

		@inlinable
		public static func icon(_ image: NSImage, title: String = "") -> IconItem {
			IconItem(image, title: title)
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
		self.init(colors.map { NSMenuItemPalette.ColorItem($0) }, selectionMode: selectionMode, template: template)
	}

	/// Creates a palette style menu displaying user-selectable color tags that tint using the specified array of colors.
	/// - Parameters:
	///   - items: The display items for the menu items.
	///   - selectionMode: The selection mode for items in the palette
	///   - template: The image the system displays for the menu items.
	public init(
		_ items: [NSMenuItemPalette.ColorItem],
		selectionMode: NSMenu.SelectionMode = .selectAny,
		template: NSImage? = nil
	) {

		super.init(title: "", action: nil, keyEquivalent: "")

		let paletteMenu = NSMenu.palette(
			colors: items.map { $0.color },
			titles: items.map { $0.title },
			template: template,
			onSelectionChange: { @MainActor [weak self] menu in
				self?.userChangedSelection(menu)
			}
		)
		paletteMenu.selectionMode = selectionMode

		self.submenu = paletteMenu
	}

	/// Creates a palette style menu displaying user-selectable color tags that tint using the specified array of colors.
	/// - Parameters:
	///   - icons: An array of icon images
	///   - selectionMode: The selection mode for items in the palette
	public init(
		_ icons: [NSMenuItemPalette.IconItem],
		selectionMode: NSMenu.SelectionMode = .selectAny
	) {

		super.init(title: "", action: nil, keyEquivalent: "")

		let items = icons.map {
			let item = NSMenuItem(title: $0.title, action: #selector(userChangedSelection(_:)), keyEquivalent: "")
			item.target = self
			item.image = $0.image.makeCopy()
			return item
		}

		let paletteMenu = NSMenu(title: "", items: items)
		paletteMenu.presentationStyle = .palette
		paletteMenu.selectionMode = selectionMode
		self.submenu = paletteMenu
	}




	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		os_log("deinit: NSMenuItemPalette", log: logger, type: .debug)
	}

	// The palette menu
	private var paletteMenu: NSMenu { self.submenu! }
	// The selected indexes in the palette
	private var currentSelectionIndexes: Set<Int> {
		let indexes = self.paletteMenu.items
			.enumerated()
			.compactMap { $0.element.state == .on ? $0.offset : nil }
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
@MainActor extension NSMenuItemPalette {

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
@MainActor extension NSMenuItemPalette {
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
@MainActor extension NSMenuItemPalette {
	/// Bind the selection
	/// - Parameter selection: The selection binding
	/// - Returns: self
	@discardableResult
	public func selection(_ selection: Bind<Set<Int>>) -> Self {
		self.selectionBinding = selection

		selection.register(self) { @MainActor [weak self] newSelections in
			guard let `self` = self, newSelections != self.currentSelectionIndexes else {
				return
			}

			// Select the indexes in the menu
			self.selectIndexes(newSelections)

			// If the binding changes from _outside_ the control (eg. a reset button sets the selection to empty),
			// make sure we reflect this change to the user's `onSelectionChange` callback
			self.onSelectionChangeBlock?(newSelections)
		}

		self.selectIndexes(selection.wrappedValue)

		return self
	}

	private func selectIndexes(_ indexes: Set<Int>) {
		self.paletteMenu.items.enumerated().forEach { item in
			item.element.state = indexes.contains(item.offset) ? .on : .off
		}
	}
}

// MARK: - Private

@available(macOS 14.0, *)
@MainActor
extension NSMenuItemPalette {
	// Called when the _user_ changes the selection via the control
	@objc private func userChangedSelection(_ menu: NSMenu) {
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
#Preview("color palette") {
	let selected = Bind(Set([2])) { n in Swift.print(".binding: \(n)") }
	let selected2 = Bind(Set<Int>()) { n in Swift.print(".binding2: \(n)") }
	let selected3 = Bind(Set<Int>([3, 2])) { n in Swift.print(".binding3: \(n)") }
	VStack {
		HStack {
			NSPopUpButton()
				.menu(
					NSMenu(title: "title") {
						NSMenuItem(title: "Menu palette items")

						NSMenuItem.sectionHeader(title: "Multiple selection")

						NSMenuItem.palette([.systemRed, .systemGreen, .systemBlue, .systemBrown, .black, .white])
							.selection(selected)
							.onSelectionChange { newSelection in
								Swift.print(".onSelectionChange: \(newSelection)")
							}

						NSMenuItem.sectionHeader(title: "Single selection")

						NSMenuItem.palette(
							[.systemRed, .systemGreen, .systemBlue, .systemBrown, .black, .white],
							template: NSImage(systemSymbolName: "lightbulb.fill")!
						)
						.selectionMode(.selectOne)
						.selection(selected2)
						.onSelectionChange { newSelection in
							Swift.print(".onSelectionChange2: \(newSelection)")
						}

						NSMenuItem.sectionHeader(title: "Multiple with custom selection")

						NSMenuItem.palette([.systemRed, .systemGreen, .systemBlue, .systemBrown, .black, .white])
							.onStateImage(NSImage(systemSymbolName: "circle.fill")!)
							.offStateImage(NSImage(systemSymbolName: "circle")!)
							.selection(selected3)
							.onSelectionChange { newSelection in
								Swift.print(".onSelectionChange3: \(newSelection)")
							}
					}
				)
			NSButton(title: "Reset selection") { _ in
				selected.wrappedValue = Set(arrayLiteral: 2)
				selected2.wrappedValue = Set()
				selected3.wrappedValue = Set([3, 2])
			}
			.isEnabled(selected.oneWayTransform { $0.count > 0 } )
		}
	}
}

@available(macOS 14, *)
#Preview("icon palette") {
	VStack {
		let allIcons: [NSMenuItemPalette.IconItem] = [
			.icon(NSImage(systemSymbolName: "figure.barre", accessibilityDescription: "Barre")!.isTemplate(true), title: "Barre"),
			.icon(NSImage(systemSymbolName: "figure.american.football", accessibilityDescription: "American Football")!.isTemplate(true), title: "American Football"),
			.icon(NSImage(systemSymbolName: "figure.indoor.soccer", accessibilityDescription: "Indoor Soccer")!.isTemplate(true), title: "Indoor Soccer"),
			.icon(NSImage(systemSymbolName: "figure.fishing", accessibilityDescription: "Fishing")!.isTemplate(true), title: "Fishing"),
			.icon(NSImage(systemSymbolName: "figure.roll", accessibilityDescription: "Wheelchair Soccer")!.isTemplate(true), title: "Wheelchair Soccer"),
		]

		var selectedImage: NSImage? {
			if let s = selected.wrappedValue.first {
				return allIcons[s].image
			}
			return nil
		}

		let selected = Bind(Set([1])) { n in Swift.print(".binding: \(n)") }
		let selectedImageBinding = Bind<NSImage?>(selectedImage)

		HStack {
			NSPopUpButton()
				.menu(
					NSMenu(title: "title") {
						NSMenuItem(title: "Select single item")
						NSMenuItem.palette(allIcons, selectionMode: .selectOne)
							.selection(selected)
							.onSelectionChange { selected in
								if let s = selected.first {
									selectedImageBinding.wrappedValue = allIcons[s].image
								}
							}
					}
				)
			NSImageView(image: selectedImageBinding)
				.frame(dimension: 32)
				.imageScaling(.scaleProportionallyUpOrDown)
				.debugFrame()

			NSButton(title: "Reset") { _ in
				selected.wrappedValue = Set([1])
			}
		}

		let selected2 = Bind(Set([1, 3])) { n in Swift.print(".binding2: \(n)") }

		HStack {
			NSButton(title: "Multiple select")
				.onActionMenu(
					NSMenu(title: "title") {
						NSMenuItem.sectionHeader("Select multiple items")
						NSMenuItem.palette(allIcons, selectionMode: .selectAny)
							.selection(selected2)
					}
				)

			NSButton(title: "Reset") { _ in
				selected2.wrappedValue = Set([1, 3])
			}
		}
	}
}

#endif
