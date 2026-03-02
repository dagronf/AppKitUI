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
import os.log

private let clippingMaskKey__ = "clippingMaskKey__"

@MainActor
public extension NSView {
	/// Clip the drawing of this view to the supplied clip shape
	/// - Parameter clipShape: The clip shape
	/// - Returns: self
	func clipShape(_ clipShape: AUIShape) -> Self {
		// Make sure we have a layer
		self.wantsLayer(true)

		// Generate the mask layer and the initial clipping shape
		let maskLayer = CAShapeLayer()
		maskLayer.frame = self.bounds
		maskLayer.path = clipShape.shape(bounds: self.bounds)
		self.layer?.mask = maskLayer

		let maskInfo = ViewClippingMask(maskLayer: maskLayer, clipShape: clipShape)

		// Store the mask/clip information as an arbitrary value in this view
		self.setArbitraryValue(maskInfo, forKey: clippingMaskKey__)

		// If the frame changes for this view, make sure we reflect the new frame to the mask
		self.onFrameChange { @MainActor [weak self] _ in
			self?.updateMask()
		}

		return self
	}
}

// MARK: - Private

@MainActor
extension NSView {

	private class ViewClippingMask {
		// The layer representing the view's mask. Is owned by the view once set, so this should be weak to avoid loops
		weak var maskLayer: CAShapeLayer?
		// The clip shape to use with the view
		var clipShape: AUIShape?

		init(maskLayer: CAShapeLayer? = nil, clipShape: AUIShape? = nil) {
			self.maskLayer = maskLayer
			self.clipShape = clipShape
		}

		deinit {
			os_log("deinit: ViewClippingMask", log: logger, type: .debug)
		}
	}

	private func updateMask() {
		let info: ViewClippingMask? = self.getArbitraryValue(forKey: clippingMaskKey__)
		guard let info,
			let mask = info.maskLayer,
			let clipShape = info.clipShape
		else {
			return
		}

		mask.frame = self.bounds
		mask.path = clipShape.shape(bounds: self.bounds)
	}
}

// MARK: - Previews

#if DEBUG
private let compima__ = NSImage(named: NSImage.computerName)!
private let ima__ = NSImage(named: NSImage.everyoneName)!

@available(macOS 14, *)
#Preview("default") {

	VStack {
		ZStack(padding: 0) {
			Circle()
				.fill(color: .windowBackgroundColor)
				.shadow(offset: .init(width: 0, height: -2), color: .black.alpha(0.4), blurRadius: 4)
				.frame(dimension: 38)
			AUIImage(image: ima__)
				.frame(dimension: 38)
				.clipShape(Circle())
			Circle()
				.stroke(.textColor, lineWidth: 1.5)
				.frame(dimension: 38)
			Circle()
				.stroke(.textBackgroundColor, lineWidth: 0.5)
				.frame(dimension: 36)
				.padding(1.5)
		}
		.frame(dimension: 38)
	}
	//.debugFrames()
}

@available(macOS 14, *)
#Preview("simple") {
	NSView(layoutStyle: .centered) {
		ZStack {
			Rectangle(cornerRadius: 10)
				.fill(color: .systemPurple)
				.frame(dimension: 64)
			Rectangle(cornerRadius: 8)
				.fill(color: .windowBackgroundColor)
				.frame(dimension: 60)
			AUIImage(image: compima__)
				.frame(dimension: 60)
				.clipShape(Rectangle(cornerRadius: 8))
		}
	}
}

#endif
