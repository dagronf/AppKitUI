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

/// A flow-style horizontal layout
///
/// When horizontal space isn't available for a view, moves to the next row and starts again
@MainActor
public class Flow: NSView {
	/// Create a flow
	/// - Parameters:
	///   - minimumLineSpacing: The minimum spacing (in points) to use between rows.
	///   - minimumInteritemSpacing: The minimum spacing (in points) to use between items in the same row.
	///   - viewsBuilder: The builder for the content
	public init(
		minimumLineSpacing: Double? = nil,
		minimumInteritemSpacing: Double? = nil,
		@NSViewsBuilder viewsBuilder: @escaping () -> [NSView]
	) {
		self.viewsBuilder = viewsBuilder
		super.init(frame: .zero)
		self.setup(minimumLineSpacing, minimumInteritemSpacing)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func reloadData() {
		// Rebuild the child views
		self.childViews = self.viewsBuilder()
		self.childViews.translatesAutoresizingMaskIntoConstraints(false)
		self.flow.reloadData()
	}

	/// Returns the first subview that matches the given identifier
	/// - Parameter identifier: The NSUserInterfaceItemIdentifier to search for
	/// - Returns: The matching NSView, or nil if no match is found
	override func allSubviews() -> [NSView] {
		var items: [NSView] = [self]
		for subview in self.childViews {
			items.append(contentsOf: subview.allSubviews())
		}

		return items
	}


	private var childViews: [NSView] = []
	/// The block to call when the views need rebuilding
	private let viewsBuilder: () -> [NSView]
	private let flow = FlowCollectionView()
}

// MARK: - Binding

@MainActor
public extension Flow {
	@discardableResult
	func childViews(_ childViews: Bind<[NSView]>) -> Self {
		childViews.register(self) { @MainActor [weak self] newChildren in
			self?.setChildren(newChildren)
		}
		self.setChildren(childViews.wrappedValue)
		return self
	}
}


// MARK: - Private

@MainActor
private extension Flow {
	func setup(_ minimumLineSpacing: Double?, _ minimumInteritemSpacing: Double?) {
		self.translatesAutoresizingMaskIntoConstraints = false

		self.flow.translatesAutoresizingMaskIntoConstraints = false
		self.flow.delegate = self
		self.flow.dataSource = self

		self.flow.pin(inside: self)

		let layout = CollectionViewLeftAlignedFlowLayout()
		// By default, use the UI layout orientation
		layout.direction = self.flow.userInterfaceLayoutDirection

		if let minimumInteritemSpacing {
			layout.minimumInteritemSpacing = minimumInteritemSpacing
		}
		if let minimumLineSpacing {
			layout.minimumLineSpacing = minimumLineSpacing
		}

		self.flow.needsLayout = true
		self.flow.collectionViewLayout = layout

		self.reloadData()
	}

	func setChildren(_ children: [NSView]) {
		self.childViews = children
		self.childViews.translatesAutoresizingMaskIntoConstraints(false)
		self.flow.reloadData()
	}
}


@MainActor
public extension Flow {

	@discardableResult
	func layoutDirection(_ layoutDirection: NSUserInterfaceLayoutDirection) -> Self {
		if let layout = self.flow.collectionViewLayout as? CollectionViewLeftAlignedFlowLayout {
			layout.direction = layoutDirection
		}
		self.layoutSubtreeIfNeeded()
		return self
	}

	/// Add padding around this view
	/// - Parameter padding: The padding value
	/// - Returns: self
	@discardableResult
	override func padding(_ value: Double = 20) -> Self {
		if let layout = self.flow.collectionViewLayout as? CollectionViewLeftAlignedFlowLayout {
			layout.sectionInset = NSEdgeInsets(top: value, left: value, bottom: value, right: value)
		}
		self.layoutSubtreeIfNeeded()
		return self
	}

	/// Add padding around this view
	/// - Parameters:
	///   - top: Top padding
	///   - left: Left padding
	///   - bottom: Bottom padding
	///   - right: Right padding
	/// - Returns: A new NSView containging this view as a child view with the specified padding
	@discardableResult
	public override func padding(top: Double = 0, left: Double = 0, bottom: Double = 0, right: Double = 0) -> NSView {
		if let layout = self.flow.collectionViewLayout as? CollectionViewLeftAlignedFlowLayout {
			layout.sectionInset = NSEdgeInsets(top: top, left: left, bottom: bottom, right: right)
		}
		self.layoutSubtreeIfNeeded()
		return self
	}
}

extension Flow: NSCollectionViewDelegate, NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout {

	public func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
		//Swift.print("numberOfItemsInSection = \(self.childViews.count)")
		return self.childViews.count
	}
	
	public func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
		//Swift.print("itemForRepresentedObjectAt [\(indexPath)]")
		let item = FlowCollectionView.CollectionItem()
		item.elementView = self.childViews[indexPath.item]
		return item
	}
	
	public func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
		let view = self.childViews[indexPath.item]
		let sz = view.fittingSize
		//Swift.print("sizeForItemAt[\(indexPath)] = \(sz)")
		return sz
	}
}

// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("default") {
	ScrollView {
		VStack {
			Flow {
				AUILinkButton(title: "#earth")
				AUILinkButton(title: "#earth")
				AUILinkButton(title: "#universe")
				AUILinkButton(title: "#space")
				AUILinkButton(title: "#black_hole")
				AUILinkButton(title: "#meteor")
				AUILinkButton(title: "#sulky")
				AUILinkButton(title: "#weeble")
			}
			.debugFrames(.systemRed)

			Flow {
				NSButton(title: "#earth")
				NSButton(title: "#universe")
				NSButton(title: "#space")
				NSButton(title: "#black_hole")
				NSButton(title: "#meteor")
				NSButton(title: "#sulky")
				NSButton(title: "#weeble")
			}
			.layoutDirection(.rightToLeft)
			.debugFrames(.systemGreen)

			Flow(minimumLineSpacing: 2, minimumInteritemSpacing: 2) {
				NSButton(title: "#earth")
				NSButton(title: "#universe")
				NSButton(title: "#space")
				NSButton(title: "#black_hole")
				NSButton(title: "#meteor")
				NSButton(title: "#sulky")
				NSButton(title: "#weeble")
			}
			.debugFrames(.systemBlue)

			Flow(minimumLineSpacing: 16, minimumInteritemSpacing: 2) {
				NSButton(title: "#earth")
				NSButton(title: "#universe")
				NSButton(title: "#space")
				NSButton(title: "#black_hole")
				NSButton(title: "#meteor")
				NSButton(title: "#sulky")
				NSButton(title: "#weeble")
			}
			.padding()
			.debugFrames(.systemYellow)
		}
		.padding()
	}
}

#endif
