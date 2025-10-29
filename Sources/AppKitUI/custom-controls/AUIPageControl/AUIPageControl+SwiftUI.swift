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

import SwiftUI

/// A macOS compatible version of UIPageControl
@available(macOS 11, *)
public struct AUIPageControlUI {
	/// The page control orientation
	public let orientation: NSUserInterfaceLayoutOrientation
	/// The number of pages
	public let numberOfPages: Int
	/// The size of the window
	public let windowSize: Int

	/// The currently selected page
	@Binding public var currentPage: Int

	public var pageIndicatorSize: CGSize

	/// The color for a page indicator
	public var pageColor: Color?
	/// The color for the selected page indicator
	public var selectionColor: Color?

	/// Can the control accept first responder?
	public var isKeyboardNavigable: Bool = false

	public init(
		_ orientation: NSUserInterfaceLayoutOrientation = .horizontal,
		pageIndicatorSize: CGSize = AUIPageControl.DefaultPageIndicatorSize,
		numberOfPages: Int,
		windowSize: Int,
		currentPage: Binding<Int>
	) {
		self.orientation = orientation
		self.pageIndicatorSize = pageIndicatorSize
		self.numberOfPages = numberOfPages
		self.windowSize = windowSize
		self._currentPage = currentPage
	}
}

@available(macOS 11, *)
extension AUIPageControlUI: NSViewRepresentable {
	public func makeNSView(context: Context) -> AUIPageControl {
		let e = AUIPageControl(self.orientation, pageIndicatorSize: self.pageIndicatorSize, numberOfPages: self.numberOfPages, windowSize: self.windowSize)
		e.selectedPageDidChange = { page in
			self.currentPage = page
		}
		return e
	}

	public func updateNSView(_ nsView: AUIPageControl, context: Context) {
		nsView.numberOfPages = self.numberOfPages
		nsView.windowSize = min(self.numberOfPages, self.windowSize)
		nsView.selectedPageDidChange = { page in
			self.currentPage = page
		}

		updateIfDifferent(&nsView.pageIndicatorTintColor, value: NSColor(color: self.pageColor))
		updateIfDifferent(&nsView.currentPageIndicatorTintColor, value: NSColor(color: self.selectionColor))
		updateIfDifferent(&nsView.isKeyboardNavigable, value: self.isKeyboardNavigable)
		updateIfDifferent(&nsView.currentPage, value: self.currentPage)
	}
}

@available(macOS 11, *)
public extension AUIPageControlUI {
	/// Set the page indicator color
	func pageColor(_ color: Color) -> Self {
		var copy = self
		copy.pageColor = color
		return copy
	}

	/// Set the seleccted page indicator color
	func selectionColor(_ color: Color) -> Self {
		var copy = self
		copy.selectionColor = color
		return copy
	}

	/// Can this control be navigable via the keyboard?
	/// - Parameter value: If true, allows keyboard navigation
	/// - Returns: self
	func isKeyboardNavigable(_ value: Bool) -> Self {
		var copy = self
		copy.isKeyboardNavigable = value
		return copy
	}
}

// MARK: - SwiftUI Conveniences

@inlinable @inline(__always)
internal func updateIfDifferent<VALUE: Equatable>(_ core: inout VALUE, value: VALUE) {
	if value != core {
		core = value
	}
}

// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("horizontal") {
	@Previewable @State var currentPage1: Int = 2
	@Previewable @State var currentPage2: Int = 0
	@Previewable @State var currentPage3: Int = 13
	@Previewable @State var currentPage4: Int = 0

	@Previewable @State var fiveDisabled: Bool = true
	@Previewable @State var currentPage5: Int = 5

	VStack {
		AUIPageControlUI(numberOfPages: 5, windowSize: 5, currentPage: $currentPage1)
		AUIPageControlUI(numberOfPages: 9, windowSize: 12, currentPage: $currentPage2)
		HStack {
			AUIPageControlUI(numberOfPages: 20, windowSize: 10, currentPage: $currentPage3)
				.border(.red, width: 0.5)
			TextField("", value: $currentPage3, formatter: NumberFormatter())
				.frame(width: 75)
			Button("do") {
				currentPage3 = 4
			}
		}
		AUIPageControlUI(numberOfPages: 32, windowSize: 7, currentPage: $currentPage4)

		Divider()

		HStack {
			AUIPageControlUI(numberOfPages: 12, windowSize: 5, currentPage: $currentPage5)
				.isKeyboardNavigable(true)
				.disabled(fiveDisabled)
			Divider()
				.frame(height: 20)
			Toggle("disabled", isOn: $fiveDisabled)
		}

		Spacer()
	}
	.padding()
}

@available(macOS 14, *)
#Preview("vertical") {
	@Previewable @State var currentPage1: Int = 2
	@Previewable @State var currentPage2: Int = 0
	@Previewable @State var currentPage3: Int = 13
	@Previewable @State var currentPage4: Int = 0
	@Previewable @State var currentPage5: Int = 19
	HStack {
		AUIPageControlUI(.vertical, numberOfPages: 5, windowSize: 5, currentPage: $currentPage1)
		AUIPageControlUI(.vertical, numberOfPages: 9, windowSize: 12, currentPage: $currentPage2)
			.pageColor(.red)
			.selectionColor(.yellow)
		HStack {
			AUIPageControlUI(.vertical, numberOfPages: 20, windowSize: 10, currentPage: $currentPage3)
			TextField("", value: $currentPage3, formatter: NumberFormatter())
				.frame(width: 75)
			Button("do") {
				currentPage3 = 4
			}
		}
		AUIPageControlUI(.vertical, numberOfPages: 32, windowSize: 7, currentPage: $currentPage4)
		AUIPageControlUI(.vertical, numberOfPages: 32, windowSize: 7, currentPage: $currentPage5)
			.selectionColor(.indigo)
			.isKeyboardNavigable(true)
		AUIPageControlUI(.vertical, pageIndicatorSize: CGSize(width: 16, height: 16), numberOfPages: 32, windowSize: 7, currentPage: $currentPage5)
			.selectionColor(.indigo)
			.isKeyboardNavigable(true)
	}
	.padding()
}

#endif
