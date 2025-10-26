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

/// A hidable view that animates showing and hiding the view
///
/// Example :-
///
/// ```swift
/// let isVisible = Bind(true)
/// …
/// VStack(spacing: 0) {
///    NSButton.checkbox(title: "is visible")
///       .state(isVisible)
///    AUiHidableView(
///       isVisible: isVisible,
///       view:
///          VStack {
///             AUIImage(named: NSImage.homeTemplateName)
///                .frame(dimension: 48)
///             NSTextField(label: "Hi there")
///                .width(100)
///                .alignment(.center)
///          }
///    )
/// }
/// ```
///
@MainActor
public class AUIHidableView: NSView {

	private let child: NSView
	private let isVisible: Bind<Bool>

	private var bottomConstraint: NSLayoutConstraint?
	private var heightConstraint: NSLayoutConstraint?

	public init(isVisible: Bind<Bool>, view: NSView) {
		self.child = view
		self.isVisible = isVisible
		
		super.init(frame: .zero)

		self.setup()

		self.isVisible.register(self) { @MainActor [weak self] newValue in
			self?.reflectVisibility(isVisible: newValue, animated: true)
		}

		self.reflectVisibility(isVisible: self.isVisible.wrappedValue, animated: false)
	}

	private func reflectVisibility(isVisible: Bool, animated: Bool) {
		isVisible ? self.show(animated: animated) : self.hide(animated: animated)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setup() {
		self.translatesAutoresizingMaskIntoConstraints = false
		self.wantsLayer = true

		self.addSubview(self.child)
		self.addConstraint(NSLayoutConstraint(item: self.child, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
		self.addConstraint(NSLayoutConstraint(item: self.child, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0))
		self.addConstraint(NSLayoutConstraint(item: self.child, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))

		let initialHeight = self.child.fittingSize.height
		let c = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: initialHeight)
		c.priority = .required
		self.addConstraint(c)
		self.heightConstraint = c
	}

	func show(animated: Bool) {
		// Cancel any existing animations
		self.layer?.removeAllAnimations()

		let initialHeight = self.child.fittingSize.height

		self.child.isHidden = false

		CATransaction.begin()
		CATransaction.setCompletionBlock { [weak self] in
			self?.child.isHidden = false
			self?.child.alphaValue = 1.0
		}
		if animated == false {
			CATransaction.setAnimationDuration(0.0)
		}
		CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeInEaseOut))
		self.child.animator().alphaValue = 1.0
		self.heightConstraint?.animator().constant = initialHeight
		CATransaction.commit()
	}

	func hide(animated: Bool) {
		// Cancel any existing animations
		self.layer?.removeAllAnimations()

		CATransaction.begin()
		CATransaction.setCompletionBlock { [weak self] in
			self?.child.isHidden = true
		}

		if animated == false {
			CATransaction.setAnimationDuration(0.0)
		}
		CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeInEaseOut))
		self.child.animator().alphaValue = 0.0
		self.heightConstraint?.animator().constant = 0.0
		CATransaction.commit()
	}
}


// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("basic") {
	let isVisible = Bind(true)
	let isVisible2 = Bind(false)

	ScrollView {
		VStack {
			VStack(spacing: 0) {
				NSButton.checkbox(title: "is visible")
					.state(isVisible)
				AUIHidableView(
					isVisible: isVisible,
					view:
						VStack {
							AUIImage(named: NSImage.homeTemplateName)
								.frame(dimension: 48)
							NSTextField(label: "Hi there")
								.width(100)
								.alignment(.center)
						}
				)
			}

			HDivider()

			NSButton.checkbox(title: "is visible 2")
				.state(isVisible2)
			AUIHidableView(
				isVisible: isVisible2,
				view:
					AUIRadioGroup()
						.items([
							"one item here",
							"second item here",
							"third? Groundbreaking",
							"fourth of nature",
							"i plead the fifth"
						])
					.padding(8)
			)
		}
		.debugFrames()
	}
}

#endif
