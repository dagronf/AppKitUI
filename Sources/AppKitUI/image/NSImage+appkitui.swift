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

import AppKit.NSImage

// MARK: - Modifiers

public extension NSImage {
	/// Set whether the image represents a template image
	/// - Parameter value: The template image state
	/// - Returns: self
	@discardableResult @inlinable
	func isTemplate(_ value: Bool) -> Self {
		self.isTemplate = value
		return self
	}

	/// Set the size
	/// - Parameters:
	///   - width: The image width
	///   - height: The image height
	/// - Returns: self
	@discardableResult @inlinable
	func size(width: Double, height: Double) -> Self {
		self.size = NSSize(width: width, height: height)
		return self
	}

	/// Set the image width and height
	/// - Parameter value: The new image size
	/// - Returns: self
	@discardableResult @inlinable
	func size(_ value: NSSize) -> Self {
		self.size = value
		return self
	}
}

// MARK: - Image loading conveniences

private let defaultMissingImage__ = NSImage(named: NSImage.cautionName)!

public extension NSImage {
	/// Create a new image containing a system symbol (macOS 11 and later)
	/// - Parameter systemSymbolName: The symbol name
	///
	/// If the symbol can't be found, returns nil
	@available(macOS 11.0, *)
	convenience init?(systemSymbolName: String) {
		self.init(systemSymbolName: systemSymbolName, accessibilityDescription: nil)
	}

	/// Create an image with a named image
	/// - Parameter name: The image name
	/// - Returns: An image.
	///
	/// If the symbol can't be found, returns the system symbol `NSImage.cautionName`
	static func named(_ name: String) -> NSImage {
		NSImage(named: name) ?? defaultMissingImage__
	}

	/// Create an image with a system symbol name (macOS 11.0+)
	/// - Parameters:
	///   - name: The system symbol name
	///   - accessibilityDescription: The accessibility description for the symbol image, if any.
	/// - Returns: An image.
	///
	/// If the symbol can't be found, returns the system symbol `NSImage.cautionName`
	@available(macOS 11.0, *)
	static func systemSymbol(_ name: String, accessibilityDescription: String? = nil) -> NSImage {
		NSImage(systemSymbolName: name, accessibilityDescription: accessibilityDescription) ?? defaultMissingImage__
	}
}

// MARK: - Accessibility

public extension NSImage {
	/// The image’s accessibility description.
	/// - Parameter name: The description
	/// - Returns: self
	@discardableResult @inlinable
	func accessibilityDescription(_ name: String) -> Self {
		self.accessibilityDescription = name
		return self
	}
}
