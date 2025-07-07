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
public func TabView(
	tabType: NSTabView.TabType,
	tabPosition: NSTabView.TabPosition = .top,
	selectedTab: Bind<Int>? = nil,
	@TabBuilder builder: () -> [NSTabView.Tab]
) -> NSTabView {
	let s = NSTabView()
	s.translatesAutoresizingMaskIntoConstraints = false

	s.tabViewType = tabType
	s.tabPosition = tabPosition

	let views = builder()
	views.forEach {
		let item = NSTabViewItem()
		item.label = $0.label
		item.toolTip = $0.toolTip
		item.color = .systemBlue

		let content = $0.contentBuilder()
		content.translatesAutoresizingMaskIntoConstraints = false
		content.needsUpdateConstraints = true

		item.view = content
		s.addTabViewItem(item)
	}

	if let selectedTab {
		s.selectedTab(selectedTab)
	}

	s.usingTabViewStorage { _ in }

	return s
}

// MARK: - Actions

@MainActor
public extension NSTabView {
	/// A block called to determine whether the specified tab can be selected
	/// - Parameter block: The block
	/// - Returns: self
	@discardableResult
	func shouldSelectTab(_ block: @escaping (Int) -> Bool) -> Self {
		self.usingTabViewStorage { $0.shouldSelectTab = block }
		return self
	}
	
	/// Called when the selection changes for a tab view
	/// - Parameter block: The block to call when the selection changes
	/// - Returns: self
	@discardableResult
	func onSelectionChange(_ block: @escaping (Int) -> Void) -> Self {
		self.usingTabViewStorage { $0.onSelectionChange = block }
		return self
	}
}

// MARK: - Bindings

@MainActor
public extension NSTabView {
	@discardableResult
	func selectedTab(_ selected: Bind<Int>) -> Self {
		selected.register(self) { [weak self] newSelection in
			self?.selectTabViewItem(at: newSelection)
		}
		self.usingTabViewStorage { $0.selected = selected }
		self.selectTabViewItem(at: selected.wrappedValue)
		return self
	}
}

// MARK: - Storage

@MainActor
fileprivate extension NSTabView {
	func usingTabViewStorage(_ block: @escaping (Storage) -> Void) {
		self.usingAssociatedValue(key: "__nstabview_bond", initialValue: { Storage(self) }, block)
	}

	@MainActor
	class Storage: NSObject, NSTabViewDelegate {
		weak var parent: NSTabView?
		var selected: Bind<Int>?
		var onSelectionChange: ((Int) -> Void)?
		var shouldSelectTab: ((Int) -> Bool)?

		init(_ parent: NSTabView) {
			self.parent = parent
			super.init()
			parent.delegate = self
		}
	}
}

@MainActor
fileprivate extension NSTabView.Storage {
	func tabView(_ tabView: NSTabView, shouldSelect tabViewItem: NSTabViewItem?) -> Bool {
		if
			let fn = self.shouldSelectTab,
			let parent,
			let tabViewItem
		{
			let index = parent.indexOfTabViewItem(tabViewItem)
			return fn(index)
		}
		return true
	}

	func tabView(_ tabView: NSTabView, willSelect tabViewItem: NSTabViewItem?) {
	}

	func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
		if
			let fn = self.onSelectionChange,
			let parent,
			let tabViewItem
		{
			fn(parent.indexOfTabViewItem(tabViewItem))
		}
	}

}


// MARK: - Tab builder

@MainActor
public extension NSTabView {
	class Tab {
		let label: String
		let toolTip: String?
		let contentBuilder: () -> NSView
		public init(label: String, toolTip: String? = nil, _ builder: @escaping () -> NSView) {
			self.label = label
			self.contentBuilder = builder
			self.toolTip = toolTip
		}
	}
}

@resultBuilder
public enum TabBuilder {
	static func buildBlock() -> [NSTabView.Tab] { [] }
}

public extension TabBuilder {
	static func buildBlock(_ settings: NSTabView.Tab...) -> [NSTabView.Tab] {
		settings
	}

	static func buildBlock(_ settings: [NSTabView.Tab]) -> [NSTabView.Tab] {
		settings
	}

	static func buildOptional(_ component: [NSTabView.Tab]?) -> [NSTabView.Tab] {
		component ?? []
	}

	/// Add support for if statements.
	static func buildEither(first components: [NSTabView.Tab]) -> [NSTabView.Tab] {
		 components
	}

	static func buildEither(second components: [NSTabView.Tab]) -> [NSTabView.Tab] {
		 components
	}

	/// Add support for loops.
	static func buildArray(_ components: [[NSTabView.Tab]]) -> [NSTabView.Tab] {
		 components.flatMap { $0 }
	}
}
