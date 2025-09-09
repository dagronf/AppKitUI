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

public extension AUIShapeFillable where Self == AUIFillStyle.Image {
	/// An image fill style
	/// - Parameters:
	///   - image: The image
	///   - contentsGravity: The gravity for the image
	/// - Returns: A new fill
	static func image(_ image: NSImage?, contentsGravity: CALayerContentsGravity? = nil) -> AUIShapeFillable {
		AUIFillStyle.Image(image: image, contentsGravity: contentsGravity)
	}
}

public extension AUIFillStyle {
	/// An image fill style
	class Image: AUIShapeFillable {
		/// An image fill style
		/// - Parameters:
		///   - image: The image
		///   - contentsGravity: The gravity for the image
		public init(image: NSImage? = nil, contentsGravity: CALayerContentsGravity? = nil) {
			self.image = image
			self.contentsGravity = contentsGravity
			self.update()
		}

		/// Set the image to be displayed
		public var image: NSImage? {
			didSet {
				self.update()
			}
		}

		/// Set the contents gravity for the i mage
		public var contentsGravity: CALayerContentsGravity? = nil {
			didSet {
				self.update()
			}
		}

		public func backgroundLayer() -> CALayer { self.imageLayer }

		public func appearanceDidChange() { }

		private func update() {
			self.imageLayer.contents = self.image
			if let cg = self.contentsGravity {
				self.imageLayer.contentsGravity = cg
			}
		}
		private let imageLayer = CALayer()
	}
}
