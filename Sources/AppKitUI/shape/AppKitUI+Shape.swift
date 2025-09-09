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

/// A shape.
///
/// Fillable and strokable
@MainActor
public class AUIShape: NSView {
	/// The shape's fill style
	public var fillStyle: AUIShapeFillable? = nil {
		didSet {
			self.rebuild()
		}
	}

	/// The shape's stroke color
	public var strokeColor: AUIResolvableColor? = nil {
		didSet {
			self.rebuild()
		}
	}

	/// The shape's stroke line width
	public var strokeLineWidth: Double = 0 {
		didSet {
			self.rebuild()
		}
	}

	/// The dash pattern to use when stroking the shape
	public var strokeLineDashPattern: [Double]? {
		didSet {
			self.rebuild()
		}
	}

	/// The dash phase to use when stroking the shape
	public var strokeLineDashPhase: Double? {
		didSet {
			self.rebuild()
		}
	}

	/// Create a shape with no fill or stoke
	public init() {
		super.init(frame: .zero)
		self.setup()
	}

	/// Create a shape using a fill style
	/// - Parameter fillStyle: The fill style
	public init(_ fillStyle: AUIShapeFillable) {
		super.init(frame: .zero)
		self.fillStyle = fillStyle
		self.setup()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		os_log("deinit: AUIShape", log: logger, type: .debug)
	}

	/// Return the shape's path
	///
	/// Needs to be overloaded in inherited classes
	open func shape(bounds: CGRect) -> CGPath {
		fatalError()
	}

	// Private

	public override var wantsUpdateLayer: Bool { true }

	public override func updateLayer() {
		super.updateLayer()
		self.rebuild()
	}

	// Make sure we reflect changes to the size of the view
	public override func setFrameSize(_ newSize: NSSize) {
		super.setFrameSize(newSize)
		self.rebuild()
	}

	private let shapeLayer = CAShapeLayer()
	private var backgroundLayer: CALayer?
	private var borderLayer: CAShapeLayer?
	private var observer: NSKeyValueObservation?

	private var showMarchingAnts: Bind<Bool>?
}

// MARK: - Fill

@MainActor
public extension AUIShape {
	/// Set the fill style
	@discardableResult @inlinable
	func fill(_ fillStyle: AUIShapeFillable?) -> Self {
		self.fillStyle = fillStyle
		return self
	}

	/// Set the fill color
	///
	/// Setting to nil removed any background fill style
	@discardableResult
	func fill(color: NSColor?) -> Self {
		self.fillStyle = AUIFillStyle.Color(color: color)
		return self
	}

	/// Set the fill color
	@discardableResult
	func fill(color: DynamicColor) -> Self {
		self.fillStyle = AUIFillStyle.Color(color: color)
		return self
	}

	/// Bind the fill color
	@discardableResult
	func fill(color: Bind<NSColor>) -> Self {
		color.register(self) { @MainActor [weak self] newColor in
			self?.fillStyle = AUIFillStyle.Color(color: newColor)
		}
		self.fillStyle = AUIFillStyle.Color(color: color.wrappedValue)
		return self
	}

	/// Bind the fill color
	@discardableResult
	func fill(color: Bind<DynamicColor>) -> Self {
		color.register(self) { @MainActor [weak self] newColor in
			self?.fillStyle = AUIFillStyle.Color(color: newColor)
		}
		self.fillStyle = AUIFillStyle.Color(color: color.wrappedValue)
		return self
	}

	/// Set the image fill
	@discardableResult
	func fill(image: NSImage?, contentsGravity: CALayerContentsGravity? = nil) -> Self {
		self.fillStyle = AUIFillStyle.Image(image: image, contentsGravity: contentsGravity)
		return self
	}
}

// MARK: - Stroke

@MainActor
public extension AUIShape {
	/// Set the stroke color
	@discardableResult @inlinable
	func strokeColor(_ color: NSColor?) -> Self {
		self.strokeColor = color
		return self
	}

	/// Set the stroke color
	@discardableResult @inlinable
	func strokeColor(_ color: DynamicColor) -> Self {
		self.strokeColor = color
		return self
	}

