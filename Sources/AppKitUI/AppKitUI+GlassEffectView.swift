////
////  Copyright © 2025 Darren Ford. All rights reserved.
////
////  MIT license
////
////  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
////  documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
////  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
////  permit persons to whom the Software is furnished to do so, subject to the following conditions:
////
////  The above copyright notice and this permission notice shall be included in all copies or substantial
////  portions of the Software.
////
////  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
////  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
////  OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
////  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
////
//
//import AppKit
//
///// A view that uses the new glass effects for macOS 26 or later, or falls back to basic `NSView` if not
//@MainActor
//public class AUIGlassEffectView: NSView {
//	/// Create a glass effect view, falling back to a basic NSView on systems >= 26.0
//	/// - Parameters:
//	///   - cornerRadius: The corner radius for the view
//	///   - tintColor: The tint color
//	///   - builder: The view builder for the content
//	public init(
//		cornerRadius: CGFloat? = nil,
//		tintColor: NSColor? = nil,
//		_ builder: () -> NSView
//	) {
//		if #available(macOS 26, *) {
//			let glassView = NSGlassEffectView()
//			glassView.translatesAutoresizingMaskIntoConstraints = false
//			glassView.contentView = builder()
//			if let cornerRadius {
//				glassView.cornerRadius = cornerRadius
//			}
//			if let tintColor {
//				glassView.tintColor = tintColor
//			}
//			self.contentView = glassView
//		}
//		else {
//			self.contentView = builder()
//		}
//
//		super.init(frame: .zero)
//		self.translatesAutoresizingMaskIntoConstraints = false
//
//		self.content(fill: self.contentView)
//	}
//
//	required init?(coder: NSCoder) {
//		fatalError("init(coder:) has not been implemented")
//	}
//
//	/// Set the glass style
//	/// - Parameter style: The style
//	/// - Returns: self
//	@available(macOS 26.0, *)
//	func style(_ style: NSGlassEffectView.Style) -> Self {
//		self.glassView?.style = style
//		return self
//	}
//
//	@available(macOS 26.0, *)
//	private var glassView: NSGlassEffectView? {
//		self.contentView as? NSGlassEffectView
//	}
//
//	private let contentView: NSView
//}
//
//// MARK: - Previews
//
//#if DEBUG
//
//@available(macOS 14, *)
//#Preview("default") {
//	let im1 = NSImage(systemSymbolName: "trash", accessibilityDescription: nil)!
//	let im2 = NSImage(systemSymbolName: "archivebox", accessibilityDescription: nil)!
//	let im3 = NSImage(systemSymbolName: "xmark.bin", accessibilityDescription: nil)!
//
//	let imleft = NSImage(systemSymbolName: "chevron.left", accessibilityDescription: nil)!
//	let imright = NSImage(systemSymbolName: "chevron.right", accessibilityDescription: nil)!
//
//	let imcycle = NSImage(systemSymbolName: "figure.outdoor.cycle", accessibilityDescription: nil)!
//		.isTemplate(true)
//
//	VStack(spacing: 20) {
//		HStack {
//			AUIGlassEffectView {
//				HStack {
//					NSButton()
//						.isBordered(false)
//						.image(im1)
//						.imageScaling(.scaleProportionallyDown)
//						.imagePosition(.imageOnly)
//					NSButton()
//						.isBordered(false)
//						.image(im2)
//						.imageScaling(.scaleProportionallyDown)
//						.imagePosition(.imageOnly)
//					NSButton()
//						.isBordered(false)
//						.image(im3)
//						.imageScaling(.scaleProportionallyDown)
//						.imagePosition(.imageOnly)
//				}
//				.padding(4)
//				.debugFrames()
//			}
//			AUIGlassEffectView {
//				NSButton()
//					.bezelStyle(.helpButton)
//					.imagePosition(.imageOnly)
//					.onAction { _ in
//						Swift.print("User clicked 'help'")
//					}
//			}
//		}
//
//		HStack {
//			NSVisualEffectView() {
//				HStack {
//					NSImageView(imageNamed: NSImage.userName)
//					VStack(alignment: .leading, spacing: 2) {
//						NSTextField(label: "Distance")
//							.font(.headline)
//						NSTextField(label: "12.5 MI")
//							.font(.body)
//					}
//					VDivider()
//					VStack(alignment: .leading, spacing: 2) {
//						NSTextField(label: "Training Effort")
//							.font(.headline)
//						NSTextField(label: "Moderate")
//							.font(.body)
//					}
//				}
//				.padding(8)
//			}
//			.backgroundCornerRadius(8)
//			.backgroundBorder(.tertiaryLabelColor, lineWidth: 0.5)
//			.identifier("vs1")
//
//			NSVisualEffectView() {
//				HStack {
//					NSButton()
//						.isBordered(false)
//						.image(imleft)
//						.imageScaling(.scaleProportionallyDown)
//						.imagePosition(.imageOnly)
//					VStack(spacing: -2) {
//						NSImageView(image: imcycle)
//							.imageScaling(.scaleProportionallyUpOrDown)
//							.frame(width: 32, height: 32)
//						NSTextField(label: "Cycling")
//							.font(.footnote.weight(.semibold))
//					}
//					NSButton()
//						.isBordered(false)
//						.image(imright)
//						.imageScaling(.scaleProportionallyDown)
//						.imagePosition(.imageOnly)
//				}
//				.padding(8)
//			}
//			.backgroundCornerRadius(8)
//			.backgroundBorder(.tertiaryLabelColor, lineWidth: 0.5)
//			.identifier("vs2")
//		}
//		.equalHeights(["vs1", "vs2"])
//		//.debugFrames()
//	}
//}
//
//#endif
