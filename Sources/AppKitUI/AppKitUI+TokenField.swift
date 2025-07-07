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

/// A custom NSTokenField class that automatically expands vertically to fit the (wrapped) content
@MainActor
public class AUITokenField: NSTokenField {
	public override var intrinsicContentSize: NSSize {
		 // Guard the cell exists and wraps
		 guard let cell = self.cell, cell.wraps else {
			 return super.intrinsicContentSize
		 }

		 // Use intrinsic width (to support autolayout)
		 let width = super.intrinsicContentSize.width

		 // Set the frame height to huge
		 self.frame.size.height = 750.0

		 // Calcuate height
		 let height = cell.cellSize(forBounds: self.frame).height

		 return NSMakeSize(width, height)
	}
}
