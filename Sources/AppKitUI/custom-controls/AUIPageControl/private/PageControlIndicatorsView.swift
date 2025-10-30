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

@MainActor
class PageControlIndicatorsView: NSStackView {

	weak var parent: AUIPageControl?

	var content: WindowedContent {
		didSet {
			self.updateContent()
		}
	}

	let pageIndicatorSize: CGSize

	init(
		content: WindowedContent,
		orientation: NSUserInterfaceLayoutOrientation = .horizontal,
		pageIndicatorSize: CGSize = CGSize(width: 21, height: 21)
	) {
		self.content = content
		self.pageIndicatorSize = pageIndicatorSize
		super.init(frame: .zero)
		self.orientation = orientation
		self.setup()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	/// Set the color to tint when the indicator is not selected
	var pageIndicatorTintColor: NSColor? {
		didSet {
			self.pageSelected(self.content.currentPage)
		}
	}

	@inlinable var _pageIndicatorTintColor: NSColor {
		self.pageIndicatorTintColor ?? .tertiaryLabelColor
	}

	/// Set the color to tint when the indicator is selected
	var currentPageIndicatorTintColor: NSColor? {
		didSet {
			self.pageSelected(self.content.currentPage)
		}
	}

	@inlinable var _currentPageIndicatorTintColor: NSColor {
		self.currentPageIndicatorTintColor ?? .textColor
	}

	override func updateLayer() {
		super.updateLayer()

		self.usingEffectiveAppearance {
			self.selectPage(self.content.currentPage, shouldAnimate: true)
		}
	}

	func selectPage(_ page: Int, shouldAnimate: Bool = true) {
		NSAnimationContext.runAnimationGroup({ context in
			context.duration = shouldAnimate ? 0.15 : 0.00
			context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
			context.allowsImplicitAnimation = true
			
			self.pageSelected(page)
		}, completionHandler: {
			self.resetCursorRects()
		})
	}

	/// Enable or disable the control
	var isEnabled: Bool = true {
		didSet {
			self.indicators.forEach { $0.isEnabled = self.isEnabled }
		}
	}

	private var indicators: [PageControlIndicatorView] {
		self.arrangedSubviews as! [PageControlIndicatorView]
	}
}

@MainActor
extension PageControlIndicatorsView {
	private func setup() {
		self.translatesAutoresizingMaskIntoConstraints = false
		self.wantsLayer = true
		self.spacing = 0

		self.updateContent()

		self.selectPage(self.content.currentPage)
	}

	private func updateContent() {

		let change = self.content.pageCount - self.arrangedSubviews.count

		if change == 0 {
			// nothing to do!
			return
		}
		else if change > 0 {
			// Need to add some
			(0 ..< change).forEach { _ in
				let p = PageControlIndicatorView(imageSize: self.pageIndicatorSize)
				p.pageIndex = self.arrangedSubviews.count
				p.delegate = self
				self.addArrangedSubview(p)
			}
		}
		else {
			// Need to remove some
			(change ..< 0).forEach { _ in
				if let last = self.arrangedSubviews.last {
					self.removeView(last)
				}
			}
		}
	}
}

@MainActor
extension PageControlIndicatorsView {
	@objc func pageSelected(_ sender: PageControlIndicatorView) {
		self.pageSelected(sender.pageIndex)
	}

	private func pageSelected(_ index: Int) {
		self.content.currentPage = index
		self.usingEffectiveAppearance {
			for item in indicators.enumerated() {
				let b = item.element
				b.tintColor = (item.offset == self.content.currentPage) ? self._currentPageIndicatorTintColor : self._pageIndicatorTintColor
				b.setState(self.content.state(for: item.offset), animated: true)
			}
		}

		self.parent?.selectionDidChange(to: index)
	}
}

@MainActor
extension PageControlIndicatorsView {
	@inlinable func pageIndicatorTintColor(_ color: NSColor?) -> Self {
		self.pageIndicatorTintColor = color
		return self
	}

	@inlinable func currentPageIndicatorTintColor(_ color: NSColor?) -> Self {
		self.currentPageIndicatorTintColor = color
		return self
	}
}

// MARK: - Previews

#if DEBUG && canImport(AppKitUI)

import AppKitUI

@available(macOS 14.0, *)
#Preview("horizontal") {
	VStack {
		PageControlIndicatorsView(content: WindowedContent(pageCount: 5, windowSize: 5))
		PageControlIndicatorsView(content: WindowedContent(pageCount: 7, windowSize: 12))
		PageControlIndicatorsView(content: WindowedContent(pageCount: 20, windowSize: 10))

		PageControlIndicatorsView(content: WindowedContent(pageCount: 20, windowSize: 10, initialPage: 8))
			.pageIndicatorTintColor(.systemCyan)
			.currentPageIndicatorTintColor(.systemYellow)
	}
	.debugFrames()
}

@available(macOS 14.0, *)
#Preview("vertical", traits: .fixedLayout(width: 600, height: 600)) {
	HStack {
		PageControlIndicatorsView(content: WindowedContent(pageCount: 5, windowSize: 5), orientation: .vertical)
		PageControlIndicatorsView(content: WindowedContent(pageCount: 7, windowSize: 12), orientation: .vertical)
		PageControlIndicatorsView(content: WindowedContent(pageCount: 20, windowSize: 10), orientation: .vertical)

		PageControlIndicatorsView(content: WindowedContent(pageCount: 20, windowSize: 10, initialPage: 8), orientation: .vertical)
			.pageIndicatorTintColor(.systemCyan)
			.currentPageIndicatorTintColor(.systemYellow)

		PageControlIndicatorsView(
			content: WindowedContent(pageCount: 20, windowSize: 10, initialPage: 8),
			orientation: .vertical,
			pageIndicatorSize: CGSize(width: 16, height: 16)
		)
		.pageIndicatorTintColor(.systemGreen)
		.currentPageIndicatorTintColor(.systemIndigo)
	}
	.debugFrames()
}

#endif

