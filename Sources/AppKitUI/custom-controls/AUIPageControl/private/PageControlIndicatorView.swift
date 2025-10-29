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

private let DefaultImage: NSImage = {
	let i: NSImage
	if #available(macOS 11.0, *) {
		i = NSImage(systemSymbolName: "circle.fill", accessibilityDescription: nil)!
	} else {
		i = NSImage(named: NSImage.touchBarRecordStartTemplateName)!
		i.isTemplate = true
	}
	return i
}()

// A basic view that shows an image tinted with a color
@MainActor
class PageControlIndicatorView: NSView {
	private let pageImage = PageImageView()

	var image: NSImage = DefaultImage
	var delegate: PageControlIndicatorsView?
	var pageIndex: Int = -1

	/// Set the tint color
	var tintColor: NSColor? {
		didSet {
			self.pageImage.tintColor = tintColor
		}
	}

	var imageSize: CGSize = AUIPageControl.DefaultPageIndicatorSize

	/// Set the tint color for the indicator
	@inlinable func tintColor(_ color: NSColor?) -> Self {
		self.tintColor = color
		return self
	}

	init(imageSize: CGSize = AUIPageControl.DefaultPageIndicatorSize) {
		super.init(frame: .zero)
		self.imageSize = imageSize
		self.setup()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private var imageWidth: NSLayoutConstraint = NSLayoutConstraint()
	private var imageHeight: NSLayoutConstraint = NSLayoutConstraint()

	private var clickGesture: NSClickGestureRecognizer?

	func setup() {
		self.translatesAutoresizingMaskIntoConstraints = false
		self.wantsLayer = true

		self.pageImage.translatesAutoresizingMaskIntoConstraints = false
		self.pageImage.wantsLayer = true

		self.widthAnchor.constraint(equalToConstant: self.imageSize.width).isActive = true
		self.heightAnchor.constraint(equalToConstant: self.imageSize.height).isActive = true

		self.addSubview(self.pageImage)
		self.addConstraint(NSLayoutConstraint(item: self.pageImage, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
		self.addConstraint(NSLayoutConstraint(item: self.pageImage, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))

		self.imageWidth = self.pageImage.widthAnchor.constraint(equalToConstant: self.imageSize.width)
		self.imageWidth.isActive = true

		self.imageHeight = self.pageImage.heightAnchor.constraint(equalToConstant: self.imageSize.height)
		self.imageHeight.isActive = true

		let g = NSClickGestureRecognizer(target: self, action: #selector(onClick(_:)))
		self.addGestureRecognizer(g)
		self.clickGesture = g

		self.pageImage.image = self.image

		// By default show no indicator
		self.setState(.none, animated: false)

		self.resetCursorRects()
	}

	override func resetCursorRects() {
		super.resetCursorRects()
		if self.isEnabled {
			self.addCursorRect(self.bounds, cursor: .pointingHand)
		}
	}

	var isEnabled: Bool = true {
		didSet {
			guard let g = self.clickGesture else { fatalError() }
			g.isEnabled = self.isEnabled
			self.resetCursorRects()
		}
	}

	func setState(_ state: WindowedContent.State, animated: Bool) {
		let sz: Double
		switch state {
		case .none:
			sz = 0
		case .small:
			sz = 4
		case .medium:
			sz = 6
		case .large:
			sz = 8
		}

		let wca = animated ? self.imageWidth.animator() : self.imageWidth
		let hca = animated ? self.imageHeight.animator() : self.imageHeight

		wca.constant = sz
		hca.constant = sz
	}

	@inlinable func state(_ state: WindowedContent.State) -> Self {
		self.setState(state, animated: false)
		return self
	}

	@objc func onClick(_ sender: Any) {
		guard self.pageIndex >= 0 else {
			Swift.print("No index specified")
			return
		}
		self.delegate?.selectPage(self.pageIndex)
	}
}

// MARK: - Previews

#if DEBUG && canImport(AppKitUI)

import AppKitUI

@available(macOS 14.0, *)
#Preview("PageImageView check") {
	PageImageView(image: DefaultImage)
		.tintColor(.systemGreen)
		.debugFrame()
}

@available(macOS 14.0, *)
#Preview("none") {
	VStack {
		HStack(spacing: 0) {
			PageControlIndicatorView()
				.state(.none)
				.debugFrame()
		}
	}
}

@available(macOS 14.0, *)
#Preview("Simple Indicator") {
	VStack {
		HStack(spacing: 0) {
			PageControlIndicatorView()
			PageControlIndicatorView()
				.state(.large)
			PageControlIndicatorView()
				.state(.medium)
			PageControlIndicatorView()
				.state(.small)
			PageControlIndicatorView()
				.state(.none)
		}

		HStack(spacing: 0) {
			PageControlIndicatorView()
				.state(.large)
				.tintColor(.systemPink)
			PageControlIndicatorView()
				.state(.medium)
				.tintColor(.systemPink)
			PageControlIndicatorView()
				.state(.small)
				.tintColor(.systemPink)
			PageControlIndicatorView()
				.state(.none)
				.tintColor(.systemPink)
		}

		HStack {
			PageControlIndicatorView()
				.state(.large)
				.tintColor(.systemRed)
			PageControlIndicatorView()
				.state(.large)
				.tintColor(.systemGreen)
			PageControlIndicatorView()
				.state(.large)
				.tintColor(.systemBlue)
		}

		HStack(spacing: 0) {
			let sz = CGSize(width: 16, height: 21)
			PageControlIndicatorView(imageSize: sz)
				.state(.large)
				.tintColor(.systemRed)
			PageControlIndicatorView(imageSize: sz)
				.state(.large)
				.tintColor(.systemGreen)
			PageControlIndicatorView(imageSize: sz)
				.state(.large)
				.tintColor(.systemBlue)
		}

		HStack(spacing: 0) {
			let sz = CGSize(width: 16, height: 16)
			PageControlIndicatorView(imageSize: sz)
				.state(.large)
				.tintColor(.systemRed)
			PageControlIndicatorView(imageSize: sz)
				.state(.large)
				.tintColor(.systemGreen)
			PageControlIndicatorView(imageSize: sz)
				.state(.large)
				.tintColor(.systemBlue)
		}

	}
	.debugFrames()
}

#endif
