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
	///   - title: The title to use if the popover is detached into its own window
	///   - isVisible: A ValueBinder to indicate whether the sheet is visible or not
	///   - preferredEdge: The edge of this view the popover should prefer to be anchored to.
	///   - behaviour: The behavior of the popover.
	///   - contentBuilder: A builder for creating the sheet content
	/// - Returns: self
	func popover(
		title: String? = nil,
		isVisible: Bind<Bool>,
		preferredEdge: NSRectEdge,
		behaviour: NSPopover.Behavior = .transient,
		contentBuilder: @escaping () -> NSView
	) -> Self {
		let popoverInstance = PopoverInstance(
			parent: self,
			title: title,
			isVisible: isVisible,
			preferredEdge: preferredEdge,
			behaviour: behaviour,
			contentBuilder: contentBuilder
		)
		self.usingViewStorage { $0.addWindowedContent(popoverInstance) }
		return self
	}
}

@MainActor
internal class PopoverInstance: NSObject, WindowedContentProtocol, NSPopoverDelegate {
	init(
		parent: NSView,
		title: String?,
		isVisible: Bind<Bool>,
		preferredEdge: NSRectEdge,
		behaviour: NSPopover.Behavior,
		contentBuilder: @escaping () -> NSView
	) {
		self.parent = parent
		self.title = title

		self.contentBuilder = contentBuilder
		self.isVisible = isVisible

		self.preferredEdge = preferredEdge
		self.behaviour = behaviour

		super.init()

		isVisible.register(self) { @MainActor [weak self] state in
			guard
				let `self` = self,
				self.isVisible.wrappedValue == state
			else {
				return
			}

			if state == true {
				self.presentPopover()
			}
			else {
				self.dismissPopover()
			}
		}
	}

	func popoverWillClose(_ notification: Notification) {
		self.dismissPopover()
	}

	func popoverShouldDetach(_ popover: NSPopover) -> Bool {
		false
	}

	func detachableWindow(for popover: NSPopover) -> NSWindow? {

		guard let content = self.contentBuilder?() else {
			return nil
		}
		let vc = NSViewController(nibName: nil, bundle: nil)
		vc.view = content

		// Create the window
		let window = KeyableWindow(
			contentRect: .zero,
			styleMask: [.titled, .closable, .miniaturizable, .resizable],
			backing: .buffered,
			defer: true
		)

		window.contentViewController = vc
		if let title = self.title {
			window.title = title
		}
		window.isReleasedWhenClosed = true
		window.isMovableByWindowBackground = false
		window.autorecalculatesKeyViewLoop = true
		window.recalculateKeyViewLoop()

		return window
	}

	deinit {
		os_log("deinit: SheetInstance", log: logger, type: .debug)
	}

	weak var parent: NSView?

	private var title: String?
	private var currentPopover: NSPopover?
	private var contentBuilder: (() -> NSView)?
	private let isVisible: Bind<Bool>
	private var preferredEdge: NSRectEdge
	private var behaviour: NSPopover.Behavior
}

@MainActor
private extension PopoverInstance {
	func presentPopover() {
		guard
			self.currentPopover == nil,
			let parent = self.parent,
			let contentBuilder = self.contentBuilder
		else {
			return
		}

		// Create the popover's content
		let content = contentBuilder()

		let vc = NSViewController(nibName: nil, bundle: nil)
		vc.view = content

		let popover = NSPopover()
		self.currentPopover = popover
		popover.behavior = self.behaviour
		popover.contentViewController = vc

		popover.delegate = self

		popover.show(relativeTo: parent.bounds, of: parent, preferredEdge: preferredEdge)
	}

	func dismissPopover() {
		self.isVisible.wrappedValue = false
		guard let currentPopver = self.currentPopover else { return }
		currentPopver.close()
		self.currentPopover = nil
	}
}

#if DEBUG

@available(macOS 14, *)
#Preview("default") {
	let value = Bind(0.2) { newValue in
		Swift.print(newValue)
	}
	let isVisible = Bind(false) { newValue in
		Swift.print(newValue)
	}

	NSButton(title: "Display a popover") { _ in
		isVisible.wrappedValue = true
	}
	.popover(title: "Wheee!", isVisible: isVisible, preferredEdge: .maxY, behaviour: .semitransient) {
		Popover1(isVisible: isVisible, progressValue: value).body
	}
}

@MainActor
struct Popover1: AUIViewBodyGenerator {
	let isVisible: Bind<Bool>
	let progressValue: Bind<Double>

	var body: NSView {
		NSView(layoutStyle: .fill) {
			VStack {
				HStack {
					//NSImageView(systemSymbolName: "tortoise")
					NSImageView(image: NSImage(named: "NSTouchBarVolumeDownTemplate")!)
					NSSlider(progressValue, range: 0 ... 1)
						.width(200)
					//NSImageView(systemSymbolName: "hare")
					NSImageView(image: NSImage(named: "NSTouchBarVolumeUpTemplate")!)
				}
				NSButton(title: "Close") { _ in
					isVisible.wrappedValue = false
				}
			}
		}
		.padding()
	}
}

#endif
