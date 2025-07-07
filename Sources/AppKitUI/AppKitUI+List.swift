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

/// A list generates a table containing a single column

@MainActor
public class List<Item: Equatable>: NSTableView {

	///
	let rowBuilder: (Item) -> NSView

	public init(_ items: Bind<[Item]>, rowBuilder: @escaping (Item) -> NSView) {
		self.rowBuilder = rowBuilder

		super.init(frame: NSRect(x: 0, y: 0, width: 50, height: 1))

		self.translatesAutoresizingMaskIntoConstraints = false
		self.headerView = nil

		let col = NSTableColumn()
		col.identifier = .init("list")
		self.addTableColumn(col)

		items.register(self) { @MainActor [weak self] newItems in
			self?.reloadContent()
		}

		self.usingStorage {
			$0.rowItems = items
			$0.rowBuilder = rowBuilder
		}

		self.reloadContent()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func reloadContent() {
		self.reloadData()
	}
}

// MARK: - Modifiers

@MainActor
public extension List {
	/// Set the background color for the list
	/// - Parameter color: The background color
	/// - Returns: self
	@discardableResult @inlinable
	func backgroundColor(_ color: NSColor) -> Self {
		self.backgroundColor = color
		return self
	}

	/// A Boolean value indicating whether the table view uses alternating row colors for its background.
	/// - Parameter value: If true, alternates the background colors
	/// - Returns: self
	@discardableResult @inlinable
	func usesAlternatingRowBackgroundColors(_ value: Bool) -> Self {
		self.usesAlternatingRowBackgroundColors = value
		return self
	}
}

// MARK: - Binding

@MainActor
public extension List {
	@discardableResult
	func selection(_ selection: Bind<Int>) -> Self {
		selection.register(self) { @MainActor [weak self] newSelection in
			guard let `self` = self else { return }
			if newSelection != self.selectedRow {
				self.selectRow(newSelection)
			}
		}

		let selected = selection.wrappedValue // max(0, min(self.numberOfRows - 1, selection.wrappedValue))
		self.usingStorage { $0.selectedRow = selection }
		self.selectRow(selected)
		return self
	}
}

// MARK: - Storage

private extension List {

	/// Select the row in the UI (don't reflect in bindings)
	func selectRow(_ row: Int) {
		self.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
	}

	func usingStorage(_ block: @escaping (Storage) -> Void) {
		self.usingAssociatedValue(key: "__nstableview_bond", initialValue: { Storage(self) }, block)
	}

	class Storage: NSObject, NSTableViewDelegate, NSTableViewDataSource, @unchecked Sendable {
		weak var control: NSTableView?
		var selectedRow: Bind<Int>?

		var rowItems: Bind<[Item]>?
		var rowBuilder: ((Item) -> NSView)?

		@MainActor init(_ control: NSTableView) {
			self.control = control
			super.init()

			control.dataSource = self
			control.delegate = self
		}

		func numberOfRows(in tableView: NSTableView) -> Int {
			self.rowItems?.wrappedValue.count ?? 0
		}

		func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
			guard
				let rows = self.rowItems,
				let fun = self.rowBuilder
			else {
				return nil
			}
			return fun(rows.wrappedValue[row])
		}

		func tableViewSelectionDidChange(_ notification: Notification) {
			guard let control = self.control else { return }
			self.selectedRow?.wrappedValue = control.selectedRow
		}
	}
}

// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("default") {
	let content = Bind(["zero", "one", "two", "three", "four", "five", "six"])
	let selection = Bind<Int>(2) {
		Swift.print("selection is -> '\($0)'")
	}

	VStack {
		ScrollView(borderType: .noBorder) {
			List(content) { item in
				HStack {
					NSImageView(systemSymbolName: "1.circle")
					NSTextField(label: item)
					NSView.Spacer()
					NSImageView(systemSymbolName: "info.circle")
						.contentTintColor(NSColor.quaternaryLabelColor)
						.toolTip("Line \(item)")

					NSButton()
						.image(NSImage(named: NSImage.infoName))
						.imageScaling(.scaleProportionallyDown)
						.isBordered(false)
						.contentTintColor(.textColor.withAlphaComponent(0.2))

				}
				.padding(0)
			}
			.selection(selection)
			.minWidth(200)
		}
		.debugFrame()

		NSButton { _ in
			content.wrappedValue = content.wrappedValue.reversed()
			selection.wrappedValue = 2
		}
	}
}

#endif
