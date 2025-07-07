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

protocol WindowedContentProtocol {

}

@MainActor
public extension NSView {
	/// Attach an alert to this element
	/// - Parameters:
	///   - isVisible: A ValueBinder to indicate whether the sheet is visible or not
	///   - alertBuilder: A block that builds the NSAlert instance when it is to be presented on screen
	///   - builder: A builder for creating the sheet content
	/// - Returns: self
	func alert(
		isVisible: Bind<Bool>,
		alertBuilder: @escaping () -> NSAlert,
		onDismissed: @escaping (NSApplication.ModalResponse) -> Void
	) -> Self {
		let alertInstance = AlertInstance(
			parent: self,
			alertBuilder: alertBuilder,
			isVisible: isVisible,
			onDismissed: onDismissed
		)
		self.usingViewStorage { $0.addWindowedContent(alertInstance) }
		return self
	}

	/// Attach an alert to this element
	/// - Parameters:
	///   - isVisible: A ValueBinder to indicate whether the sheet is visible or not
	///   - alert: The alert to display
	///   - builder: A builder for creating the sheet content
	/// - Returns: self
	func alert(
		isVisible: Bind<Bool>,
		alert: NSAlert,
		onDismissed: @escaping (NSApplication.ModalResponse) -> Void
	) -> Self {
		let alertInstance = AlertInstance(
			parent: self,
			alert: alert,
			isVisible: isVisible,
			onDismissed: onDismissed
		)
		self.usingViewStorage { $0.addWindowedContent(alertInstance) }
		return self
	}
}

@MainActor
internal class AlertInstance: WindowedContentProtocol {
	init(
		parent: NSView,
		alertBuilder: @escaping () -> NSAlert,
		isVisible: Bind<Bool>,
		onDismissed: @escaping (NSApplication.ModalResponse) -> Void
	) {
		self.parent = parent
		self.alertBuilder = alertBuilder
		self.isVisible = isVisible
		self.onDismissBlock = onDismissed

		isVisible.register(self) { @MainActor [weak self] state in
			guard let `self` = self else { return }
			if state == true {
				self.presentAlert()
			}
			else {
				self.dismissAlert()
			}
		}
	}

	init(
		parent: NSView,
		alert: NSAlert,
		isVisible: Bind<Bool>,
		onDismissed: @escaping (NSApplication.ModalResponse) -> Void
	) {
		self.parent = parent
		self.alert = alert
		self.isVisible = isVisible
		self.onDismissBlock = onDismissed

		isVisible.register(self) { @MainActor [weak self] state in
			guard let `self` = self else { return }
			if state == true {
				self.presentAlert()
			}
			else {
				self.dismissAlert()
			}
		}
	}

	deinit {
		Swift.print("deinit: AlertInstance")
		self.currentAlert = nil
	}

	weak var parent: NSView?

	// The current NSAlert instance, or `nil` if no alert is presented
	var currentAlert: NSAlert?
	// The function to use when building the alert for display
	var alertBuilder: (() -> NSAlert)?
	var alert: NSAlert?
	let isVisible: Bind<Bool>
	let onDismissBlock: (NSApplication.ModalResponse) -> Void
}

@MainActor
private extension AlertInstance {
	func presentAlert() {
		guard
			self.currentAlert == nil,
			let parentWindow = self.parent?.window
		else {
			return
		}

		// Create the alert. Use the builder, otherwise use the provided alert, else do nothing
		guard let alert = self.alertBuilder?() ?? self.alert else {
			return
		}
		self.currentAlert = alert

		alert.usingStorage {
			if let accessory = $0.accessoryViewBuilder {
				let view = accessory()
				view.translatesAutoresizingMaskIntoConstraints = false

				// It appears that the accessoryView doesn't support autolayout.
				// Wrap the content in a fixed size, non-autolayout container representing the
				// fitting size for the content.
				let container = NSView()
				container.translatesAutoresizingMaskIntoConstraints = true
				container.setFrameSize(view.fittingSize)
				view.pin(inside: container)

				alert.accessoryView = container
			}
		}

		alert.beginSheetModal(for: parentWindow) { [weak self] modalResponse in
			// The callback is not guaranteed to be called on the main actor, so fire off a
			// response on the main actor
			DispatchQueue.main.async {
				self?.presentAlertResponse(modalResponse)
			}
		}
	}


	/// Called when the alert is dismissed
	/// - Parameter response: The alert response
	func presentAlertResponse(_ response: NSApplication.ModalResponse) {
		assert(Thread.isMainThread)
		self.isVisible.wrappedValue = false
		self.onDismissBlock(response)
		self.dismissAlert()
	}

	func dismissAlert() {
		guard
			let currentAlert = self.currentAlert,
			let parentWindow = self.parent?.window
		else {
			return
		}
		parentWindow.endSheet(currentAlert.window)
		self.currentAlert = nil
	}
}
