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

/// A view which allows the user to quickly switch the visibility between one of its child views
///
/// Very similar to a tab view but with a lot less functionality and overhead
@MainActor
public class AUIViewSwitcher: NSView {
	/// Create a view switcher
	/// - Parameters:
	///   - selectedViewIndex: A binding to the currently visible child view
	///   - builder: The builder for the child views
	public init(selectedViewIndex: Bind<Int>, @NSViewsBuilder builder: () -> [NSView]) {
		self.childViews = builder()

		super.init(frame: .zero)
		self.translatesAutoresizingMaskIntoConstraints = false

		self.setContentHuggingPriority(.defaultLow, for: .horizontal)
		self.setContentHuggingPriority(.defaultLow, for: .vertical)

		self.childViews.translatesAutoresizingMaskIntoConstraints(false)

		selectedViewIndex.register(self) { @MainActor [weak self] newSelection in
			self?.reflectView(newSelection)
		}

		self.reflectView(selectedViewIndex.wrappedValue)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	/// Get an array of all subviews for this view
	override func allSubviews() -> [NSView] {
		var items: [NSView] = [self]
		for subview in self.childViews {
			items.append(contentsOf: subview.allSubviews())
		}
		return items
	}

	/// Switch to a new child view
	private func reflectView(_ index: Int) {
		guard index < self.childViews.count else { return }
		let view = self.childViews[index]
		self.content(fill: view)
	}

	// The available child views to be switched between
	private let childViews: [NSView]
}

// MARK: - Previews

#if DEBUG

import SwiftUI

@available(macOS 14, *)
#Preview("default") {
	let items = Bind(["Internet", "Phone", "Email"])
	let selectedItem = Bind(0)
	let content = Bind("Text content")

	VStack(spacing: 20) {
		NSGridView {
			NSGridView.Row {
				NSTextField(label: "Activate via:")
				NSPopUpButton()
					.menuItems(items)
					.selectedIndex(selectedItem)

				AUIViewSwitcher(selectedViewIndex: selectedItem) {
					NSTextField(label: "To automatically activate NVivo via the Internet, enter your details below and click 'Activate'")
						.compressionResistancePriority(.defaultLow, for: .horizontal)
					NSTextField(label: "Call 03-5555-5555 and speak with a friendly operator")
						.huggingPriority(.defaultLow, for: .horizontal)
						.compressionResistancePriority(.defaultLow, for: .horizontal)
					HStack {
						NSTextField(label: "Automatically format an email to send to email@email.com")
							.compressionResistancePriority(.defaultLow, for: .horizontal)
						NSButton(title: "Generate Email")
							.bezelStyle(.badge)
					}
				}
				.huggingPriority(.defaultLow, for: .horizontal)
			}
		}
		.columnSpacing(12)
		.rowPlacement(.center, forRowIndex: 0)
		.padding(8)
	}
	.debugFrames()
}

#endif
