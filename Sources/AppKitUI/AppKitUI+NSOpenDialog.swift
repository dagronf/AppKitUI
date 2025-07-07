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
import UniformTypeIdentifiers

protocol FileTypeIdentifier { }
extension String: FileTypeIdentifier { }
@available(macOS 11.0, *)
extension UTType: FileTypeIdentifier { }

@available(macOS 11.0, *)
@MainActor
public extension NSView {
	/// Display an open panel and allow the user to select files
	/// - Parameters:
	///   - isVisible: The binding for the visibility of the panel
	///   - allowedContentTypes: The allowed content types for the open dialog
	///   - allowsMultiple: Does the panel allow selecting multiple files?
	///   - message: The prompt to display in the panel
	///   - openButtonTitle: The title for the open button in the panel
	///   - accessoryViewBuilder:
	///   - onSelectFiles: The method to call when the user selects files
	/// - Returns: self
	@discardableResult
	func fileImporter(
		isVisible: Bind<Bool>,
		allowedContentTypes: [UTType],
		allowsMultiple: Bool,
		message: String? = nil,
		openButtonTitle: String? = nil,
		accessoryViewBuilder: (() -> NSView)? = nil,
		onSelectFiles: @escaping ([URL]) -> Void
	) -> Self {
		let panelInstance = OpenPanelInstance(
			parent: self,
			isVisible: isVisible,
			allowedContentTypes: allowedContentTypes,
			allowsMultiple: allowsMultiple,
			message: message,
			openButtonTitle: openButtonTitle,
			accessoryViewBuilder: accessoryViewBuilder,
			onSelectFiles: onSelectFiles
		)
		self.usingViewStorage { $0.addWindowedContent(panelInstance) }
		return self
	}
}

@available(macOS, deprecated: 12.0, message: "Use -allowedContentTypes instead")
@MainActor
public extension NSView {
	/// Display an open panel and allow the user to select files
	/// - Parameters:
	///   - isVisible: The binding for the visibility of the panel
	///   - allowedFileTypes: The allowed file types for the open dialog
	///   - allowsMultiple: Does the panel allow selecting multiple files?
	///   - message: The prompt to display in the panel
	///   - openButtonTitle: The title for the open button in the panel
	///   - accessoryViewBuilder:
	///   - onSelectFiles: The method to call when the user selects files
	/// - Returns: self
	@discardableResult
	func fileImporter(
		isVisible: Bind<Bool>,
		allowedFileTypes: [String],
		allowsMultiple: Bool,
		message: String? = nil,
		openButtonTitle: String? = nil,
		accessoryViewBuilder: (() -> NSView)? = nil,
		onSelectFiles: @escaping ([URL]) -> Void
	) -> Self {
		let panelInstance = OpenPanelInstance(
			parent: self,
			isVisible: isVisible,
			allowedContentTypes: allowedFileTypes,
			allowsMultiple: allowsMultiple,
			message: message,
			openButtonTitle: openButtonTitle,
			accessoryViewBuilder: accessoryViewBuilder,
			onSelectFiles: onSelectFiles
		)
		self.usingViewStorage { $0.addWindowedContent(panelInstance) }
		return self
	}
}

// MARK: - Private instance

@MainActor
private class OpenPanelInstance: WindowedContentProtocol {
	weak var parent: NSView?
	let isVisible: Bind<Bool>
	let allowedContentTypes: [FileTypeIdentifier]
	let allowsMultiple: Bool
	let message: String?
	let openButtonTitle: String?
	let accessoryViewBuilder: (() -> NSView)?
	let onSelectFiles: ([URL]) -> Void

	private var currentPanel: NSOpenPanel?

	init(
		parent: NSView,
		isVisible: Bind<Bool>,
		allowedContentTypes: [FileTypeIdentifier],
		allowsMultiple: Bool,
		message: String?,
		openButtonTitle: String?,
		accessoryViewBuilder: (() -> NSView)? = nil,
		onSelectFiles: @escaping ([URL]) -> Void
	) {
		self.parent = parent
		self.allowedContentTypes = allowedContentTypes
		self.allowsMultiple = allowsMultiple
		self.message = message
		self.isVisible = isVisible
		self.openButtonTitle = openButtonTitle
		self.onSelectFiles = onSelectFiles
		self.accessoryViewBuilder = accessoryViewBuilder

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
		Swift.print("deinit: OpenPanelInstance")
	}

	@MainActor
	private func presentSheet() {
		guard
			self.currentPanel == nil,
			let parent = self.parent,
			let containingWindow = parent.window
		else {
			return
		}

		let openPanel = NSOpenPanel()
		self.currentPanel = openPanel

		if #available(macOS 11.0, *) {
			let uttypes = self.allowedContentTypes.compactMap { $0 as? UTType }
			if uttypes.count > 0 {
				openPanel.allowedContentTypes = uttypes
			}
		}

		let strs = self.allowedContentTypes.compactMap { $0 as? String }
		if strs.count > 0 {
			openPanel.allowedFileTypes = strs
		}

		openPanel.allowsMultipleSelection = self.allowsMultiple
		openPanel.message = self.message
		openPanel.prompt = self.openButtonTitle

		if let fn = self.accessoryViewBuilder {
			openPanel.accessoryView = fn()
		}

		openPanel.beginSheetModal(for: containingWindow) { [weak self, weak openPanel] response in
			DispatchQueue.main.async {
				if let `self` = self,
					let urls = openPanel?.urls
				{
					self.didChooseFiles(response, urls: urls)
					self.dismissSheet()
				}
			}
		}
	}

	private func didChooseFiles(_ response: NSApplication.ModalResponse, urls: [URL]) {
		if response == .OK {
			self.onSelectFiles(urls)
		}
		self.isVisible.wrappedValue = false
	}

	@MainActor
	private func dismissSheet() {
		if let panel = self.currentPanel {
			panel.close()
		}
		self.currentPanel = nil
	}
}

// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("Select one image") {
	let showOpenPanel = Bind(false)
	let showOpenPanel2 = Bind(false)
	let selectedFiles = Bind<[URL]>([])

	VStack {
		HStack {
			NSButton(title: "Select One Image File...") { _ in
				showOpenPanel.wrappedValue = true
			}
			.fileImporter(
				isVisible: showOpenPanel,
				allowedContentTypes: [.jpeg],
				//allowedFileTypes: ["public.jpeg"],  // backwards compatible < 11
				allowsMultiple: false,
				message: "Message",
				openButtonTitle: "prompt"
			) { selected in
				selectedFiles.wrappedValue = selected
			}

			NSButton(title: "Select Multiple Image Files...") { _ in
				showOpenPanel2.wrappedValue = true
			}
			.fileImporter(
				isVisible: showOpenPanel2,
				allowedContentTypes: [.image],
				allowsMultiple: true,
				message: "Select multiple images",
			) { selected in
				selectedFiles.wrappedValue = selected
			}
		}

		ScrollView {
			List(selectedFiles) { item in
				NSPathControl(fileURL: item)
					.huggingPriority(.defaultLow, for: .horizontal)
			}
			.usesAlternatingRowBackgroundColors(true)
		}
		.minWidth(500)
		.minHeight(100)
	}
	.padding(top: 40, left: 20, bottom: 20, right: 20)
}

#endif

