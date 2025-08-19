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

/// An NSComboButton equivalent that is available for all supported macOS versions
/// (NSComboButton is only available for macOS 13+)
@MainActor
public class AUIComboButton: NSSegmentedControl {
	/// The combo button style
	public enum Style {
		/// A style that separates the button’s title and image from the menu indicator people use to activate the button.
		case split
		/// A style that unifies the button’s title and image with the menu indicator.
		case unified
	}

	@MainActor
	public init(title: String, style: AUIComboButton.Style = .split, _ action: ((AUIComboButton) -> Void)? = nil) {
		super.init(frame: .zero)
		self.setup(title: title, style: style)
		if let action {
			self.onAction(action)
		}
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	/// Is the control style `.split`
	var isSplit: Bool { self.segmentCount == 2 }

	private func setup(title: String, style: AUIComboButton.Style) {
		if style == .split {
			self.cell = SegmentedAutoMenuCell()
			self.segmentCount = 2
			self.setShowsMenuIndicator(true, forSegment: 1)
			self.setEnabled(false, forSegment: 1)
		}
		else {
			self.segmentCount = 1
		}
		self.trackingMode = .momentary

		self.setLabel(title, forSegment: 0)
	}

	public override func accessibilityRole() -> NSAccessibility.Role? { .button }
	public override func accessibilityLabel() -> String? { self.label(forSegment: 0) }
}

// MARK: - Modifiers

@MainActor
public extension AUIComboButton {
	/// Set the title
	/// - Parameter string: The button's title
	/// - Returns: self
	@discardableResult @inlinable
	func title(_ string: String) -> Self {
		self.setLabel(string, forSegment: 0)
		return self
	}

	/// Set the image
	/// - Parameters:
	///   - image: The image
	///   - scaling: The scaling applied to the image
	/// - Returns: self
	@discardableResult @inlinable
	func image(_ image: NSImage, scaling: NSImageScaling = .scaleProportionallyDown) -> Self {
		self.setImage(image, forSegment: 0)
		self.setImageScaling(scaling, forSegment: 0)
		return self
	}

	/// Set the menu for the popup
	/// - Parameter menu: The menu
	/// - Returns: self
	@discardableResult
	func menu(_ menu: NSMenu) -> Self {
		if isSplit {
			self.setMenu(menu, forSegment: 1)
			self.setEnabled(true, forSegment: 1)
		}
		else {
			self.setMenu(menu, forSegment: 0)
		}
		return self
	}

	/// Create a menu using menu items
	/// - Parameter builder: The function for building
	/// - Returns: self
	@discardableResult
	func menu(@NSMenuItemsBuilder builder: () -> [NSMenuItem]) -> Self {
		let menu = NSMenu(title: self.label(forSegment: 0) ?? "menu", items: builder())
		return self.menu(menu)
	}
}

// MARK: - Actions

@MainActor
public extension AUIComboButton {
	/// Set an action for when the user clicks on the button
	/// - Parameter action: The action
	/// - Returns: self
	@discardableResult
	func onAction(_ action: @escaping (AUIComboButton) -> Void) -> Self {
		self.usingStorage { $0.onAction = action }
		return self
	}
}

// MARK: - Bindings

@MainActor
public extension AUIComboButton {
	@discardableResult
	func title(_ string: Bind<String>) -> Self {
		string.register(self) { @MainActor [weak self] newValue in
			self?.title(newValue)
		}
		return self.title(string.wrappedValue)
	}
}

// MARK: - Storage

@MainActor
private extension AUIComboButton {
	func usingStorage(_ block: @escaping (Storage) -> Void) {
		self.usingAssociatedValue(key: "__zacombobutton_bond", initialValue: { Storage(self) }, block)
	}

	@MainActor
	class Storage {
		weak var parent: AUIComboButton?
		var onAction: ((AUIComboButton) -> Void)?
		init(_ parent: AUIComboButton) {
			self.parent = parent

			parent.target = self
			parent.action = #selector(performAction(_:))
		}

		deinit {
			os_log("deinit: AUIComboButton.Storage", log: logger, type: .debug)
		}

		@objc func performAction(_ sender: AUIComboButton) {
			self.onAction?(sender)
		}
	}
}

// MARK: - Private

/// A segmented cell overload that automatically displays a menu on click if it has been set
fileprivate class SegmentedAutoMenuCell: NSSegmentedCell {
	override var action: Selector? {
		get {
			if self.menu(forSegment: self.selectedSegment) != nil {
				return nil
			}
			return super.action
		}
		set {
			super.action = newValue
		}
	}
}

// MARK: - Previews

#if DEBUG

@MainActor private let _segmentImage = NSImage(named: "NSColorPanel")!

@available(macOS 14, *)
#Preview("default") {

	let enabled = Bind(true)

	let menuItemEnabled = Bind(true)

