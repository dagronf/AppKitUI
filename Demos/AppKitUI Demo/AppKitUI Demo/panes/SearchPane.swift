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
import AppKitUI

class SearchPane: Pane {
	override func title() -> String { "Search Text" }
	@MainActor
	override func make(model: Model) -> NSView {
		let searchText1 = Bind("")
		let searchText1Submitted = Bind("")

		let searchText2 = Bind("")
		let searchText2Submitted = Bind("")

		let searchOptionsText = Bind("")

		return ScrollView {
			VStack(alignment: .leading, spacing: 16) {
				NSBox(title: "Basic search") {
					VStack(alignment: .leading) {
						NSSearchField()
							.content(searchText1)
							.placeholder("Enter some text here")
							.onSearch { text in
								model.log("Basic search (onSearch): \(text)")
								searchText1Submitted.wrappedValue = text
							}
						HStack {
							NSTextField(label: "Search text:")
							NSTextField()
								.content(searchText1)
						}
					}
					.padding(2)
				}
				.huggingPriority(.init(10), for: .horizontal)

				NSBox(title: "Basic search with recents") {
					VStack(alignment: .leading) {
						NSSearchField()
							.content(searchText2)
							.sendsSearchStringImmediately(false)
							.sendsWholeSearchString(true)
							.placeholder("Basic search with recents")
							.showRecents(autosaveName: "recents search")
							.onSearch { text in
								model.log("Search text (onSubmit): \(text)")
								searchText2Submitted.wrappedValue = text
							}
						HStack {
							NSTextField(label: "Search text:")
								.compressionResistancePriority(.defaultLow, for: .horizontal)
							NSTextField()
								.identifier("id1")
								.content(searchText2)
								.minWidth(50)
							NSTextField(label: "Last submitted:")
								.compressionResistancePriority(.defaultLow, for: .horizontal)
							NSTextField()
								.identifier("id2")
								.content(searchText2Submitted)
								.minWidth(50)
						}
						.equalWidths(["id1", "id2"])
					}
					.padding(2)
				}
				.huggingPriority(.init(10), for: .horizontal)

				NSBox(title: "Other styling options") {
					VStack(alignment: .leading, spacing: 2) {
						HStack {
							NSSearchField()
								.bezelStyle(.squareBezel)
								.font(.monospaced.size(24))
								.onSearch { newSearchText in
									searchOptionsText.wrappedValue = newSearchText
								}
							VStack(alignment: .leading, spacing: 0) {
								NSTextField(label: "onSearch returns:")
									.font(.caption1)
								NSTextField(label: searchOptionsText)
									.textColor(.secondaryLabelColor)
							}
							.padding(2)
							.backgroundBorder(.tertiaryLabelColor, lineWidth: 0.5)
							.backgroundCornerRadius(2)
							.width(200)
						}
					}
					.padding(2)
				}
				.huggingPriority(.init(10), for: .horizontal)
			}
			.padding()
		}
	}
}

#if DEBUG
@available(macOS 14, *)
#Preview("Basic") {
	SearchPane().make(model: Model())
		.width(600)
}
#endif
