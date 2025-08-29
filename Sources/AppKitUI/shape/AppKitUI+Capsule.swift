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

/// A view that displays a capsule
@MainActor
public class Capsule: AUIShape {
	/// Draw a capsule shape
	/// - Parameter bounds: The bounds to draw the capsule
	/// - Returns: The capsule path
	public override func shape(bounds: CGRect) -> CGPath {
		let inset = self.strokeLineWidth / 2
		let destination = bounds.insetBy(dx: inset, dy: inset)
		let cr = min(destination.width / 2, destination.height / 2)
		return CGPath(roundedRect: destination, cornerWidth: cr, cornerHeight: cr, transform: nil)
	}

	deinit {
		os_log("deinit: AUIShape.Capsule", log: logger, type: .debug)
	}
}

// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("Basic") {
	HStack {
		Capsule()
			.fill(color: .systemRed)
			.frame(width: 50, height: 50)
		Capsule()
			.fill(color: .systemOrange)
			.frame(width: 150, height: 50)
		Capsule()
			.fill(color: .systemYellow)
			.frame(width: 50, height: 150)
	}
}

#endif
