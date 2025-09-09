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

import AppKit.NSButton
import os.log

@MainActor
public extension NSButton {
	/// Create a button with a button type and a style
	/// - Parameters:
	///   - title: The title for the button
	///   - type: The type of button
	///   - style: The bezel style for the button
	///   - onAction: A block to call when the button action occurs
	convenience init(
		title: String? = nil,
		type: NSButton.ButtonType = .momentaryLight,
		style: NSButton.BezelStyle = .push,
		onAction: ((NSControl.StateValue) -> Void)? = nil
	) {
		self.init()
		self.translatesAutoresizingMaskIntoConstraints = false
		self.setButtonType(type)
		self.bezelStyle = style
		if let title {
			self.title = title
		}
		if let onAction {
			self.usingButtonStorage { $0.action = onAction }
		}
	}

	/// Create a button containing only an image
	/// - Parameters:
	///   - image: The image to display
	///   - imageScaling: The scaling to apply
	///   - onAction: A block to call when the button action occurs
	/// - Returns: A new NSButton containing an image only
	static func image(
		_ image: NSImage,
		imageScaling: NSImageScaling = .scaleProportionallyDown,
		onAction: ((NSControl.StateValue) -> Void)? = nil
	) -> NSButton {
		let button = NSButton()
			.isBordered(false)
			.image(image)
			.imagePosition(.imageOnly)
			.imageScaling(imageScaling)
		if let onAction {
			button.usingButtonStorage { $0.action = onAction }
		}
		return button
	}
}

// MARK: - Modifiers

@MainActor
public extension NSButton {
	/// The title of the control.
	@objc @discardableResult
	func title(_ title: String) -> Self {
		self.title = title
		return self
	}

	/// The title that the button displays when the button is in an on state.
	///
	/// [alternateTitle](https://developer.apple.com/documentation/appkit/nsbutton/alternatetitle)
	@discardableResult @inlinable
	func alternateTitle(_ alternateTitle: String) -> Self {
		self.alternateTitle = alternateTitle
		return self
	}

	/// The attributed title of the control.
	///
	/// [attributedTitle](https://developer.apple.com/documentation/appkit/nsbuttoncell/attributedtitle)
	@discardableResult @inlinable
	func attributedTitle(_ title: NSAttributedString) -> Self {
		self.attributedTitle = title
		return self
	}

	/// Sets the button’s type, which affects its user interface and behavior when clicked
	/// - Parameter buttonType: The button type
	/// - Returns: self
	@discardableResult @inlinable
	func buttonType(_ buttonType: NSButton.ButtonType) -> Self {
		self.setButtonType(buttonType)
		return self
	}

	/// The appearance of the button’s border
	/// - Parameter style: The border style
	/// - Returns: self
	@discardableResult @inlinable
	func bezelStyle(_ style: NSButton.BezelStyle) -> Self {
		self.bezelStyle = style
		return self
	}

	/// The color of the button’s bezel, in appearances that support it.
	/// - Parameter color: The bezel color
	/// - Returns: self
	@discardableResult @inlinable
	func bezelColor(_ color: NSColor?) -> Self {
		self.bezelColor = color
		return self
	}

	/// A Boolean value that determines whether the button has a border.
	/// - Parameter isBordered: Does the button have a border?
	/// - Returns: self
	@discardableResult @inlinable
	func isBordered(_ isBordered: Bool) -> Self {
		self.isBordered = isBordered
		return self
	}

	/// A Boolean value that indicates whether the button is transparent.
	/// - Parameter isTransparent: Is the control transparent?
	/// - Returns: self
	@discardableResult @inlinable
	func isTransparent(_ isTransparent: Bool) -> Self {
		self.isTransparent = isTransparent
		return self
	}

	/// Set the button's state
	/// - Parameter state: A constant that indicates whether a control is on, off, or in a mixed state.
	/// - Returns: self
	@discardableResult @inlinable
	func state(_ state: NSControl.StateValue) -> Self {
		self.state = state
		return self
	}

	/// A Boolean value that indicates whether the button allows a mixed state.
	/// - Parameter allowsMixedState: True if the button supports mixed state
	/// - Returns: self
	@discardableResult @inlinable
	func allowsMixedState(_ allowsMixedState: Bool) -> Self {
		self.allowsMixedState = allowsMixedState
		return self
	}

