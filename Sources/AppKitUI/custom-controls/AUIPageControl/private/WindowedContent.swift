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

import Foundation

@MainActor
class WindowedContent {
	
	enum State {
		case none
		case small
		case medium
		case large
	}
	
	func state(for page: Int) -> State {
		if self.window.contains(page) == false {
			return .none
		}
		else if self.pageCount <= 4 {
			return .large
		}
		else if self.window.inset(2).contains(page) {
			return .large
		}
		
		else if page == self.firstVisiblePage {
			if self.windowIsAtLeftEdge {
				return .large
			}
			else {
				return .small
			}
		}
		else if page == self.firstVisiblePage + 1 {
			if self.windowIsAtLeftEdge {
				return .large
			}
			else {
				return .medium
			}
		}
		
		else if page == self.lastVisiblePage {
			if self.windowIsAtRightEdge {
				return .large
			}
			else {
				return .small
			}
		}
		else if page == self.lastVisiblePage - 1 {
			if self.windowIsAtRightEdge {
				return .large
			}
			else {
				return .medium
			}
		}
		return .large
	}
	
	let windowSize: Int
	let pageCount: Int

	let validPages: Range<Int>

	func printCurrentState() {
		var result = ""
		(0 ..< self.pageCount).forEach { index in
			if index == self.currentPage {
				result += "*"
			}
			else {
				switch self.state(for: index) {
				case .none:
					result += "_"
				case .small:
					result += "."
				case .medium:
					result += "o"
				case .large:
					result += "O"
				}
			}
		}
		Swift.print(result)
	}
	
	// This is the currently selected page
	private var _currentPage: Int = 0
	
	var currentPage: Int {
		get { self._currentPage }
		set { self.setCurrentPage(newValue) }
	}
	
	/// The window range
	private var window: Range<Int>
	
	// This is the page index for the LEADING visible page
	@inlinable var firstVisiblePage: Int { self.window.lowerBound }
	// This is the page index for the TRAILING visible page
	@inlinable var lastVisiblePage: Int { self.window.upperBound - 1 }
	
	// Is the window currently sitting on the left edge
	@inlinable var windowIsAtLeftEdge: Bool { self.window.lowerBound == 0 }
	// Is the window currently sitting on the right edge
	@inlinable var windowIsAtRightEdge: Bool { self.window.upperBound == self.pageCount }
	
	init(pageCount: Int, windowSize: Int, initialPage: Int = 0) {

		let windowSize = pageCount < windowSize ? pageCount : windowSize
		
		self.windowSize = windowSize
		self.pageCount = pageCount

		self.validPages = 0 ..< pageCount

		// Set the initial window
		self.window = 0 ..< windowSize

		self.setCurrentPage(initialPage)
	}
	
	func setCurrentPage(_ page: Int) {
		// If we have no pages then just ignore
		if self.pageCount == 0 { return }

		// Make sure we're valid
		guard self.validPages.contains(page) else {
			return
		}

		self._currentPage = page
		
		// Quick first page handling
		if self.currentPage == 0 {
			self.window = 0 ..< self.windowSize
			return
		}
		
		// Quick last page handling
		if self.currentPage == self.pageCount - 1 {
			let leading = (self.pageCount - self.windowSize)
			self.window = leading ..< self.pageCount
			return
		}
		
		if self.window.inset(2).contains(self.currentPage) {
			// Window doesn't need moving
			return
		}
		
		let lx = max(0, self.window.lowerBound + 2)
		if self.currentPage < lx {
			let leading = max(0, self.currentPage - 2)
			self.window = leading ..< leading + self.windowSize
			return
		}
		
		if self.currentPage > self.lastVisiblePage - 2 {
			// Shift the window up
			let leading = min(self.currentPage + 2 - self.windowSize + 1, self.pageCount - self.windowSize)
			self.window = leading ..< leading + self.windowSize
		}
	}
}
