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

@available(macOS 10.12, *)
@MainActor
public extension NSGridView {
	/// Create a grid view with row content
	/// - Parameters:
	///   - xPlacement: The x placement
	///   - yPlacement: The y placement
	///   - columnSpacing: Space between columns
	///   - rowSpacing: Space between rows
	///   - rows: The rows
	@MainActor
	convenience init(
		xPlacement: NSGridCell.Placement = .inherited,
		yPlacement: NSGridCell.Placement = .inherited,
		columnSpacing: CGFloat? = nil,
		rowSpacing: CGFloat? = nil,
		rows: [NSGridView.Row]
	) {
		self.init()

		self.xPlacement = xPlacement
		self.yPlacement = yPlacement

		if let columnSpacing = columnSpacing {
			self.columnSpacing = columnSpacing
		}

		if let rowSpacing = rowSpacing {
			self.rowSpacing = rowSpacing
		}

		rows.enumerated().forEach { row in
			let views: [NSView] = row.element.rowCells
			self.addRow(with: views)
			let rowItem = self.row(at: row.0)
			rowItem.topPadding = row.1.topPadding
			rowItem.bottomPadding = row.1.bottomPadding
			rowItem.rowAlignment = row.1.rowAlignment

			row.element.mergedCells.forEach {
				rowItem.mergeCells(in: NSRange($0))
			}
		}
	}

	/// Create a grid view with row content generated from a builder
	/// - Parameters:
	///   - xPlacement: The x placement
	///   - yPlacement: The y placement
	///   - columnSpacing: Space between columns
	///   - rowSpacing: Space between rows
	///   - builder: The row builder block
	@MainActor
	convenience init(
		xPlacement: NSGridCell.Placement = .inherited,
		yPlacement: NSGridCell.Placement = .inherited,
		columnSpacing: CGFloat? = nil,
		rowSpacing: CGFloat? = nil,
		@GridRowBuilder builder: () -> [NSGridView.Row]
	) {
		self.init(
			xPlacement: xPlacement,
			yPlacement: yPlacement,
			columnSpacing: columnSpacing,
			rowSpacing: rowSpacing,
			rows: builder()
		)
	}
}

// MARK: - Columns

@available(macOS 10.12, *)
@MainActor
public extension NSGridView {
	/// The column spacing
	/// - Parameter width: The spacing between columns
	/// - Returns: self
	@discardableResult @inlinable
	func columnSpacing(_ spacing: Double) -> Self {
		self.columnSpacing = spacing
		return self
	}

	/// The column width for a particular column index
	/// - Parameters:
	///   - width: The column width
	///   - column: The column index to apply the width to
	/// - Returns: self
	@discardableResult @inlinable
	func columnWidth(_ width: Double, forColumn column: Int) -> Self {
		self.column(at: column).width = width
		return self
	}

	/// The column width for a particular column index range
	/// - Parameters:
	///   - width: The column width
	///   - columns: The column indexes to apply the width to
	/// - Returns: self
	func columnWidth(_ width: Double, forColumns columns: AUIIndexes) -> Self {
		columns.auiIndexValues.forEach { column in
			self.column(at: column).width = width
		}
		return self
	}

	/// The column alignment for a specific column index
	/// - Parameters:
	///   - alignment: The column alignment
	///   - column: The column index to apply the alignment to
	/// - Returns: self
	@discardableResult @inlinable
	func columnAlignment(_ alignment: NSGridCell.Placement, forColumn column: Int) -> Self {
		self.column(at: column).xPlacement = alignment
		return self
	}

	/// The column alignment for a specific column indexes
	/// - Parameters:
	///   - alignment: The column alignment
	///   - columns: The column indexes to apply the alignment to
	/// - Returns: self
	@discardableResult @inlinable
	func columnAlignment(_ alignment: NSGridCell.Placement, forColumns columns: AUIIndexes) -> Self {
		columns.auiIndexValues.forEach { column in
			self.column(at: column).xPlacement = alignment
		}
		return self
	}
}



// MARK: - Rows

@available(macOS 10.12, *)
@MainActor public extension NSGridView {
	/// An NSGridView row definition
	@MainActor class Row {
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
			self.rowCells = builder()
			self.topPadding = topPadding
			self.bottomPadding = bottomPadding
			self.rowAlignment = rowAlignment
		}

		/// Merge the cell indexes
		/// - Parameter indexes: The indexes to merge
		/// - Returns: self
		public func mergeCells(_ indexes: ClosedRange<Int>) -> Self {
			self.mergedCells.append(indexes)
			return self
		}

		/// Merge the cell indexes
		/// - Parameter indexes: The indexes to merge
		/// - Returns: self
		public func mergeCells(_ indexes: [ClosedRange<Int>]) -> Self {
			self.mergedCells.append(contentsOf: indexes)
			return self
		}

		fileprivate let topPadding: CGFloat
		fileprivate let bottomPadding: CGFloat
		fileprivate let rowAlignment: NSGridRow.Alignment
		fileprivate let rowCells: [NSView]
		fileprivate var mergedCells: [ClosedRange<Int>] = []
	}
}

@available(macOS 10.12, *)
@MainActor
public extension NSGridView {
	@discardableResult @inlinable
	func rowAlignment(_ value: NSGridRow.Alignment) -> Self {
		self.rowAlignment = value
		return self
	}

