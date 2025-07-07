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

import AppKit.NSVisualEffectView

@MainActor
public extension NSVisualEffectView {

	// MARK: - Static creators

	/// Create a visual effect view set to light mode (.aqua) (macOS 10.14+)
	/// - Parameters:
	///   - layoutStyle: The layout for the view builder
	///   - content: block content builder
	/// - Returns: A visual effect view set to light mode (.aqua)
	@available(macOS 10.14, *)
	@discardableResult @inlinable
	static func lightMode(layoutStyle: LayoutStyle = .fill, content: () -> NSView) -> NSVisualEffectView {
		NSVisualEffectView(isDarkMode: false, layoutStyle: layoutStyle, content: content)
	}

	/// Create a visual effect view set to light mode (.aqua) (macOS 10.14+)
	/// - Parameters:
	///   - layoutStyle: The layout for the view builder
	///   - content: block content builder
	/// - Returns: A visual effect view set to light mode (.aqua)
	@available(macOS 10.14, *)
	@discardableResult @inlinable
	static func darkMode(layoutStyle: LayoutStyle = .fill, content: () -> NSView) -> NSVisualEffectView {
		NSVisualEffectView(isDarkMode: true, layoutStyle: layoutStyle, content: content)
	}

	// MARK: - Initializers

	/// Create a visual effect view defining whether the view is dark or light mode (10.14 or later)
	/// - Parameters:
	///   - isDarkMode: If true sets the view style to dark mode, otherwise light mode
	///   - layoutStyle: The layout for the view builder
	///   - content: block content builder
	@available(macOS 10.14, *)
	@discardableResult @inlinable
	convenience init(
		isDarkMode: Bool,
		layoutStyle: LayoutStyle = .fill,
		content: () -> NSView
	) {
		let appearance = isDarkMode ? NSAppearance(named: .darkAqua)! : NSAppearance(named: .aqua)!
		self.init(appearance: appearance, layoutStyle: layoutStyle, content: content)
	}

	/// Create using an appearance value
	/// - Parameters:
	///   - appearance: The appearance style
	///   - layoutStyle: The layout for the view builder
	///   - content: block content builder
	convenience init(
		appearance: NSAppearance,
		layoutStyle: LayoutStyle = .fill,
		content: () -> NSView
	) {
		self.init()
		self
			.appearance(appearance)
			.content(layoutStyle: layoutStyle, content: content())
	}

	/// Create a visual effect view
	/// - Parameters:
	///   - layoutStyle: The layout for the view builder
	///   - material: Constants to specify the material shown by the visual effect view.
	///   - blendingMode: Constants that specify whether the visual effect view blends with what’s either behind or within the window.
	///   - isEmphasized: If true, emphasizes the material style
	///   - content: The child builder
	convenience init(
		layoutStyle: LayoutStyle = .fill,
		material: NSVisualEffectView.Material? = nil,
		blendingMode: NSVisualEffectView.BlendingMode? = nil,
		isEmphasized: Bool? = nil,
		content: () -> NSView
	) {
		self.init()
		self.content(layoutStyle: layoutStyle, content: content())

		self.translatesAutoresizingMaskIntoConstraints = false

		if let material { self.material = material }
		if let blendingMode { self.blendingMode = blendingMode }
		if let isEmphasized { self.isEmphasized = isEmphasized }
	}
}

// MARK: - Modifiers

@MainActor
public extension NSVisualEffectView {
	/// Set the appearance for the view
	/// - Parameter appearance: The appearance
	/// - Returns: self
	///
	/// [appearance documentation](https://developer.apple.com/documentation/appkit/nsappearancecustomization/appearance)
	@discardableResult @inlinable
	func appearance(_ appearance: NSAppearance?) -> Self {
		self.appearance = appearance
		return self
	}

	/// Set the material for the effect view
	/// - Parameter material: The material
	/// - Returns: self
	///
	/// [material documentation](https://developer.apple.com/documentation/appkit/nsvisualeffectview/material-swift.property)
	@discardableResult @inlinable
	func material(_ material: NSVisualEffectView.Material) -> Self {
		self.material = material
		return self
	}

	/// Set the blend mode for the effect view
	/// - Parameter blendingMode: The blend mode
	/// - Returns: self
	///
	/// [blendMode documentation](https://developer.apple.com/documentation/appkit/nsvisualeffectview/blendingmode-swift.property)
	@discardableResult @inlinable
	func blendingMode(_ blendingMode: NSVisualEffectView.BlendingMode) -> Self {
		self.blendingMode = blendingMode
		return self
	}

	/// Set whether to emphasize the look of the material
	/// - Parameter isEmphasized: If the look is emphasized
	/// - Returns: self
	///
	/// Some materials change their appearance when they are emphasized. For example, the first responder view conveys its status.
	///
	/// [isEmphasized documentation](https://developer.apple.com/documentation/appkit/nsvisualeffectview/isemphasized)
	@discardableResult @inlinable
	func isEmphasized(_ isEmphasized: Bool) -> Self {
		self.isEmphasized = isEmphasized
		return self
	}

	/// An image whose alpha channel masks the visual effect view’s material.
	/// - Parameter maskImage: The mask image
	/// - Returns: self
	///
	/// [maskimage documentation](https://developer.apple.com/documentation/appkit/nsvisualeffectview/maskimage)
	@discardableResult @inlinable
	func maskImage(_ maskImage: NSImage?) -> Self {
		self.maskImage = maskImage
		return self
	}
}

// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("default") {
	VStack {
		HStack {
			NSVisualEffectView.lightMode {
				NSTextField(labelWithString: "Aqua style (light mode)")
					.padding()
			}
			.debugFrame()

			NSVisualEffectView.darkMode {
				NSTextField(labelWithString: "Dark Aqua style (dark mode)")
					.padding()
			}
			.debugFrame()
		}

		HStack {
			NSVisualEffectView(material: .popover) {
				NSTextField(labelWithString: "Material = .popover")
					.padding()
			}
			.debugFrame()

			NSVisualEffectView(material: .sheet) {
				NSTextField(labelWithString: "Material = .sheet")
					.padding()
			}
			.debugFrame()
		}
	}
}
#endif
