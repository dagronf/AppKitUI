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

class CircularAvatarView: NSView {

	// MARK: - Properties
	private var avatarImage: NSImage? {
		didSet {
			updateImageLayer()
		}
	}

	private var backgroundColor: NSColor = NSColor.systemGray {
		didSet {
			updateBackgroundLayer()
		}
	}

	private var borderColor: NSColor = NSColor.white {
		didSet {
			updateBorderLayer()
		}
	}

	private var borderWidth: CGFloat = 1.0 {
		didSet {
			updateBorderLayer()
		}
	}

	// Layer references
	private var backgroundLayer: CALayer!
	private var imageLayer: CALayer!
	private var borderLayer: CAShapeLayer!

	// MARK: - Initialization
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		setup()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}

	private func setup() {
		wantsLayer = true
		layer?.masksToBounds = false

		setupLayers()
	}

	private func setupLayers() {
		guard let mainLayer = layer else { return }

		// Background layer
		backgroundLayer = CALayer()
		backgroundLayer.masksToBounds = true
		mainLayer.addSublayer(backgroundLayer)

		// Image layer
		imageLayer = CALayer()
		imageLayer.masksToBounds = true
		imageLayer.contentsGravity = .resizeAspectFill
		backgroundLayer.addSublayer(imageLayer)

		// Border layer
		borderLayer = CAShapeLayer()
		borderLayer.fillColor = NSColor.clear.cgColor
		borderLayer.masksToBounds = false
		mainLayer.addSublayer(borderLayer)

		updateAllLayers()
	}

	// MARK: - Public Methods
	//    func setAvatarImage(_ image: NSImage?) {
	//        self.avatarImage = image
	//    }

	func avatarImage(_ image: NSImage?) -> Self {
		self.avatarImage = image
		return self
	}

	func setBackgroundColor(_ color: NSColor) {
		self.backgroundColor = color
	}

	func setBorderColor(_ color: NSColor) {
		self.borderColor = color
	}

	func setBorderWidth(_ width: CGFloat) {
		self.borderWidth = width
	}

	// MARK: - Layer Updates
	private func updateAllLayers() {
		updateBackgroundLayer()
		updateImageLayer()
		updateBorderLayer()
	}

	private func updateBackgroundLayer() {
		guard let backgroundLayer = backgroundLayer else { return }

		backgroundLayer.backgroundColor = backgroundColor.cgColor

		// Update frame and corner radius
		let bounds = self.bounds
		let radius = min(bounds.width, bounds.height) / 2

		backgroundLayer.frame = bounds
		backgroundLayer.cornerRadius = radius
	}

	private func updateImageLayer() {
		guard let imageLayer = imageLayer else { return }

		if let image = avatarImage {
			// Convert NSImage to CGImage
			let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)
			imageLayer.contents = cgImage
		} else {
			imageLayer.contents = nil
		}

		// Update frame
		imageLayer.frame = backgroundLayer?.bounds ?? bounds
	}

	private func updateBorderLayer() {
		guard let borderLayer = borderLayer else { return }

		let bounds = self.bounds

		// Create circular path
		let circlePath = CGPath(ellipseIn: bounds, transform: nil)

		borderLayer.path = circlePath
		borderLayer.strokeColor = borderColor.cgColor
		borderLayer.lineWidth = borderWidth
		borderLayer.frame = bounds

		// Hide border if width is 0
		borderLayer.isHidden = borderWidth <= 0
	}

	// MARK: - Layout
	override var intrinsicContentSize: NSSize {
		return NSSize(width: 80, height: 80) // Default size
	}

	override func layout() {
		super.layout()

		// Ensure the view is always square for perfect circle
		let size = min(bounds.width, bounds.height)
		if bounds.width != size || bounds.height != size {
			setFrameSize(NSSize(width: size, height: size))
		}

		// Update all layers when layout changes
		updateAllLayers()
	}

	override func setFrameSize(_ newSize: NSSize) {
		super.setFrameSize(newSize)
		updateAllLayers()
	}

	// MARK: - Animation Support
	func setAvatarImage(_ image: NSImage?, animated: Bool, duration: TimeInterval = 0.3) {
		if animated && avatarImage != nil {
			// Fade out current image
			CATransaction.begin()
			CATransaction.setAnimationDuration(duration / 2)
			imageLayer.opacity = 0.0

			CATransaction.setCompletionBlock { [weak self] in
				// Set new image
				self?.avatarImage = image

				// Fade in new image
				CATransaction.begin()
				CATransaction.setAnimationDuration(duration / 2)
				self?.imageLayer.opacity = 1.0
				CATransaction.commit()
			}
			CATransaction.commit()
		} else {
			self.avatarImage = image
		}
	}

	func setBorderWidth(_ width: CGFloat, animated: Bool, duration: TimeInterval = 0.3) {
		if animated {
			CATransaction.begin()
			CATransaction.setAnimationDuration(duration)
			self.borderWidth = width
			CATransaction.commit()
		} else {
			self.borderWidth = width
		}
	}
}

// MARK: - Convenience Extensions
extension CircularAvatarView {

	/// Load image from file path
	func loadImage(from path: String, animated: Bool = false) {
		if let image = NSImage(contentsOfFile: path) {
			setAvatarImage(image, animated: animated)
		}
	}

	/// Load image from URL (for local file URLs)
	func loadImage(from url: URL, animated: Bool = false) {
		if let image = NSImage(contentsOf: url) {
			setAvatarImage(image, animated: animated)
		}
	}

	/// Create with initial image
	convenience init(frame: NSRect, image: NSImage?) {
		self.init(frame: frame)
		self.setAvatarImage(image, animated: false)
	}

	/// Add a subtle shadow effect
	func addShadow(color: NSColor = NSColor.black, opacity: Float = 0.3, offset: NSSize = NSSize(width: 0, height: -2), radius: CGFloat = 4) {
		guard let mainLayer = layer else { return }

		mainLayer.shadowColor = color.cgColor
		mainLayer.shadowOpacity = opacity
		mainLayer.shadowOffset = offset
		mainLayer.shadowRadius = radius
		mainLayer.masksToBounds = false
	}

	/// Remove shadow effect
	func removeShadow() {
		guard let mainLayer = layer else { return }

		mainLayer.shadowOpacity = 0
	}
}