	/// Set the stroke line width
	@discardableResult @inlinable
	func strokeLineWidth(_ lineWidth: Double) -> Self {
		self.strokeLineWidth = max(0, lineWidth)
		return self
	}

	/// Set the stroke for the rectangle
	@discardableResult @inlinable
	func stroke(_ color: NSColor, lineWidth: Double) -> Self {
		self
			.strokeColor(color)
			.strokeLineWidth(lineWidth)
	}

	/// Set the stroke for the rectangle
	@discardableResult @inlinable
	func stroke(_ color: DynamicColor, lineWidth: Double) -> Self {
		self
			.strokeColor(color)
			.strokeLineWidth(lineWidth)
	}

	@discardableResult @inlinable
	func strokeLineDashPattern(_ pattern: [Double]) -> Self {
		self.strokeLineDashPattern = pattern
		return self
	}

	@discardableResult @inlinable
	func strokeLineDashPhase(_ phase: Double = 0) -> Self {
		self.strokeLineDashPhase = max(phase, 0)
		return self
	}
}

// MARK: - Animate marching ants

@MainActor
public extension AUIShape {
	@discardableResult
	func marchingAnts(_ isVisible: Bind<Bool>) -> Self {
		self.showMarchingAnts = isVisible
		isVisible.register(self) { @MainActor [weak self] state in
			self?.showMarchingAnts(state)
		}
		self.showMarchingAnts(isVisible.wrappedValue)
		return self
	}

	private func showMarchingAnts(_ isVisible: Bool) {
		guard let borderLayer = self.borderLayer else { return }
		borderLayer.removeAllAnimations()
		if isVisible {
			let lineDashAnimation = CABasicAnimation(keyPath: "lineDashPhase")
			lineDashAnimation.fromValue = 0
			lineDashAnimation.toValue = borderLayer.lineDashPattern?.reduce(0) { $0 + $1.intValue }
			lineDashAnimation.duration = 1
			lineDashAnimation.repeatCount = Float.greatestFiniteMagnitude
			borderLayer.add(lineDashAnimation, forKey: "phase")
		}
	}
}

@MainActor
extension AUIShape {
	private func setup() {
		self.wantsLayer = true
		self.clipsToBounds = false

		self.huggingPriority(.defaultLow, for: .horizontal)
		self.huggingPriority(.defaultLow, for: .vertical)

		self.compressionResistancePriority(.defaultHigh, for: .horizontal)
		self.compressionResistancePriority(.defaultHigh, for: .vertical)

		if #available(macOS 10.14, *) {
			self.observer = NSApp.observe(\.effectiveAppearance, options: [.new, .initial]) { @MainActor [weak self] app, change in
				self?.rebuild()
			}
		}

		self.rebuild()
	}

	func rebuild() {
		self.backgroundLayer?.removeFromSuperlayer()
		self.borderLayer?.removeFromSuperlayer()

		self.shapeLayer.frame = self.bounds
		self.shapeLayer.path = self.shape(bounds: self.bounds)
		self.shapeLayer.fillColor = .black

		// Update the colors to match the appearance
		self.fillStyle?.appearanceDidChange()

		self.backgroundLayer = self.fillStyle?.backgroundLayer()
		if let background = self.backgroundLayer {
			background.frame = self.bounds
			background.mask = self.shapeLayer
			background.zPosition = -2
			self.layer?.addSublayer(background)
		}

		if self.strokeLineWidth > 0, let strokeColor = self.strokeColor {
			let border = CAShapeLayer()
			self.borderLayer = border
			border.frame = self.bounds
			border.path = self.shapeLayer.path
			border.fillColor = .clear
			border.strokeColor = strokeColor.effectiveColor.cgColor
			border.lineWidth = self.strokeLineWidth

			border.lineDashPattern = self.strokeLineDashPattern?.map { NSNumber(value: $0) }
			border.lineDashPhase = self.strokeLineDashPhase ?? 0

			border.zPosition = -1
			self.layer?.addSublayer(border)
		}

		if let marchingAnts = self.showMarchingAnts, self.borderLayer != nil {
			self.showMarchingAnts(marchingAnts.wrappedValue)
		}
	}
}