	/// A Boolean value that defines whether a button’s action has a destructive effect.
	/// - Parameter hasDestructiveAction: If true, marks the button as having a destructive action
	/// - Returns: self
	@available(macOS 11.0, *)
	@discardableResult @inlinable
	func hasDestructiveAction(_ hasDestructiveAction: Bool) -> Self {
		self.hasDestructiveAction = hasDestructiveAction
		return self
	}

	/// Set the key equivalent for the button
	/// - Parameters:
	///   - keyEquivalent: The key equivalent
	///   - modifiers: The modifiers applied to the key equivalent
	/// - Returns: self
	///
	/// [Key Equivalient](https://developer.apple.com/documentation/appkit/nsbutton/keyequivalent)
	///
	/// [Key Equivalent Modifier Mask](https://developer.apple.com/documentation/appkit/nsbutton/keyequivalentmodifiermask)
	@discardableResult @inlinable
	func keyEquivalent(_ keyEquivalent: String, modifiers: NSEvent.ModifierFlags? = nil) -> Self {
		self.keyEquivalent = keyEquivalent
		if let modifiers {
			self.keyEquivalentModifierMask = modifiers
		}
		return self
	}

	/// Set this button as the default button
	/// - Parameter value: The default status for the button
	/// - Returns: self
	@discardableResult @inlinable
	func isDefaultButton(_ value: Bool) -> Self {
		self.keyEquivalent = "\r"
		return self
	}

	/// Display the button border only when the mouse is hovering over it and the button is active
	/// - Parameter value: If true, only shows the border when the mouse is hovering over it
	/// - Returns: self
	///
	/// [showsBorderOnlyWhileMouseInside](https://developer.apple.com/documentation/appkit/nsbutton/showsborderonlywhilemouseinside)
	@discardableResult @inlinable
	func showsBorderOnlyWhileMouseInside(_ value: Bool) -> Self {
		self.showsBorderOnlyWhileMouseInside = value
		return self
	}

	/// The sound that plays when the user clicks the button
	/// - Parameter value: The sound, or nil for no sound
	/// - Returns: self
	///
	/// [sound](https://developer.apple.com/documentation/appkit/nsbutton/sound)
	@discardableResult @inlinable
	func sound(_ value: NSSound?) -> Self {
		self.sound = value
		return self
	}

	/// A tint color to use for the template image and text content.
	/// - Parameter value: The color
	/// - Returns: self
	///
	/// Does nothing on macOS 10.13 and earlier
	///
	/// [`contentTintColor` discussion](https://developer.apple.com/documentation/appkit/nsbutton/contenttintcolor)
	@discardableResult @inlinable
	func contentTintColor(_ value: NSColor) -> Self {
		if #available(macOS 10.14, *) {
			self.contentTintColor = value
		}
		return self
	}

	/// If true, the checkbox is shown as the check only, no title
	@discardableResult @inlinable
	func hidesTitle(_ hide: Bool) -> Self {
		self.imagePosition = hide ? .imageOnly : .imageLeading
		return self
	}
}

//@MainActor
//@available(macOS 26, *)
//public extension NSButton {
//	/// Set the tint prominence for the button (macOS 26+)
//	/// - Parameter prominence: The prominence
//	/// - Returns: self
//	///
//	/// [tintProminence](https://developer.apple.com/documentation/appkit/nsbutton/tintprominence)
//	@available(macOS 26.0, *)
//	@discardableResult @inlinable
//	func tintProminence(_ prominence: NSTintProminence) -> Self {
//		self.tintProminence = prominence
//		return self
//	}
//}

// MARK: - Image

@MainActor
public extension NSButton {
	/// The image that appears on the button when it’s in an off state, or nil if there is no such image.
	/// - Parameter image: The image
	/// - Returns: self
	@discardableResult @inlinable
	func image(_ image: NSImage?) -> Self {
		self.image = image
		return self
	}

	/// An alternate image that appears on the button when the button is in an on state.
	/// - Parameter alternateImage: The image
	/// - Returns: self
	@discardableResult @inlinable
	func alternateImage(_ alternateImage: NSImage?) -> Self {
		self.alternateImage = alternateImage
		return self
	}