	/// Set the spacing between rows
	/// - Parameter width: The width between rows
	/// - Returns: self
	@discardableResult @inlinable
	func rowSpacing(_ width: Double) -> Self {
		self.rowSpacing = width
		return self
	}

	/// Set the row placement for a row
	/// - Parameters:
	///   - yPlacement: The y placement value
	///   - row: The row index to apply the y placement to
	/// - Returns: self
	@discardableResult @inlinable
	func rowPlacement(_ yPlacement: NSGridCell.Placement, forRowIndex row: Int) -> Self {
		self.row(at: row).yPlacement = yPlacement
		return self
	}

	/// Set the row placement for a row
	/// - Parameters:
	///   - yPlacement: The y placement value
	///   - rows: The row indexes to apply the y placement to
	/// - Returns: self
	@discardableResult
	func rowPlacement(_ yPlacement: NSGridCell.Placement, forRowIndexes rows: AUIIndexes) -> Self {
		rows.auiIndexValues.forEach {
			self.rowPlacement(yPlacement, forRowIndex: $0)
		}
		return self
	}
}

@available(macOS 10.12, *)
@MainActor
public extension NSGridView {
	/// Merge the specified cell indexes in 'row'
	@discardableResult @inlinable
	func mergeRowCells(_ columnIndexes: ClosedRange<Int>, inRowIndex row: Int) -> Self {
		self.row(at: row).mergeCells(in: NSRange(columnIndexes))
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

// MARK: - Cells

@available(macOS 10.12, *)
@MainActor
public extension NSGridView {
	/// Get the cell and the specified row and column, and perform a block passing the cell
	/// - Parameters:
	///   - col: The column index within the grid
	///   - row: The row index within the grid
	///   - block: The block to call
	/// - Returns: self
	@discardableResult
	func cell(atColumnIndex col: Int, rowIndex row: Int, _ block: (NSGridCell) -> Void) -> Self {
		let cell = self.cell(atColumnIndex: col, rowIndex: row)
		block(cell)
		return self
	}

	/// Set the x placement for the given cell
	/// - Parameters:
	///   - col: The cell's column
	///   - row: The cell's row
	///   - xPlacement: The x placement value
	/// - Returns: self
	@discardableResult @inlinable
	func cell(atColumnIndex col: Int, rowIndex row: Int, xPlacement: NSGridCell.Placement) -> Self {
		self.cell(atColumnIndex: col, rowIndex: row).xPlacement = xPlacement
		return self
	}

	/// Set the y placement for the given cell
	/// - Parameters:
	///   - col: The cell's column
	///   - row: The cell's row
	///   - yPlacement: The y placement value
	/// - Returns: self
	@discardableResult @inlinable
	func cell(atColumnIndex col: Int, rowIndex row: Int, yPlacement: NSGridCell.Placement) -> Self {
		self.cell(atColumnIndex: col, rowIndex: row).yPlacement = yPlacement
		return self
	}
}

// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("default") {
	let firstName = Bind("Caterpillar")
	let lastName = Bind("Jones")

	VStack {

		NSGridView(columnSpacing: 2, rowSpacing: 8) {
			NSGridView.Row {
				NSTextField(labelWithString: "First Name:")
				NSTextField(labelWithString: "*")
					.textColor(.systemRed)
				NSTextField()
					.content(firstName)
					.onChange { newValue in
						Swift.print("Cell -> \(newValue)")
					}
			}
			NSGridView.Row {
				NSTextField(labelWithString: "Last Name:")
				NSTextField(labelWithString: "*")
					.textColor(.systemRed)
				NSTextField()
					.content(lastName)
			}

			NSGridView.Row {
				HDivider()
			}
			.mergeCells(0 ... 2)

			NSGridView.Row {
				NSTextField(labelWithString: "Email Address:")
				NSTextField(labelWithString: "*")
					.textColor(.systemRed)
				NSTextField()
			}
			NSGridView.Row {
				NSTextField(labelWithString: "Phone:")
				NSGridCell.emptyContentView
				NSTextField()
			}
			NSGridView.Row {
				NSTextField(labelWithString: "Fax:")
				NSGridCell.emptyContentView
				NSTextField()
			}

			NSGridView.Row {
				NSTextField(labelWithString: "Sector:")
				NSTextField(labelWithString: "*")
					.textColor(.systemRed)
				NSPopUpButton()
					.menuItems(["Astronomy", "University", "Wombles"])
					.huggingPriority(.init(1), for: .horizontal)
			}

			NSGridView.Row {
				NSGridCell.emptyContentView
				NSTextField(labelWithString: "*")
					.textColor(.systemRed)
				NSTextField(labelWithString: "indicates a required field")
			}

			NSGridView.Row {
				HDivider()
			}
			.mergeCells(0 ... 2)

			NSGridView.Row {
				NSButton.checkbox(title: "All cells merged")
			}
			.mergeCells(0 ... 2)
		}
		.rowAlignment(.firstBaseline)
		.columnAlignment(.trailing, forColumn: 0)
		.columnWidth(200, forColumn: 2)
		.cell(atColumnIndex: 0, rowIndex: 9, xPlacement: .center)
		//.debugFrames()
	}

	.onChange(firstName) { newValue in
		Swift.print(newValue)
	}
}

#endif
