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
import os.log

@MainActor
public extension NSView {
	/// Attach a sheet to this view
	/// - Parameters:
	///   - isVisible: A ValueBinder to indicate whether the sheet is visible or not
	///   - frameAutosaveName: The name for window sizing
	///   - contentBuilder: A builder for creating the sheet content
	/// - Returns: self
	func sheet(
		isVisible: Bind<Bool>,
		frameAutosaveName: NSWindow.FrameAutosaveName? = nil,
		contentBuilder: @escaping () -> NSView
	) -> Self {
		let sheetInstance = SheetInstance(
			parent: self,
			frameAutosaveName: frameAutosaveName,
			contentBuilder: contentBuilder,
			isVisible: isVisible
		)
		self.usingViewStorage { $0.addWindowedContent(sheetInstance) }
		return self
	}
}

@MainActor
internal class SheetInstance: WindowedContentProtocol {
	init(
		parent: NSView,
		frameAutosaveName: NSWindow.FrameAutosaveName?,
		contentBuilder: @escaping () -> NSView,
		isVisible: Bind<Bool>
	) {
		self.parent = parent
		self.contentBuilder = contentBuilder
		self.isVisible = isVisible
		self.frameAutosaveName = frameAutosaveName

		isVisible.register(self) { @MainActor [weak self] state in
			guard let `self` = self else { return }
			if state == true {
				self.presentSheet()
			}
			else {
				self.dismissSheet()
			}
		}
	}

	deinit {
		os_log("deinit: SheetInstance", log: logger, type: .debug)
	}

	weak var parent: NSView?

	var frameAutosaveName: NSWindow.FrameAutosaveName?

	// The current sheet
	var currentSheet: NSWindow?
	// The function to use when building the alert for display
	var contentBuilder: (() -> NSView)?
	let isVisible: Bind<Bool>
}

@MainActor
private extension SheetInstance {
	func presentSheet() {
		guard
			self.currentSheet == nil,
			let parentWindow = self.parent?.window,
			let contentBuilder = self.contentBuilder
		else {
			return
		}

		// Create the sheet's content
		let content = contentBuilder()

		// Create the window
		let window = KeyableWindow(contentRect: .zero, styleMask: [.resizable], backing: .buffered, defer: true)

		window.title = "sheet"
		window.isReleasedWhenClosed = true
		window.isMovableByWindowBackground = false
		window.autorecalculatesKeyViewLoop = true
		if let frameAutosaveName {
			window.setFrameAutosaveName(frameAutosaveName)
		}
		//window.delegate = self

		window.contentView = content
		window.recalculateKeyViewLoop()

		self.currentSheet = window

		parentWindow.beginSheet(window)
	}

	func dismissSheet() {
		guard
			let currentSheet = self.currentSheet,
			let parentWindow = self.parent?.window
		else {
			return
		}
		parentWindow.endSheet(currentSheet)
		self.currentSheet = nil
	}
}