	VStack(spacing: 12) {

		NSTextField(label: "Split buttons")
			.font(.headline)

		HStack {
			AUIComboButton(title: "Has Menu")
				.onAction { _ in
					Swift.print("[.split] Has Menu selected")
				}
				.menu(
					NSMenu(title: "One") {
						NSMenuItem(title: "fish") { _ in
							Swift.print("Pressed fish!")
						}
					}
				)

			AUIComboButton(title: "No Menu")
				.onAction { _ in
					Swift.print("[.split] No Menu selected")
				}

			AUIComboButton(title: "Disabled")
				.onAction { _ in
					Swift.print("[.split] Disabled selected")
				}
				.isEnabled(false)
		}

		HDivider()

		NSTextField(label: "Unified buttons")
			.font(.headline)

		HStack {
			AUIComboButton(title: "Has Menu", style: .unified)
				.onAction { _ in
					Swift.print("[.unified] Has Menu selected")
				}
				.menu(
					NSMenu(title: "One") {
						NSMenuItem(title: "Do something exciting") { _ in
							Swift.print("[.unified] Pressed 'Do something exciting'")
						}
						.image(NSImage(named: "NSQuickLookTemplate")!)
					}
				)

			AUIComboButton(title: "No Menu", style: .unified)
				.onAction { _ in
					Swift.print("[.unified] No Menu selected")
				}

			AUIComboButton(title: "Disabled", style: .unified)
				.onAction { _ in
					Swift.print("[.unified] Disabled selected??")
				}
				.isEnabled(false)
		}

		HDivider()

		HStack {
			NSTextField(label: "Control Sizes")
				.font(.headline)
			NSView.Spacer()
			NSButton.checkbox(title: "Enabled")
				.state(enabled)
				.controlSize(.small)
		}

		HStack {
			AUIComboButton(title: "Large")
				.image(_segmentImage)
				.controlSize(.large)
				.isEnabled(enabled)
				.onAction { _ in
					Swift.print("[large] menu selected")
				}
				.menu(
					NSMenu(title: "One") {
						NSMenuItem(title: "Do something exciting") { _ in
							Swift.print("[large] Pressed 'Do something exciting'")
						}
						.image(NSImage(named: "NSQuickLookTemplate")!)
					}
				)
			AUIComboButton(title: "Regular")
				.isEnabled(enabled)
				.controlSize(.regular)
				.image(_segmentImage)
				.onAction { _ in
					Swift.print("[regular] menu selected")
				}
				.menu(
					NSMenu(title: "One") {
						NSMenuItem(title: "Do something exciting") { _ in
							Swift.print("[regular] Pressed 'Do something exciting'")
						}
						.image(NSImage(named: "NSQuickLookTemplate")!)
					}
				)
			AUIComboButton(title: "Small")
				.isEnabled(enabled)
				.controlSize(.small)
				.font(.systemSmall)
				.image(_segmentImage)
				.onAction { _ in
					Swift.print("[small] menu selected")
				}
				.menu(
					NSMenu(title: "One") {
						NSMenuItem(title: "Do something exciting") { _ in
							Swift.print("[small] Pressed 'Do something exciting'")
						}
						.image(NSImage(named: "NSQuickLookTemplate")!)
					}
				)
			AUIComboButton(title: "Mini")
				.isEnabled(enabled)
				.controlSize(.mini)
				.image(_segmentImage)
				.font(.systemMini)
				.onAction { _ in
					Swift.print("[mini] menu selected")
				}
				.menu {
					NSMenuItem(title: "Always do something!")
						.onAction { _ in
							Swift.print("[mini] Pressed 'Always do something'")
						}

					NSMenuItem(title: "Do something exciting")
					.image(NSImage(named: "NSQuickLookTemplate")!)
					.onAction { _ in
					  Swift.print("[mini] Pressed 'Do something exciting'")
					}
					.onValidate { _ in true }

					NSMenuItem(title: "Dont do anything at all") { _ in
						Swift.print("[mini] Pressed 'Dont do anything at all'")
					}
					.image(NSImage(named: "NSFollowLinkFreestandingTemplate")!)
					.onValidate { _ in false }
				}
		}

		HDivider()

		HStack {
			AUIComboButton(title: "Check Enabling Menu Items")
				.onAction { _ in
					Swift.print("[mini] menu selected")
				}
				.menu {
					NSMenuItem(title: "First one (toggles third)")
						.onAction { _ in
							Swift.print("[enabletest] Pressed 'First one'")
							menuItemEnabled.toggle()
						}
					NSMenuItem(title: "Second one (disabled)")
						.onAction { _ in
							Swift.print("[enabletest] Pressed 'First one'")
						}
						.onValidate { _ in false }

					NSMenuItem(title: "Third one")
						.onAction { _ in
							Swift.print("[enabletest] Pressed 'Third one'")
						}
						.isEnabled(menuItemEnabled)
				}

			NSView.Spacer()

			NSButton.checkbox(title: "Enable third item")
				.state(menuItemEnabled)
		}

	}
	.alignment(.leading)
}

#endif

