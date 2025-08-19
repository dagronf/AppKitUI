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

@MainActor
public extension NSMenuItem {
	/// Create a menu item with a title
	/// - Parameters:
	///   - title: The title
	///   - onActionBlock: The block to call when the user performs the action
	convenience init(title: String, onActionBlock: ((NSMenuItem) -> Void)? = nil) {
		self.init()
		self.title = title
		if let onActionBlock {
			self.onAction(onActionBlock)
		}
	}

	/// Create a menu item that has a submenu
	/// - Parameters:
	///   - title: The title
	///   - submenuBuilder: The submenu items
	convenience init(title: String, @NSMenuItemsBuilder submenuBuilder: () -> [NSMenuItem]) {
		self.init()
		self.title = title

		let sm = NSMenu(title: "", builder: submenuBuilder)
		self.submenu = sm
	}

	/// Create a menu item that has a submenu
	/// - Parameters:
	///   - title: The title
	///   - submenu: The submenu items
	convenience init(title: String, submenu: NSMenu) {
		self.init()
		self.title = title
		self.submenu = submenu
	}

	/// Set the menu item title
	/// - Parameter title: The title
	/// - Returns: self
	@discardableResult @inlinable
	func title(_ title: String) -> Self {
		self.title = title
		return self
	}

	/// The menu item's image
	/// - Parameter image: The image
	/// - Returns: self
	@discardableResult @inlinable
	func image(_ image: NSImage?) -> Self {
		self.image = image
		return self
	}

	/// The menu item's image as an SF Symbol (macOS 11+)
	/// - Parameter systemSymbolName: The system symbol to use as the image
	/// - Returns: self
	func image(systemSymbolName: String) -> Self {
		if #available(macOS 11.0, *) {
			if let image = NSImage(systemSymbolName: systemSymbolName, accessibilityDescription: nil) {
				self.image = image
			}
		}
		return self
	}

	/// The menu item's tooltip
	/// - Parameter toolTip: The tooltip text
	/// - Returns: self
	@discardableResult @inlinable
	func toolTip(_ toolTip: String) -> Self {
		self.toolTip = toolTip
		return self
	}

	/// The menu item's tag
	/// - Parameter tag: The menu item's tag
	/// - Returns: self
	@discardableResult @inlinable
	func tag(_ tag: Int) -> Self {
		self.tag = tag
		return self
	}

	/// Set the key equivalent for the menu item
	/// - Parameters:
	///   - keyEquivalent: The key equivalent
	///   - modifiers: The required modifiers
	/// - Returns: self
	@discardableResult @inlinable
	func keyEquivalent(_ keyEquivalent: String, modifiers: NSEvent.ModifierFlags) -> Self {
		self.keyEquivalent = keyEquivalent
		self.keyEquivalentModifierMask = modifiers
		return self
	}

	/// Set the item's indentation level
	/// - Parameter level: The indentation level
	/// - Returns: self
	@discardableResult @inlinable
	func indentationLevel(_ level: Int) -> Self {
		self.indentationLevel = level
		return self
	}

	/// The view to be displayed in the menu item
	/// - Parameter viewBuilder: A block that returns a view
	/// - Returns: self
	@discardableResult @inlinable
	func view(_ viewBuilder: () -> NSView) -> Self {
		self.view = viewBuilder()
		return self
	}

	/// Set the badge for the item (macOS 14+)
	/// - Parameter badge: The badge
	/// - Returns: self
	@available(macOS 14.0, *)
	@discardableResult @inlinable
	func badge(_ badge: NSMenuItemBadge?) -> Self {
		self.badge = badge
		return self
	}
}

// MARK: - Actions

@MainActor
public extension NSMenuItem {
	/// Provide an action block
	/// - Parameter block: A block that gets called with the menu item that caused the action
	/// - Returns: self
	@discardableResult
	func onAction(_ block: @escaping (NSMenuItem) -> Void) -> Self {
		self.usingMenuItemStorage { $0.onActionMenuItem = block }
		return self
	}

