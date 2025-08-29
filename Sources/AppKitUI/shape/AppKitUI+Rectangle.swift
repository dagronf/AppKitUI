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

/// A view that displays a rectangle
@MainActor
public class Rectangle: AUIShape {
	/// The corner radius for the rectangle
	public var cornerRadius: Double = 0 {
		didSet {
			self.rebuild()
		}
	}

	/// Set the corner radius
	/// - Parameter value: The corner radius
	/// - Returns: self
	@discardableResult @inlinable
	public func cornerRadius(_ value: Double) -> Self {
		self.cornerRadius = value
		return self
	}

	/// Create a rectangle with an optional corner radius
	/// - Parameter cornerRadius: The corner radius
	public init(cornerRadius: Double = 0) {
		super.init()
		self.cornerRadius = cornerRadius
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		os_log("deinit: AUIShape.Rectangle", log: logger, type: .debug)
	}

	public override func shape(bounds: CGRect) -> CGPath {
		let inset = self.strokeLineWidth / 2
		let destination = bounds.insetBy(dx: inset, dy: inset)

		// We need to perform this check for macOS 10.13
		let c = max(0, min(destination.height / 2.0, self.cornerRadius))

		return CGPath(roundedRect: destination, cornerWidth: c, cornerHeight: c, transform: nil)
	}
}

// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("Basic") {
	HStack {
		Rectangle()
			.fill(color: .systemRed)
			.frame(width: 50, height: 50)
		Rectangle()
			.fill(color: .systemOrange)
			.frame(width: 150, height: 50)
	}
}

#endif
