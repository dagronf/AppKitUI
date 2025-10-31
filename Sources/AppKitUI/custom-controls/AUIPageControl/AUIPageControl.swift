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

/// The default page indicator size
public let AUIPageControlDefaultPageIndicatorSize = CGSize(width: 21, height: 21)

/// A page control
@MainActor
@IBDesignable
@objc public class AUIPageControl: NSControl {
	/// Orientation
	@IBInspectable @objc public dynamic var isHorizontal: Bool = true
	/// Page indicator width
	@IBInspectable @objc public dynamic var pageIndicatorWidth: Double = AUIPageControlDefaultPageIndicatorSize.width
	/// Page indicator height
	@IBInspectable @objc public dynamic var pageIndicatorHeight: Double = AUIPageControlDefaultPageIndicatorSize.height
	/// The page indicator size
	private var pageIndicatorSize: CGSize {
		CGSize(width: self.pageIndicatorWidth, height: self.pageIndicatorHeight)
	}

	/// The number of pages in the control
	@IBInspectable @objc public dynamic var numberOfPages: Int = 6 {
		didSet {
			let content = WindowedContent(pageCount: self.numberOfPages, windowSize: self.windowSize, initialPage: self.currentPage)
			self.content = content
			self.indicatorsView?.content = content
		}
	}
	/// The window size
	@IBInspectable @objc public dynamic var windowSize: Int = 6
	/// The currently selected page
	@IBInspectable @objc public dynamic var currentPage: Int = 0 {
		didSet {
			if oldValue != self.currentPage {
				self.indicatorsView?.selectPage(self.currentPage)
			}
		}
	}

	/// Is the control disabled?
	///
	/// Thisis a KVO-compliant wrapper for `isEnabled` which allows being set
	/// from within Interface Builder
	@IBInspectable @objc public dynamic var disabled: Bool {
		get { !self.isEnabled }
		set { self.isEnabled = !newValue }
	}

	/// Is the control navigable by the keyboard
	@IBInspectable @objc public dynamic var isKeyboardNavigable: Bool = false

	/// A callback for when the selected page changes
	public var selectedPageDidChange: ((Int) -> Void)?

	/// The tint color to apply to the page indicator.
	@IBInspectable public var pageIndicatorTintColor: NSColor? {
		didSet {
			self.indicatorsView?.pageIndicatorTintColor = self.pageIndicatorTintColor
		}
	}

	/// The tint color to apply to the current page indicator.
	@IBInspectable public var currentPageIndicatorTintColor: NSColor? {
		didSet {
			self.indicatorsView?.currentPageIndicatorTintColor = self.currentPageIndicatorTintColor
		}
	}

	/// Create a page control
	/// - Parameters:
	///   - orientation: horizontal or vertical orientation
	///   - numberOfPages: The total number of pages
	///   - windowSize: The window size
	///   - initialPage: The initial selection for the control
	public init(
		_ orientation: NSUserInterfaceLayoutOrientation = .horizontal,
		pageIndicatorSize: CGSize = AUIPageControlDefaultPageIndicatorSize,
		numberOfPages: Int,
		windowSize: Int,
		initialPage: Int = 0
	) {
		self.isHorizontal = (orientation == .horizontal)
		self.pageIndicatorWidth = pageIndicatorSize.width
		self.pageIndicatorHeight = pageIndicatorSize.height
		self.numberOfPages = numberOfPages
		self.windowSize = min(numberOfPages, windowSize)

		let initial = max(0, min(numberOfPages - 1, initialPage))

		let content = WindowedContent(pageCount: numberOfPages, windowSize: windowSize, initialPage: initial)
		self.content = content
		self.indicatorsView = PageControlIndicatorsView(
			content: content,
			orientation: orientation,
			pageIndicatorSize: pageIndicatorSize
		)
		super.init(frame: .zero)
		self.setup()

		self.currentPage = initialPage
	}

