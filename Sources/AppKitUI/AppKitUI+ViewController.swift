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

/// A view controller that uses AppKitUI for view content
///
/// Override `body` in your class to generate the view controller's view
///
/// Example :-
///
/// ```swift
/// class MyController: AUIViewController {
///    override var body: NSView {
///       VStack {
///          NSTextField(label: "This is a test!")
///       }
///    }
/// }
@MainActor
open class AUIViewController: NSViewController {
	/// Create an AppKitUI-compatible view controller
	public convenience init() {
		self.init(nibName: nil, bundle: nil)
	}

	/// The view body for the view controller.
	///
	/// It is called once during the view loading process.
	open var body: NSView {
		fatalError("Overrriding class must provide body")
	}

	//
	// Private
	//

	final public override func loadView() {
		self.view = self.body
	}
}

// MARK: - Previews

#if DEBUG

class PreviewViewController: AUIViewController {
	let text = Bind("Exciting text field content!")
	override var body: NSView {
		VStack {
			HStack {
				NSTextField(content: text)
					.huggingPriority(.init(10), for: .horizontal)
				NSButton(title: "Reset")
					.onAction { [weak self] _ in
						self?.text.wrappedValue = "I've been reset 😤"
					}
			}
			NSTextField(label: text)
				.huggingPriority(.init(10), for: .horizontal)
				.padding(left: 4)
		}
		.width(250)
	}
}

@available(macOS 14, *)
#Preview("default") {
	PreviewViewController()
}

#endif
