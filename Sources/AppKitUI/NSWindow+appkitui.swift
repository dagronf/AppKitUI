//
//  Copyright © 2026 Darren Ford. All rights reserved.
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
public class AUIWindow: WindowedContentProtocol {

	public enum ToolbarStyle: Int {
		case automatic = 0
		case expanded = 1
		case preference = 2
		case unified = 3
		case unifiedCompact = 4

		@available(macOS 11.0, *)
		func core() -> NSWindow.ToolbarStyle {
			NSWindow.ToolbarStyle(rawValue: self.rawValue) ?? NSWindow.ToolbarStyle.automatic
		}
	}

	public init(
		isVisible: Bind<Bool>,
		frameAutosaveName: String? = nil,
		_ contentBuilder: (() -> NSView)? = nil
	) {
		self.isVisible = isVisible
		if let contentBuilder {
			self.contentBuilder = contentBuilder
		}
		self.frameAutosaveName = frameAutosaveName
		isVisible.register(self) { @MainActor [weak self] newState in
			self?.reflectVisibility(newState)
		}

		let isv = isVisible.wrappedValue
//		DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
		DispatchQueue.main.async { [weak self] in
			self?.reflectVisibility(isv)
		}
	}

	@discardableResult
	public func title(_ value: String) -> Self {
		self.setTitle(value)
		return self
	}

	@discardableResult
	public func styleMask(_ value: NSWindow.StyleMask) -> Self {
		self.styleMask = value
		self.window?.styleMask = value
		return self
	}

	@discardableResult
	public func initialRect(_ value: NSRect) -> Self {
		self.initialRect = value
		return self
	}

	@discardableResult
	public func isMovableByWindowBackground(_ value: Bool) -> Self {
		self.isMovableByWindowBackground = value
		self.window?.isMovableByWindowBackground = value
		return self
	}

	@discardableResult
	public func content(_ contentBuilder: @escaping () -> NSView) -> Self {
		self.contentBuilder = contentBuilder
		return self
	}

	/// Set the frame autosave name (useful to automatically set the size)
	/// - Parameter value: The frame autosave name
	/// - Returns: self
	@discardableResult
	public func frameAutosaveName(_ value: String) -> Self {
		self.frameAutosaveName = value
		return self
	}

	/// Set the style for the toolbar
	@discardableResult
	public func toolbarStyle(_ style: AUIWindow.ToolbarStyle) -> Self {
		self.toolbarStyle = style
		if #available(macOS 11.0, *) {
			self.window?.toolbarStyle = style.core()
		}
		return self
	}

	/// A block to call when the window opens
	/// - Parameter block: The block to call
	/// - Returns: self
	@discardableResult
	public func onOpen(_ block: @escaping () -> Void) -> Self {
		self.windowDidShowBlock = block
		return self
	}

	/// A block to call when the window closes
	/// - Parameter block: The block to call
	/// - Returns: self
	@discardableResult
	public func onClose(_ block: @escaping () -> Void) -> Self {
		self.windowDidCloseBlock = block
		return self
	}

	deinit {
		os_log("deinit: AUIWindow", log: logger, type: .debug)
	}

	// private
	private let isVisible: Bind<Bool>

	private var title: String?
	private var isClosing: Bool = false
	private var isMovableByWindowBackground: Bool = false
	private var initialRect: NSRect = NSRect(x: 100, y: 100, width: 300, height: 300)
	private var contentBuilder: (() -> NSView) = { NSView().translatesAutoresizingMaskIntoConstraints(false) }
	private var window: NSWindow?
	private var styleMask: NSWindow.StyleMask = [.titled, .closable, .miniaturizable, .resizable]
	private var closeNotifications: NSObjectProtocol?

	private var frameAutosaveName: String?

	private var toolbarStyle: AUIWindow.ToolbarStyle = .automatic

	private var windowDidCloseBlock: (() -> Void)?
	private var windowDidShowBlock: (() -> Void)?
}

@MainActor
public extension AUIWindow {
	private func setTitle(_ value: String) {
		self.title = value
		self.window?.title = value
	}

	@discardableResult
	func title(_ value: Bind<String>) -> Self {
		value.register(self) { @MainActor [weak self] newTitle in
			self?.setTitle(newTitle)
		}
		self.setTitle(value.wrappedValue)
		return self
	}
}

@MainActor
extension AUIWindow {

	// During close, make sure we remove our associated window object
	func willCloseWindowedContent() {
		self.closeWindow()
	}

	func reflectVisibility(_ show: Bool) {
		show ? self.showWindow() : self.closeWindow()
	}

	func showWindow() {
		guard self.window == nil else { return }

		let w = NSWindow(
			contentRect: self.initialRect,
			styleMask: self.styleMask,
			backing: .buffered,
			defer: true
		)

		if let title = self.title {
			w.title = title
		}

		w.isReleasedWhenClosed = false
		w.autorecalculatesKeyViewLoop = true
		w.isMovableByWindowBackground = self.isMovableByWindowBackground

		self.window = w

		w.makeKeyAndOrderFront(self)
		w.contentView = self.contentBuilder()

		if let name = self.frameAutosaveName {
			w.setFrameUsingName(name)
			w.setFrameAutosaveName(name)
		}

		if #available(macOS 11, *) {
			w.toolbarStyle = self.toolbarStyle.core()
		}

		w.recalculateKeyViewLoop()

		self.windowDidShowBlock?()

		// Listen for close events
		self.closeNotifications = NotificationCenter.default.addObserver(
			forName: NSWindow.willCloseNotification,
			object: w,
			queue: .main
		) { @MainActor [weak self] _ in
			guard let `self` = self else { return }
			if self.isClosing == false {
				self.closeWindow()
			}
		}
	}

	func closeWindow() {
		if let f = self.frameAutosaveName, let w = self.window {
			w.saveFrame(usingName: f)
		}

		self.closeNotifications = nil
		self.isClosing = true
		if let w = self.window {
			w.orderOut(nil)
			w.performClose(self)
			self.window = nil
			self.windowDidCloseBlock?()
		}
		self.isClosing = false
		self.isVisible.wrappedValue = false
	}
}

public extension NSView {
	/// Attach the supplied window to this view
	@discardableResult
	func window(_ window: AUIWindow) -> Self {
		self.usingViewStorage { $0.addWindowedContent(window) }
		return self
	}
}

// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("default") {
	let isWindowVisible = Bind(false)
	let tempWindow = AUIWindow(isVisible: isWindowVisible)
		.content {
			NSTextField(label: "which and what")
		}

	VStack {
		NSButton(title: "which") { newState in
			let isv = newState == .on
			Swift.print("button pressed: \(isv)")
			isWindowVisible.wrappedValue = isv
		}
		.window(tempWindow)
	}
	.padding()
}

#endif
