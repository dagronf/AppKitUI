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

/// A CollectionView that manages its children in a flow-style layout
///
/// When horizontal space isn't available for a view, moves to the next row and starts again
@MainActor
class FlowCollectionView: NSCollectionView {
	override func reloadData() {
		super.reloadData()
		self.invalidateIntrinsicContentSize()
	}

	override func viewWillMove(toWindow newWindow: NSWindow?) {
		super.viewWillMove(toWindow: newWindow)
		self.backgroundColors = [.clear]
		self.setContentHuggingPriority(.init(10), for: .horizontal)
		self.setContentHuggingPriority(.init(999), for: .vertical)
	}

	override func layout() {
		super.layout()
		self.invalidateIntrinsicContentSize()
	}

	override var intrinsicContentSize: CGSize {
		let intr = self.collectionViewLayout?.collectionViewContentSize ?? .zero
		return CGSize(width: -1, height: intr.height)
	}
}

// MARK: - Flow item

extension FlowCollectionView {
	// The collection item
	class CollectionItem: NSCollectionViewItem {
		override func loadView() {
			self.view = NSView()
			self.view.translatesAutoresizingMaskIntoConstraints = false
			self.view.wantsLayer = true
		}

		override func viewDidLoad() {
			super.viewDidLoad()
			if let v = elementView {
				self.view.addSubview(v)
				v.pin(inside: self.view)
			}
		}

		var elementView: NSView?
	}
}

// MARK: - Flow layout

// A left-aligned flow layout class
class CollectionViewLeftAlignedFlowLayout: NSCollectionViewFlowLayout {
	internal var direction: NSUserInterfaceLayoutDirection!

	override func layoutAttributesForElements(in rect: NSRect) -> [NSCollectionViewLayoutAttributes] {
		let defaultAttributes = super.layoutAttributesForElements(in: rect)
		if defaultAttributes.isEmpty { return defaultAttributes }
		if self.direction == .rightToLeft {
			return self.layoutAttributesForElementsRTL(in: rect, defaultAttributes: defaultAttributes)
		}
		else {
			return self.layoutAttributesForElementsLTR(in: rect, defaultAttributes: defaultAttributes)
		}
	}

	private func layoutAttributesForElementsLTR(
		in rect: NSRect,
		defaultAttributes: [NSCollectionViewLayoutAttributes]
	) -> [NSCollectionViewLayoutAttributes] {
		var attributes = [NSCollectionViewLayoutAttributes]()
		var leftMargin = sectionInset.left
		var lastYPosition = defaultAttributes[0].frame.maxY

		for itemAttributes in defaultAttributes {
			guard let newAttributes = itemAttributes.copy() as? NSCollectionViewLayoutAttributes else {
				continue
			}

			if newAttributes.frame.origin.y > lastYPosition {
				// Wrap to the next line
				leftMargin = sectionInset.left
			}

			newAttributes.frame.origin.x = leftMargin
			leftMargin += newAttributes.frame.width + minimumInteritemSpacing
			lastYPosition = newAttributes.frame.maxY

			attributes.append(newAttributes)
		}
		return attributes
	}

	private func layoutAttributesForElementsRTL(
		in rect: NSRect,
		defaultAttributes: [NSCollectionViewLayoutAttributes]
	) -> [NSCollectionViewLayoutAttributes] {
		var attributes = [NSCollectionViewLayoutAttributes]()
		let rightMargin = self.collectionViewContentSize.width - sectionInset.right
		var rightPosition = rightMargin
		var lastYPosition = defaultAttributes[0].frame.maxY

		for itemAttributes in defaultAttributes {
			guard let newAttributes = itemAttributes.copy() as? NSCollectionViewLayoutAttributes else {
				continue
			}

			if newAttributes.frame.origin.y > lastYPosition {
				// The next line
				rightPosition = rightMargin
			}

			newAttributes.frame.origin.x = rightPosition - itemAttributes.frame.width
			rightPosition -= (newAttributes.frame.width + minimumInteritemSpacing)
			lastYPosition = newAttributes.frame.maxY

			attributes.append(newAttributes)
		}
		return attributes
	}
}
