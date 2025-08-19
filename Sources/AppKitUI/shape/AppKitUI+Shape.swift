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
public class AUIShape: NSView {
	/// The rectangle fill color
	public var fillColor: NSColor? = nil {
		didSet {
			self.rebuild()
		}
	}

	/// Set the fill color
	@discardableResult @inlinable
	public func fillColor(_ color: NSColor?) -> Self {
		self.fillColor = color
		return self
	}

	/// The stroke color
	public var strokeColor: NSColor? = nil {
		didSet {
			self.rebuild()
		}
	}

	/// Set the stroke color
	@discardableResult @inlinable
	public func strokeColor(_ color: NSColor?) -> Self {
		self.strokeColor = color
		return self
	}

	/// The stroke line width for the rectangle
	public var strokeLineWidth: Double = 0 {
		didSet {
			self.rebuild()
		}
	}

	/// Set the stroke line width
	@discardableResult @inlinable
	public func strokeLineWidth(_ lineWidth: Double) -> Self {
		self.strokeLineWidth = lineWidth
		return self
	}

	/// Set the stroke for the rectangle
	@discardableResult @inlinable
	public func stroke(_ color: NSColor, lineWidth: Double) -> Self {
		self
			.strokeColor(color)
			.strokeLineWidth(lineWidth)
	}

	open func shape(bounds: CGRect) -> CGPath {
		fatalError()
	}

	public init() {
		super.init(frame: .zero)
		self.setup()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setup() {
		self.wantsLayer = true
		self.clipsToBounds = false

		self.layer?.backgroundColor = .clear
		self.layer?.addSublayer(self.content)

		self.huggingPriority(.defaultLow, for: .horizontal)
		self.huggingPriority(.defaultLow, for: .vertical)

		self.compressionResistancePriority(.defaultHigh, for: .horizontal)
		self.compressionResistancePriority(.defaultHigh, for: .vertical)

		self.rebuild()
	}

	public override var wantsUpdateLayer: Bool { true }
	public override func updateLayer() {
		super.updateLayer()
		self.rebuild()
	}

	internal func rebuild() {
		self.content.frame = self.bounds
		self.content.path = self.shape(bounds: self.bounds)
		self.content.fillColor = self.fillColor?.cgColor ?? .clear

		self.content.strokeColor = self.strokeColor?.cgColor
		self.content.lineWidth = self.strokeLineWidth
	}

	private let content = CAShapeLayer()
}
