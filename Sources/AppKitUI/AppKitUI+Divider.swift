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

import AppKit.NSBox

@MainActor
public class HDivider: NSBox {
	public init() {
		super.init(frame: NSRect(x: 0, y: 0, width: 50, height: 1))
		self.translatesAutoresizingMaskIntoConstraints = false
		self.boxType = .separator
		self.titlePosition = .noTitle
		self.contentView = nil
		self.setContentHuggingPriority(.defaultLow, for: .horizontal)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

@MainActor
public class VDivider: NSBox {
	public init() {
		super.init(frame: NSRect(x: 0, y: 0, width: 1, height: 50))
		self.translatesAutoresizingMaskIntoConstraints = false
		self.boxType = .separator
		self.titlePosition = .noTitle
		self.contentView = nil
		self.setContentHuggingPriority(.defaultLow, for: .vertical)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}








//class Divider: NSView {
//	override init(frame frameRect: NSRect) {
//		super.init(frame: frameRect)
//		self.setup()
//	}
//	required init?(coder: NSCoder) {
//		fatalError()
//	}
//
//	func setup() {
//
//	}
//
//	override var intrinsicContentSize: NSSize {
//		guard let s = self.superview as? NSStackView else { return NSSize(width: -1, height: -1) }
//
//		if s.orientation == .horizontal {
//			return NSSize(width: 4, height: -1)
//		}
//		else {
//			return NSSize(width: -1, height: 4)
//		}
//	}
//
//	override func draw(_ dirtyRect: NSRect) {
//		let bounds = self.bounds
//		guard let s = self.superview as? NSStackView else { return }
//		NSColor.separatorColor.setStroke()
//		let pth = NSBezierPath()
//		pth.lineWidth = 1
//
//		if bounds.width > bounds.height {
//			pth.move(to: NSPoint(x: bounds.minX, y: bounds.midY))
//			pth.line(to: NSPoint(x: bounds.maxX, y: bounds.midY))
//			pth.stroke()
//		}
//		else {
//			pth.move(to: NSPoint(x: bounds.midX, y: bounds.minY))
//			pth.line(to: NSPoint(x: bounds.midX, y: bounds.maxY))
//			pth.stroke()
//		}
//	}
//
////	open override func viewDidMoveToSuperview() {
////		super.viewDidMoveToSuperview()
////		if let s = self.superview as? NSStackView {
////			if s.orientation == .vertical {
////				isHorizontal = true
////			}
////			else {
////				isHorizontal = true
////			}
////		}
////	}
//}
