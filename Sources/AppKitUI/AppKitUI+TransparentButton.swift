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

/// A transparent button
///
/// This button draws nothing, but allows the caller to specify a focus ring to allow tabbing for keyboard navigation
///
/// This button has NO intrinsic size. You need to either specify the size yourself or rely on autolayout to
/// automatically size the control
@MainActor
public class AUITransparentButton: NSButton {
	/// Create a transparent button
	public init() {
		super.init(frame: .zero)
		self.setup()
	}
	
	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.setup()
	}

	/// Set the block that returns the focus ring for the button
	/// - Parameter block: The block
	/// - Returns: self
	@discardableResult
	public func focusRingBounds(_ block: @escaping (NSRect) -> NSBezierPath) -> Self {
		self.focusBoundsFn = block
		return self
	}

	// Private

	private func setup() {
		self.isBordered = false
		self.image = NSImage()
		self.imagePosition = .imageOnly
	}

	public override func drawFocusRingMask() {
		self.focusBoundsFn(self.bounds).fill()
	}

	public override func draw(_ dirtyRect: NSRect) {
		// Do nothing
	}

	private var focusBoundsFn: (NSRect) -> NSBezierPath = { NSBezierPath(rect: $0) }
}
