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

// NSImage utilities

extension NSImage {
	/// Lock the image focus and perform a block
	@inlinable
	func withLockedFocus(_ block: () -> Void) {
		self.lockFocus()
		defer { self.unlockFocus() }
		block()
	}

	/// Lock the image focus and perform a block, passing in the core graphics context for the image
	func withLockedFocus(_ block: (CGContext) -> Void) {
		self.withLockedFocus {
			guard let ctx = NSGraphicsContext.current?.cgContext else { return }
			block(ctx)
		}
	}

	/// Get a tinted representation for this image
	/// - Parameter color: The color for tinting.  If nil, returns a copy of this image
	/// - Returns: A new image
	func tint(color: NSColor?) -> NSImage {
		// If a color is not specified, just return a copy of the image
		guard let color else {
			// No tinting
			return self.copy() as! NSImage
		}

		let tintedImage = NSImage(size: size)
		let bounds = NSRect(origin: .zero, size: size)

		tintedImage.withLockedFocus {
			// Fill with the tint color
			color.setFill()
			bounds.fill()

			// Draw the image as a mask, which will show the color through
			// the image's alpha channel
			self.draw(in: bounds, from: bounds, operation: .destinationIn, fraction: 1.0)
		}

		return tintedImage
	}
}
