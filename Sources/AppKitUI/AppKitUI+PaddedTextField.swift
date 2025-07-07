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
import Foundation

// A textfield with configurable edge insets
@MainActor
public class AUIInsetTextField: NSTextField {

	@discardableResult
	public override func padding(top: Double = 0, left: Double = 0, bottom: Double = 0, right: Double = 0) -> AUIInsetTextField {
		self.edgeInsets_ = NSEdgeInsets(top: top, left: left, bottom: bottom, right: right)
		return self
	}

	/// The edge insets to apply to the field
	var edgeInsets_ = NSEdgeInsets() {
		didSet {
			if let cell = self.cell as? InsetTextFieldCell {
				cell.edgeInsets = self.edgeInsets_
				self.needsLayout = true
				self.invalidateIntrinsicContentSize()
			}
		}
	}

	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.customCell.edgeInsets = self.edgeInsets_
	}

	class public override var cellClass: AnyClass? {
		get { InsetTextFieldCell.self }
		set {}
	}

	private var customCell: InsetTextFieldCell { self.cell as! InsetTextFieldCell }
}

// MARK: - Padded cell

@MainActor
extension AUIInsetTextField {
	@objc(InsetTextFieldCell) public class InsetTextFieldCell: NSTextFieldCell {
		public var edgeInsets = NSEdgeInsets()

		public override func cellSize(forBounds rect: NSRect) -> NSSize {
			var size = super.cellSize(forBounds: rect)
			size.width += (edgeInsets.left + edgeInsets.right)
			size.height += (edgeInsets.top + edgeInsets.bottom)
			return size
		}

		public override func drawingRect(forBounds rect: NSRect) -> NSRect {
			var newRect = rect

			// If we are right-to-left, then the horizontal insets are swapped
			newRect.origin.x += (self.userInterfaceLayoutDirection == .leftToRight) ? edgeInsets.left : edgeInsets.right
			newRect.origin.y += edgeInsets.top
			newRect.size.width -= (edgeInsets.left + edgeInsets.right)
			newRect.size.height -= (edgeInsets.top + edgeInsets.bottom)
			return super.drawingRect(forBounds: newRect)
		}
	}
}


//// MARK: - Secure field
//
//// A secure text field with configurable edge insets
//@MainActor
//class PaddableSecureTextField: NSSecureTextField {
//
//	@IBInspectable var topInset: CGFloat = 0 {
//		didSet { self.edgeInsets.top = self.topInset }
//	}
//	@IBInspectable var leadingInset: CGFloat = 0 {
//		didSet { self.edgeInsets.left = self.leadingInset }
//	}
//	@IBInspectable var bottomInset: CGFloat = 0 {
//		didSet { self.edgeInsets.bottom = self.bottomInset }
//	}
//	@IBInspectable var trailingInset: CGFloat = 0 {
//		didSet { self.edgeInsets.right = self.trailingInset }
//	}
//
//	/// The edge insets to apply to the field
//	@objc var edgeInsets = NSEdgeInsets() {
//		didSet {
//			if let cell = self.cell as? PaddableSecureTextFieldCell {
//				cell.edgeInsets = edgeInsets
//				self.needsLayout = true
//				self.invalidateIntrinsicContentSize()
//			}
//		}
//	}
//
//	override init(frame frameRect: NSRect) {
//		super.init(frame: frameRect)
//	}
//
//	required init?(coder: NSCoder) {
//		super.init(coder: coder)
//		self.customCell.edgeInsets = self.edgeInsets
//	}
//
//	class override var cellClass: AnyClass? {
//		get { PaddableSecureTextFieldCell.self }
//		set {}
//	}
//
//	private var customCell: PaddableSecureTextFieldCell { self.cell as! PaddableSecureTextFieldCell }
//}
//
//// MARK: - Padded cell
//
//extension PaddableSecureTextField {
//	@objc(PaddableSecureTextFieldCell) public class PaddableSecureTextFieldCell: NSSecureTextFieldCell {
//		public var edgeInsets = NSEdgeInsets()
//
//		override func cellSize(forBounds rect: NSRect) -> NSSize {
//			var size = super.cellSize(forBounds: rect)
//			size.width += (edgeInsets.left + edgeInsets.right)
//			size.height += (edgeInsets.top + edgeInsets.bottom)
//			return size
//		}
//
//		override func drawingRect(forBounds rect: NSRect) -> NSRect {
//			var newRect = rect
//
//			// If we are right-to-left, then the horizontal insets are swapped
//			newRect.origin.x += (self.userInterfaceLayoutDirection == .leftToRight) ? edgeInsets.left : edgeInsets.right
//			newRect.origin.y += edgeInsets.top
//			newRect.size.width -= (edgeInsets.left + edgeInsets.right)
//			newRect.size.height -= (edgeInsets.top + edgeInsets.bottom)
//			return super.drawingRect(forBounds: newRect)
//		}
//	}
//}
//