	/// The position of the button’s image relative to its title.
	/// - Parameter position: The image position
	/// - Returns: self
	@discardableResult @inlinable
	func imagePosition(_ position: NSControl.ImagePosition) -> Self {
		self.imagePosition = position
		return self
	}

	/// A Boolean value that determines how the button’s image and title are positioned together within the button bezel.
	/// - Parameter imageHugsTitle: The state determining
	/// - Returns: self
	///
	/// [https://developer.apple.com/documentation/appkit/nsbutton/imagehugstitle](https://developer.apple.com/documentation/appkit/nsbutton/imagehugstitle)
	@discardableResult @inlinable
	func imageHugsTitle(_ imageHugsTitle: Bool) -> Self {
		self.imageHugsTitle = imageHugsTitle
		return self
	}

	/// The scaling mode applied to make the cell’s image fit the frame of the image view.
	/// - Parameter imageScaling: The scaling
	/// - Returns: self
	@discardableResult @inlinable
	func imageScaling(_ imageScaling: NSImageScaling) -> Self {
		self.imageScaling = imageScaling
		return self
	}

	/// Set the menu for the popup button
	/// - Parameter menu: The menu
	/// - Returns: self
	@discardableResult @inlinable
	func menu(_ menu: NSMenu) -> Self {
		self.menu = menu
		return self
	}

	/// Set the menu for the popup button
	/// - Parameters:
	///   - title: The menu title
	///   - builder: The block returning `NSMenuItem`s for the menu
	/// - Returns: self
	@discardableResult
	func menu(title: String = "", @NSMenuItemsBuilder builder: () -> [NSMenuItem]) -> Self {
		self.menu = NSMenu(title: title, builder: builder)
		return self
	}
}

// MARK: - Bindings

@MainActor
public extension NSButton {
	/// Bind the button title
	/// - Parameter title: The button title
	/// - Returns: self
	@discardableResult
	func title(_ title: Bind<String>) -> Self {
		title.register(self) { @MainActor [weak self] newValue in
			self?.title = newValue
		}
		self.title = title.wrappedValue
		return self
	}

	/// Bind the control state
	/// - Parameter state: The state binder
	/// - Returns: self
	@discardableResult
	func state(_ state: Bind<NSControl.StateValue>) -> Self {
		state.register(self) { @MainActor [weak self] newValue in
			self?.state = newValue
		}

		self.usingButtonStorage { $0.state = state }

		self.state = state.wrappedValue
		return self
	}

	/// Bind the control state
	/// - Parameter state: The state binder
	/// - Returns: self
	@discardableResult
	func state(_ state: Bind<Bool>) -> Self {
		state.register(self) { @MainActor [weak self] newValue in
			self?.state = newValue ? .on : .off
		}
		self.state = state.wrappedValue ? NSControl.StateValue.on : NSControl.StateValue.off
		self.usingButtonStorage { $0.onOffState = state }
		return self
	}

	/// Bind the button image
	/// - Parameter image: The image binder
	/// - Returns: self
	@discardableResult
	func image(_ image: Bind<NSImage?>) -> Self {
		image.register(self) { @MainActor [weak self] newValue in
			self?.image = newValue
		}
		self.image = image.wrappedValue
		return self
	}
}

// MARK: - Actions

@MainActor
public extension NSButton {
	/// Called when the user interacts with the button
	/// - Parameter block: The block to call
	/// - Returns: self
	///
	/// NOTE: This action is _not_ called if the state is changed programatically
	@discardableResult
	func onAction(_ block: @escaping (NSControl.StateValue) -> Void) -> Self {
		self.usingButtonStorage { storage in
			storage.action = block
		}
		return self
	}

	/// Display a menu when the user clicks the button
	/// - Parameter menu: The menu
	/// - Returns: self
	func onActionMenu(_ menu: NSMenu) -> Self {
		self.onAction { @MainActor [weak self] _ in
			guard let `self` = self else { return }
			let menuLocation = NSPoint(x: self.bounds.minX, y: self.bounds.maxY)
			menu.popUp(positioning: nil, at: menuLocation, in: self)
		}
		return self
	}

	/// Called when the user interacts with the button
	/// - Parameters:
	///   - target: The target for the action
	///   - action: The selector to call when the action is performed
	/// - Returns: self
	///
	/// NOTE: This action is _not_ called if the state is changed programatically
	@discardableResult
	func onAction(target: AnyObject, action: Selector) -> Self {
		let action = AUITargetAction(target: target, action: action, from: self)
		self.usingButtonStorage { $0.actionSelector = action }
		return self
	}
}

