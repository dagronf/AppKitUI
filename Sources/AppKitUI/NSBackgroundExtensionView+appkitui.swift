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

#if canImport(AppKit.NSBackgroundExtensionView)

/// Is `NSBackgroundExtensionView` available?
public let AppKitUI_supportsNSBackgroundExtensionView: Bool = true

import AppKit

@available(macOS 26.0, *)
@MainActor
public extension NSBackgroundExtensionView {
	/// Create a background extension view
	/// - Parameters:
	///   - automaticallyPlacesContentView: Controls the automatic safe area placement of the contentView within the container
	///   - viewBuilder: The content for the background extension view
	convenience init(automaticallyPlacesContentView: Bool = true, _ viewBuilder: () -> NSView) {
		self.init()
		self.contentView = viewBuilder()
		self.automaticallyPlacesContentView = automaticallyPlacesContentView
	}
}

// MARK: - Modifiers

@available(macOS 26.0, *)
@MainActor
public extension NSBackgroundExtensionView {
	/// Controls the automatic safe area placement of the contentView within the container
	/// - Parameter value: safe area placement state
	/// - Returns: self
	///
	/// When NO, the frame of the content view must be explicitly set or constraints added.
	/// The extension effect will be used to fill the container view around the content.
	@discardableResult @inlinable
	func automaticallyPlacesContentView(_ value: Bool) -> Self {
		self.automaticallyPlacesContentView = value
		return self
	}
}

#else

/// Is `NSBackgroundExtensionView` available?
public let AppKitUI_supportsNSBackgroundExtensionView: Bool = false

#endif