	public required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	public override func awakeFromNib() {
		super.awakeFromNib()
		let content = WindowedContent(pageCount: self.numberOfPages, windowSize: self.windowSize)
		self.content = content
		self.indicatorsView = PageControlIndicatorsView(
			content: content,
			orientation: self.isHorizontal ? .horizontal : .vertical,
			pageIndicatorSize: self.pageIndicatorSize
		)

		self.setup()
	}

	public override var intrinsicContentSize: NSSize {
		guard let i = self.indicatorsView else { fatalError() }
		if i.orientation == .horizontal {
			return NSSize(width: self.pageIndicatorWidth * Double(self.windowSize), height: self.pageIndicatorHeight)
		}
		else {
			return NSSize(width: self.pageIndicatorWidth, height: self.pageIndicatorHeight * Double(self.windowSize))
		}
	}

	private var indicatorsView: PageControlIndicatorsView?
	private var leadingConstraint: NSLayoutConstraint?
	private var content: WindowedContent?
	private var enableDetector: NSKeyValueObservation?
}

@MainActor
extension AUIPageControl {
	@objc func selectionDidChange(to page: Int) {
		guard let content = self.content else { fatalError() }

		self.currentPage = page

		let offset = self.isHorizontal ? self.pageIndicatorWidth : self.pageIndicatorHeight

		let leadingOffset = Double(content.firstVisiblePage) * -offset
		self.leadingConstraint?.animator().constant = leadingOffset
		self.indicatorsView?.needsLayout = true

		self.usingPageStorage { $0.currentPage?.wrappedValue = page }

		self.selectedPageDidChange?(page)
	}

	private func setEnabled(_ value: Bool) {
		self.indicatorsView?.isEnabled = value
		self.layer!.opacity = value ? 1.0 : 0.4
	}

