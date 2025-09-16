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
public class AUIDropView: NSView {
	
	/// Create a drop view
	public convenience init() {
		self.init(frame: .zero)
	}

	public convenience init(isDroppable: Bind<Bool>) {
		self.init()
		self.isDroppable = isDroppable
	}

	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		self.setup()
	}

	required init?(coder: NSCoder) {
		fatalError()
	}

	/// A binding indicating whether the dragged item is droppable on the view
	private var isDroppable: Bind<Bool>?
	/// Called when the user drags over the top of this view
	private var onDragEnteredBlock: ((AUIDragInfo) -> NSDragOperation)?
	/// Called when the user drags out of the view
	private var onDragExitedBlock: ((AUIDragInfo?) -> Void)?
	/// Called when the user has dropped, and we need to provide a final yes/no decision
	private var onDragPrepareForDragOperationBlock: ((AUIDragInfo) -> Bool)?
	/// Called to perform the drop
	private var onDragPerformOperationBlock: ((AUIDragInfo) -> Bool)?
}

@MainActor
extension AUIDropView {
	private func setup() {
		self.wantsLayer = true
		self.translatesAutoresizingMaskIntoConstraints = false
		self.setContentHuggingPriority(.defaultLow, for: .horizontal)
		self.setContentHuggingPriority(.defaultLow, for: .vertical)
		self.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
		self.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
	}
}

// MARK: - Modifiers

@MainActor
public extension AUIDropView {
	/// Is the view currently supporting a drop?
	/// - Parameter value: The binding
	/// - Returns: self
	@discardableResult
	func isDroppable(_ value: Bind<Bool>) -> Self {
		self.isDroppable = value
		return self
	}

	/// Registers the pasteboard types that the view will accept as the destination of a dragging session.
	/// - Parameters:
	///   - types: An array of Uniform Type Identifier. See System-Declared Uniform Type Identifiers for descriptions of the pasteboard type identifiers.
	/// - Returns: self
	@discardableResult
	func registeredTypes(_ types: [NSPasteboard.PasteboardType]) -> Self {
		self.registerForDraggedTypes(types)
		return self
	}
}

// MARK: - Actions

@MainActor
public extension AUIDropView {
	/// Set a block to call when the user drags a compatible item over the view, and returns the acceptable drag operation.
	/// - Parameter block: The block
	/// - Returns: self
	@discardableResult
	public func onDragEntered(_ block: @escaping (AUIDragInfo) -> NSDragOperation) -> Self {
		self.onDragEnteredBlock = block
		return self
	}

	/// Set a block to call when the user drags out of the view
	/// - Parameter block: The block
	/// - Returns: self
	@discardableResult
	public func onDragExited(_ block: @escaping (AUIDragInfo?) -> Void) -> Self {
		self.onDragExitedBlock = block
		return self
	}

	/// Set a block to call when the user drops the item
	/// - Parameter block: The block. Returns true if the item should be accepted, or false to reject the drop
	/// - Returns: self
	@discardableResult
	public func onDragPrepareForDragOperation(_ block: @escaping (AUIDragInfo) -> Bool) -> Self {
		self.onDragPrepareForDragOperationBlock = block
		return self
	}

	@discardableResult
	public func onDragPerformOperation(_ block: @escaping (AUIDragInfo) -> Bool) -> Self {
		self.onDragPerformOperationBlock = block
		return self
	}
}

@MainActor
public extension AUIDropView {
	// Called when the user drops, and we have to give a yes/no answer for whether to accept the drop
	override func prepareForDragOperation(_ sender: any NSDraggingInfo) -> Bool {
		return self.onDragPrepareForDragOperationBlock?(AUIDragInfo(sender)) ?? false
	}

	// This is called when the user drags _something_ into the view
	override func draggingEntered(_ sender: any NSDraggingInfo) -> NSDragOperation {
		let dragOperation = self.onDragEnteredBlock?(AUIDragInfo(sender)) ?? []
		self.isDroppable?.wrappedValue = (dragOperation != [])
		return dragOperation
	}

	// Called when the user drags out of the view
	override func draggingExited(_ sender: (any NSDraggingInfo)?) {
		var dragInfo: AUIDragInfo?
		if let sender { dragInfo = AUIDragInfo(sender) }
		self.onDragExitedBlock?(dragInfo)
		self.isDroppable?.wrappedValue = false
	}

	// Called to perform the drag operation
	override func performDragOperation(_ sender: any NSDraggingInfo) -> Bool {
		self.onDragPerformOperationBlock?(AUIDragInfo(sender)) ?? false
	}

	// Final clean up when the drag operation completes
	public override func concludeDragOperation(_ sender: (any NSDraggingInfo)?) {
		self.isDroppable?.wrappedValue = false
	}
}
