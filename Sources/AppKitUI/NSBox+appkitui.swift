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

import AppKit.NSBox

@MainActor
public extension NSBox {
	convenience init(title: String, _ block: () -> NSView) {
		self.init()
		self.wantsLayer = true
		self.translatesAutoresizingMaskIntoConstraints = false
		self.autoresizesSubviews = true
		self.title = title
		self.titlePosition = .atTop

		let content = block()
		content.translatesAutoresizingMaskIntoConstraints = false
		content.wantsLayer = true
		content.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
		//self.contentViewMargins = NSSize(width: 10, height: 10)

		self.contentView?.addSubview(content)

		if let contentView = self.contentView {
			NSLayoutConstraint.activate([
				content.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
				content.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
				content.topAnchor.constraint(equalTo: contentView.topAnchor),
				content.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
			])
		}
	}

	/// Set the title's position within the box
	/// - Parameter value: The position
	/// - Returns: self
	///
	/// [`titlePosition` discussion](https://developer.apple.com/documentation/appkit/nsbox/titleposition-swift.property)
	@discardableResult @inlinable
	func titlePosition(_ value: NSBox.TitlePosition) -> Self {
		self.titlePosition = value
		return self
	}

	/// Set the font for the title
	/// - Parameter font: The font
	/// - Returns: self
	///
	/// [`titleFont` discussion](https://developer.apple.com/documentation/appkit/nsbox/titlefont)
	@discardableResult @inlinable
	func titleFont(_ font: NSFont) -> Self {
		self.titleFont = font
		return self
	}
}


// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("default") {
	VStack {
		NSBox(title: "Great") {
			NSButton.radioGroup()
				.items(["one", "two", "three"])
		}
		NSBox(title: "This is great and it is longer") {
			NSButton.radioGroup()
				.items(["one", "two", "three"])
				.padding(4)
		}
		.titleFont(.monospaced.italic)
		.debugFrame()
	}
}
#endif