	private func setup() {
		self.translatesAutoresizingMaskIntoConstraints = false
		self.wantsLayer = true

		guard let iv = self.indicatorsView else { fatalError() }

		iv.parent = self

		self.setContentHuggingPriority(.required, for: .horizontal)
		self.setContentHuggingPriority(.required, for: .vertical)

		self.clipsToBounds = true

		self.addSubview(iv)

		if iv.orientation == .horizontal {
			self.addConstraint(NSLayoutConstraint(item: iv, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
			self.addConstraint(NSLayoutConstraint(item: iv, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
			let c = NSLayoutConstraint(item: iv, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
			self.addConstraint(c)
			self.leadingConstraint = c
		}
		else {
			self.addConstraint(NSLayoutConstraint(item: iv, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
			self.addConstraint(NSLayoutConstraint(item: iv, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0))

			let c = NSLayoutConstraint(item: iv, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
			self.addConstraint(c)
			self.leadingConstraint = c
		}

		if let color = self.pageIndicatorTintColor {
			self.indicatorsView?.pageIndicatorTintColor = color
		}

		if let color = self.currentPageIndicatorTintColor {
			self.indicatorsView?.currentPageIndicatorTintColor = color
		}

		iv.selectPage(self.currentPage)

		// Detect changes in the enabled state for this control so we can
		// pass it down to the actual buttons
		self.enableDetector = self.observe(\.isEnabled, options: [.initial, .new]) { [weak self] control, change in
			guard let value = change.newValue else { return }

			// observe calls arent guaranteed to run on the main thread, so
			DispatchQueue.main.async {
				self?.setEnabled(value)
			}
		}
		self.setEnabled(self.isEnabled)
	}
}

// MARK: - Navigation

@MainActor
public extension AUIPageControl {
	/// Move the selection to the next page
	func moveToNextPage() {
		guard self.currentPage < self.numberOfPages - 1 else {
			NSSound.beep()
			return
		}
		self.currentPage = min(self.numberOfPages - 1, self.currentPage + 1)
	}

	/// Move the selection to the previous page
	func moveToPreviousPage() {
		guard self.currentPage - 1 >= 0 else {
			NSSound.beep()
			return
		}
		self.currentPage = max(0, self.currentPage - 1)
	}

	/// Move the selection to the first page
	@inlinable func moveToFirstPage() {
		self.currentPage = 0
	}

	/// Move the selection to the last page
	@inlinable func moveToLastPage() {
		self.currentPage = self.numberOfPages - 1
	}
}

// MARK: - Colors

@MainActor
public extension AUIPageControl {
	/// Set the page indicator color
	/// - Parameter color: The color
	/// - Returns: self
	@inlinable
	func pageIndicatorTintColor(_ color: NSColor) -> Self {
		self.pageIndicatorTintColor = color
		return self
	}

	/// Set the color for the active page
	/// - Parameter color: The color
	/// - Returns: self
	@inlinable
	func currentPageIndicatorTintColor(_ color: NSColor) -> Self {
		self.currentPageIndicatorTintColor = color
		return self
	}
}

// MARK: - Keyboard support

import Carbon.HIToolbox

public extension AUIPageControl {
	override var acceptsFirstResponder: Bool { self.isKeyboardNavigable && self.isEnabled }
	override var canBecomeKeyView: Bool { self.isKeyboardNavigable && self.isEnabled }
	override var focusRingMaskBounds: NSRect { self.bounds.insetBy(dx: -1, dy: -1) }
	override func drawFocusRingMask() {
		let c = min(self.bounds.height, self.bounds.width)
		let cr = (c - 2) / 2
		NSBezierPath(roundedRect: self.bounds.insetBy(dx: -1, dy: -1), xRadius: cr, yRadius: cr).fill()
	}

	override func keyDown(with event: NSEvent) {
		if event.keyCode == kVK_LeftArrow {
			self.moveToPreviousPage()
		}
		else if event.keyCode == kVK_RightArrow {
			self.moveToNextPage()
		}
		else if event.keyCode == kVK_UpArrow {
			self.isHorizontal ? self.moveToLastPage() : self.moveToFirstPage()
		}
		else if event.keyCode == kVK_DownArrow {
			self.isHorizontal ? self.moveToFirstPage() : self.moveToLastPage()
		}
		else if event.keyCode == kVK_Space {
			self.moveToNextPage()
		}
		else if event.keyCode == kVK_Home {
			self.currentPage = 0
		}
		else if event.keyCode == kVK_End {
			self.currentPage = self.numberOfPages - 1
		}
		else {
			super.keyDown(with: event)
		}
	}

	@inlinable func isKeyboardNavigable(_ value: Bool) -> Self {
		self.isKeyboardNavigable = value
		return self
	}
}

// MARK: - Actions

public extension AUIPageControl {
	/// A block to call when the page control selection changes
	/// - Parameter block: The block to call when the change occurs passing the new selected page
	/// - Returns: self
	@discardableResult @inlinable
	func onSelectedPageChange(_ block: @escaping (Int) -> Void) -> Self {
		self.selectedPageDidChange = block
		return self
	}
}

// MARK: - Bindings

public extension AUIPageControl {
	/// Create a page control
	/// - Parameters:
	///   - orientation: horizontal or vertical orientation
	///   - numberOfPages: The total number of pages
	///   - windowSize: The window size
	///   - currentPage: The current page binding
	convenience init(
		_ orientation: NSUserInterfaceLayoutOrientation = .horizontal,
		pageIndicatorSize: CGSize = AUIPageControlDefaultPageIndicatorSize,
		numberOfPages: Int,
		windowSize: Int,
		currentPage: Bind<Int>
	) {
		self.init(orientation, pageIndicatorSize: pageIndicatorSize, numberOfPages: numberOfPages, windowSize: windowSize, initialPage: 0)
		self.currentPage(currentPage)
	}

	/// Bind the current page
	/// - Parameter page: The current page
	/// - Returns: self
	@discardableResult
	func currentPage(_ page: Bind<Int>) -> Self {
		page.register(self) { @MainActor [weak self] newPage in
			self?.currentPage = newPage
		}
		self.usingPageStorage { $0.currentPage = page }

		self.currentPage = page.wrappedValue
		return self
	}
}

// MARK: - Private

@MainActor
internal extension AUIPageControl {
	@MainActor
	class Storage {
		var currentPage: Bind<Int>?
		init() { }
		deinit {
			os_log("deinit: AUIPageControl.Storage", log: logger, type: .debug)
		}
	}

	@MainActor
	func usingPageStorage(_ block: @escaping (Storage) -> Void) {
		self.usingAssociatedValue(key: "__AUIPageControl_bond", initialValue: { Storage() }, block)
	}
}

// MARK: - Previews

#if DEBUG

@available(macOS 14.0, *)
#Preview("horizontal") {
	NSGridView {
		NSGridView.Row {
			NSTextField(label: "pages")
			NSTextField(label: "window")
			NSTextField(label: "control")
		}
		NSGridView.Row {
			NSTextField(label: "5")
			NSTextField(label: "5")
			VStack {
				AUIPageControl(numberOfPages: 5, windowSize: 5)
				AUIPageControl(numberOfPages: 5, windowSize: 5)
					.isEnabled(false)
			}
		}
		NSGridView.Row {
			NSTextField(label: "9")
			NSTextField(label: "12")
			AUIPageControl(numberOfPages: 9, windowSize: 12)
				.onSelectedPageChange { newPage in
					Swift.print("Selected page is now \(newPage)")
				}
		}
		NSGridView.Row {
			NSTextField(label: "7")
			NSTextField(label: "5")
			AUIPageControl(numberOfPages: 7, windowSize: 5)
				.isKeyboardNavigable(true)
		}
		NSGridView.Row {
			NSTextField(label: "20")
			NSTextField(label: "10")
			VStack {
				AUIPageControl(numberOfPages: 20, windowSize: 10, initialPage: 2)
					.pageIndicatorTintColor(.systemIndigo)
					.currentPageIndicatorTintColor(.systemOrange)
					.isKeyboardNavigable(true)
				AUIPageControl(
					pageIndicatorSize: CGSize(width: 16, height: 16),
					numberOfPages: 20,
					windowSize: 10,
					initialPage: 2
				)
				.pageIndicatorTintColor(.systemIndigo)
				.currentPageIndicatorTintColor(.systemOrange)
				.isKeyboardNavigable(true)
			}
		}
	}
	.columnAlignment(.center, forColumns: 0 ... 2)
}

@available(macOS 14.0, *)
#Preview("vertical") {
	HStack {
		AUIPageControl(.vertical, numberOfPages: 2, windowSize: 5)
		AUIPageControl(.vertical, numberOfPages: 5, windowSize: 5)
		AUIPageControl(.vertical, numberOfPages: 15, windowSize: 5)
		AUIPageControl(.vertical, numberOfPages: 20, windowSize: 10, initialPage: 2)
			.pageIndicatorTintColor(.systemIndigo)
			.currentPageIndicatorTintColor(.systemOrange)
		AUIPageControl(.vertical, pageIndicatorSize: CGSize(width: 16, height: 16), numberOfPages: 20, windowSize: 10, initialPage: 2)
			.pageIndicatorTintColor(.systemIndigo)
			.currentPageIndicatorTintColor(.systemOrange)
	}
}

@available(macOS 14.0, *)
#Preview("edge cases") {
	HStack {
		VStack {
			for i in 0 ... 10 {
				AUIPageControl(numberOfPages: i, windowSize: 6)
					.isKeyboardNavigable(true)
			}
		}
		HStack {
			for i in 0 ... 10 {
				AUIPageControl(.vertical, numberOfPages: i, windowSize: 6, initialPage: 0)
					.isKeyboardNavigable(true)
			}
		}
	}
	.debugFrames()
}

@available(macOS 14.0, *)
#Preview("changing") {
	VStack {
		var cx: AUIPageControl?
		AUIPageControl(numberOfPages: 8, windowSize: 8)
			.store(in: &cx)
		HStack {
			NSButton(title: "-") { _ in
				cx!.numberOfPages = max(0, cx!.numberOfPages - 1)
			}
			NSButton(title: "+") { _ in
				cx!.numberOfPages = cx!.numberOfPages + 1
			}
		}
	}
	.debugFrames()
}

#endif
