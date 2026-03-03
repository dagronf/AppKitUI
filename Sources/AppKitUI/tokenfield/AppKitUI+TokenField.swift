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

// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("default") {
	let tokenField = Bind<[String]>(["red", "green", "blue", "cyan", "magenta", "yellow", "mint", "orange", "brown", "white", "black"])
	let tokenField3 = Bind<[String]>(["Australia", "Isle of Man", "Wallis & Futuna"])

	VStack {
		NSBox(title: "Single line, no wrapping") {
			VStack {
				NSTokenField(content: tokenField3)
					.isScrollable(true)
					.frame(width: 400)
				HStack(alignment: .top) {
					NSTextField(label: "Tokens:")
						.font(.system.bold)
					NSTextField(label: tokenField3.stringValue())
						.huggingPriority(.init(1), for: .horizontal)
						.compressionResistancePriority(.defaultLow, for: .horizontal)
				}
			}
		}

		NSBox(title: "Expand vertically to fit") {
			VStack {
				AUITokenField(content: tokenField)
					.wraps(true)
					.lineBreakMode(.byWordWrapping)
					.truncatesLastVisibleLine(false)
					.huggingPriority(.init(1), for: .horizontal)
					.compressionResistancePriority(.defaultLow, for: .horizontal)
					.frame(width: 400)
				HStack(alignment: .top) {
					NSTextField(label: "Tokens:")
						.font(.system.bold)
					NSTextField(label: tokenField.stringValue())
						.huggingPriority(.init(1), for: .horizontal)
						.compressionResistancePriority(.defaultLow, for: .horizontal)
				}

			}
		}
	}
	.padding()

	.onChange(tokenField) { newValue in
		Swift.print("tokenField -> \(newValue)")
	}
	.onChange(tokenField3) { newValue in
		Swift.print("tokenField3 -> \(newValue)")
	}
}

#endif
