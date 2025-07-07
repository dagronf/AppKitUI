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

// A convenience wrapper around a scrollable text view, with the ability to toggle word wrapping
open class ScrollableTextView: NSView {

	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		self.setup()
	}

	required public init?(coder: NSCoder) {
		super.init(coder: coder)
		self.setup()
	}

	public override func setFrameSize(_ newSize: NSSize) {
		super.setFrameSize(newSize)
		self.scrollView.frame = self.bounds
	}

	public let scrollView = NSScrollView()
	public let textView = NSTextView()
}

extension ScrollableTextView {
	private func setup() {
		self.wantsLayer = true

		textView.wantsLayer = true
		textView.autoresizingMask = [.width]

		scrollView.wantsLayer = true
		scrollView.documentView = textView
		scrollView.hasVerticalScroller = true

		self.addSubview(scrollView)
	}

	func wrapText(_ isWrapped: Bool) {
		self.scrollView.hasHorizontalScroller = !isWrapped
		self.textView.isHorizontallyResizable = !isWrapped

		self.scrollView.hasVerticalScroller = true

		let width = isWrapped ? scrollView.contentSize.width : CGFloat.greatestFiniteMagnitude
		self.textView.maxSize = NSSize(width: width, height: CGFloat.greatestFiniteMagnitude)

		self.textView.textContainer?.size = NSSize(width: width, height: CGFloat.greatestFiniteMagnitude)
		self.textView.textContainer?.widthTracksTextView = isWrapped

		if isWrapped {
			self.textView.autoresizingMask = [.width]
		}
		else {
			self.textView.autoresizingMask = [.width, .height]
		}

		if isWrapped {
			self.textView.setFrameSize(NSSize(width: width, height: scrollView.contentSize.height))
		}

		self.textView.invalidateTextContainerOrigin()
	}
}