// MARK: - Private

@MainActor
internal extension NSButton {
	@MainActor
	class Storage {
		var onOffState: Bind<Bool>?
		var state: Bind<NSControl.StateValue>?
		var action: ((NSControl.StateValue) -> Void)?
		var actionSelector: AUITargetAction?
		var menu: NSMenu?

		init(_ parent: NSButton) {
			parent.target = self
			parent.action = #selector(actionCalled(_:))
		}

		deinit {
			os_log("deinit: NSButton.Storage", log: logger, type: .debug)
		}

		@MainActor
		@objc private func actionCalled(_ sender: NSButton) {
			self.state?.wrappedValue = sender.state
			self.onOffState?.wrappedValue = sender.state == .on
			self.action?(sender.state)

			// Call the control action if it exists
			self.actionSelector?.perform()

			if let menu, let event = NSApplication.shared.currentEvent {
				NSMenu.popUpContextMenu(menu, with: event, for: sender)
			}
		}
	}

	@MainActor
	func usingButtonStorage(_ block: @escaping (Storage) -> Void) {
		self.usingAssociatedValue(key: "__nsbutton_bond", initialValue: { Storage(self) }, block)
	}
}

// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("default") {
	ScrollView(borderType: .noBorder, fitHorizontally: true) {
		VStack {
			HStack {
				NSButton(title: "default")
				NSButton(title: "default")
					.bezelColor(.systemGreen)
				NSButton(title: "default")
					.keyEquivalent("\r")
			}
			.padding(2)

			HStack {
				NSButton(title: "default")
					.image(NSImage(named: NSImage.quickLookTemplateName)!.isTemplate(true))
					.contentTintColor(.systemRed)
				NSButton(title: "default")
					.contentTintColor(.systemRed)
				NSButton.image(
					NSImage(named: NSImage.quickLookTemplateName)!.isTemplate(true),
					imageScaling: .scaleProportionallyDown
				) { _ in
					Swift.print("clicked image")
				}
				.frame(width: 24, height: 24)

				NSButton()
					.title("􀍠")
					.bezelStyle(.circular)
					.onActionMenu(
						NSMenu {
							NSMenuItem(title: "first") { _ in Swift.print("first") }
							NSMenuItem(title: "second") { _ in Swift.print("second") }
							NSMenuItem(title: "third") { _ in Swift.print("third") }
						}
					)
					.accessibilityTitle("More options 1")
					.accessibilityLabel("More options 2")
			}
			.padding(2)

			HDivider()

			HStack {
				NSButton(title: "accessoryBar")
					.bezelStyle(.accessoryBar)
				NSButton(title: "badge")
					.bezelStyle(.badge)
				NSButton(title: "toolbar")
					.bezelStyle(.toolbar)
			}
			.padding(2)

			HDivider()

			HStack {
				NSButton(title: "flexiblepush\nflexiblepush")
					.bezelStyle(.flexiblePush)
				NSButton(title: "smallSquare\nsmallSquare")
					.bezelStyle(.smallSquare)
				NSButton(title: "texturedSquare\ntexturedSquare")
					.bezelStyle(.texturedSquare)
			}
			.padding(2)

			HDivider()

			HStack {
				NSButton(title: "circular")
					.bezelStyle(.circular)
				NSButton(title: "", type: .onOff)
					.bezelStyle(.disclosure)
				NSButton(title: "", type: .onOff)
					.bezelStyle(.pushDisclosure)
			}
			.padding(2)

			HDivider()

			VStack(alignment: .leading) {
				NSButton.checkbox(title: "This is a checkbox")
				HStack(spacing: 12) {
					NSButton.checkbox(title: "This title is hidden")
						.hidesTitle(true)
						.onAction { _ in
							Swift.print("Clicked the checkbox with the hidden title")
						}
					NSTextField(label: "←")
					NSTextField(label: "This checkbox has hidden its title")
				}
			}

			HDivider()
			NSButton.radioGroup()
				.items(["one", "two", "three"])
			NSButton.radioGroup(orientation: .horizontal)
				.items(["eight", "nine", "ten"])
		}
	}
}

#endif

