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

/// A note to remind me why I didn't just use `NSGridRow` here :-
///
/// AppKit throws an internal exception when you try to manually create an NSGridRow instance via the init().
/// The exception states that NSGridRow should never be created and should only be accessed via NSGridView.
///
/// Hence, the birth of a new wrapper class `NSGridView.Row`!

@available(macOS 10.12, *)
@MainActor
public extension NSGridView {
	/// An NSGridView row definition
	@MainActor
	class Row {
		/// Create a grid row
		/// - Parameters:
		///   - topPadding: The padding to apply to the top of the row
		///   - bottomPadding: The padding to apply to the bottom of the row
		///   - rowAlignment: The alignment for all cells in the row
		///   - builder: The cell builder
		public init(
			topPadding: CGFloat = 0,
			bottomPadding: CGFloat = 0,
			rowAlignment: NSGridRow.Alignment = .inherited,
			@NSViewsBuilder builder: () -> [NSView]
		) {

			let rowViews = builder()
			rowViews.translatesAutoresizingMaskIntoConstraints(false)

			self.rowCells = rowViews
			self.topPadding = topPadding
			self.bottomPadding = bottomPadding
			self.rowAlignment = rowAlignment
		}

		var topPadding: Double
		var bottomPadding: Double
		var rowAlignment: NSGridRow.Alignment

		let rowCells: [NSView]
		var mergedCells: [ClosedRange<Int>] = []
	}
}

// MARK: - Row Modifiers

@MainActor
public extension NSGridView.Row {
	/// Set the row's top padding
	/// - Parameter padding: The padding value
	/// - Returns: self
	@discardableResult
	func topPadding(_ padding: Double) -> Self {
		self.topPadding = padding
		return self
	}

	/// Set the row's bottom padding
	/// - Parameter padding: The padding value
	/// - Returns: self
	@discardableResult
	func bottomPadding(_ padding: Double) -> Self {
		self.bottomPadding = padding
		return self
	}

	/// Set the row's alignment
	/// - Parameter alignment: The alignment
	/// - Returns: self
	@discardableResult
	func rowAlignment(_ alignment: NSGridRow.Alignment) -> Self {
		self.rowAlignment = alignment
		return self
	}
}

// MARK: - Row cell merging

@MainActor
public extension NSGridView.Row {
	/// Merge the cell indexes for this row
	/// - Parameter indexes: The indexes to merge
	/// - Returns: self
	@discardableResult
	func mergeCells(_ indexes: ClosedRange<Int>) -> Self {
		self.mergedCells.append(indexes)
		return self
	}

	/// Merge the cell indexes for this row
	/// - Parameter indexes: The indexes to merge
	/// - Returns: self
	@discardableResult
	func mergeCells(_ indexes: [ClosedRange<Int>]) -> Self {
		self.mergedCells.append(contentsOf: indexes)
		return self
	}
}

// MARK: GridRow Result builder

@available(macOS 10.12, *)
@resultBuilder
public enum GridRowBuilder {
	static func buildBlock() -> [NSGridView.Row] { [] }
}

@available(macOS 10.12, *)
public extension GridRowBuilder {
	static func buildBlock(_ settings: NSGridView.Row...) -> [NSGridView.Row] {
		settings
	}

	static func buildBlock(_ settings: [NSGridView.Row]) -> [NSGridView.Row] {
		settings
	}

	static func buildOptional(_ component: [NSGridView.Row]?) -> [NSGridView.Row] {
		component ?? []
	}

	/// Add support for if statements.
	static func buildEither(first components: [NSGridView.Row]) -> [NSGridView.Row] {
		 components
	}

	static func buildEither(second components: [NSGridView.Row]) -> [NSGridView.Row] {
		 components
	}

	/// Add support for loops.
	static func buildArray(_ components: [[NSGridView.Row]]) -> [NSGridView.Row] {
		 components.flatMap { $0 }
	}
}