	/// Provide a validation block, called when the menu is about to display
	/// - Parameter block: The validation block, returning the enabled state for the menu item
	/// - Returns: self
	@discardableResult
	func onValidate(_ block: @escaping (NSMenuItem) -> Bool) -> Self {
		self.usingMenuItemStorage { $0.onValidate = block }
		return self
	}
}

// MARK: - Bindings

@MainActor
public extension NSMenuItem {
	/// Bind the enabled status of the menu item
	/// - Parameter isEnabled: The isEnabled binding
	/// - Returns: self
	@discardableResult
	func isEnabled(_ isEnabled: Bind<Bool>) -> Self {
		self.usingMenuItemStorage { $0.onValidateBond = isEnabled }
		return self
	}

	/// Set the menu item state
	/// - Parameter isEnabled: The isEnabled binding
	/// - Returns: self
	@discardableResult @inlinable
	func isEnabled(_ isEnabled: Bool) -> Self {
		self.isEnabled(Bind(isEnabled))
	}

	/// Set the isHidden status
	/// - Parameter isHidden: The isHidden binding
	/// - Returns: self
	@discardableResult
	func isHidden(_ isHidden: Bind<Bool>) -> Self {
		isHidden.register(self) { @MainActor [weak self] newHiddenState in
			if self?.isHidden != newHiddenState {
				self?.isHidden = newHiddenState
			}
		}

		self.isHidden = isHidden.wrappedValue
		return self
	}

	/// Set the badge for the item (macOS 14+)
	/// - Parameter badge: The badge
	/// - Returns: self
	@available(macOS 14.0, *)
	@discardableResult
	func badge(_ badge: Bind<NSMenuItemBadge?>) -> Self {
		badge.register(self) { @MainActor [weak self] newBadge in
			self?.badge = newBadge
		}

		self.badge = badge.wrappedValue

		return self
	}
}

// MARK: - Storage

@MainActor
private extension NSMenuItem {
	@MainActor class Storage: NSObject, NSMenuItemValidation {
		var onActionMenuItem: ((NSMenuItem) -> Void)?
		var onValidate: ((NSMenuItem) -> Bool)?
		var onValidateBond: Bind<Bool>?

		weak var parent: NSMenuItem?

		init(_ parent: NSMenuItem) {
			super.init()

			self.parent = parent
			parent.target = self
			parent.action = #selector(onActionCalled(_:))
		}

		deinit {
			os_log("deinit: NSMenuItem.Storage", log: logger, type: .debug)
		}

		@objc private func onActionCalled(_ sender: NSMenuItem) {
			self.onActionMenuItem?(sender)
		}

		func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
			if menuItem == self.parent {
				if let t = onValidateBond {
					return t.wrappedValue
				}

				if let f = self.onValidate {
					return f(menuItem)
				}
			}
			// If there's no specified validation logic, just return true
			return true
		}
	}

	func usingMenuItemStorage(_ block: @escaping (Storage) -> Void) {
		self.usingAssociatedValue(key: "__nsmenuitem_bond", initialValue: { Storage(self) }, block)
	}
}

// MARK: - NSMenuItem builders

@MainActor
@resultBuilder
public enum NSMenuItemsBuilder {
	public static func buildBlock() -> [NSMenuItem] { [] }
}

@MainActor
public extension NSMenuItemsBuilder {
	static func buildBlock(_ settings: NSMenuItem...) -> [NSMenuItem] {
		settings
	}

	static func buildBlock(_ settings: [NSMenuItem]) -> [NSMenuItem] {
		settings
	}

	static func buildOptional(_ component: [NSMenuItem]?) -> [NSMenuItem] {
		component ?? []
	}

	/// Add support for if statements.
	static func buildEither(first components: [NSMenuItem]) -> [NSMenuItem] {
		 components
	}

	static func buildEither(second components: [NSMenuItem]) -> [NSMenuItem] {
		 components
	}

	/// Add support for loops.
	static func buildArray(_ components: [[NSMenuItem]]) -> [NSMenuItem] {
		 components.flatMap { $0 }
	}
}
