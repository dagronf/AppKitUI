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

@available(macOS 11.0, *)
@MainActor
public extension NSView {
	/// Display a file save sheet
	/// - Parameters:
	///   - isVisible: A flag to make the panel visible
	///   - allowedContentTypes: The available uttypes to save
	///   - message: The message text displayed in the panel.
	///   - prompt: The text to display in the default button.
	///   - canCreateDirectories: A Boolean value that indicates whether the panel displays UI for creating directories.
	///   - isExtensionHidden: A Boolean value that indicates whether to display filename extensions.
	///   - showsHiddenFiles: A Boolean value that indicates whether to display filename extensions.
	///   - directoryURL: The current directory shown in the panel.
	///   - accessoryViewBuilder: The builder to generate the accessory view for the panel
	///   - onSelectFile: Called when the user selects a file
	/// - Returns: self
	@discardableResult
	func fileExporter(
		isVisible: Bind<Bool>,
		allowedContentTypes: [UTType],
		message: String? = nil,
		prompt: String? = nil,
		canCreateDirectories: Bool? = nil,
		isExtensionHidden: Bool? = nil,
		showsHiddenFiles: Bool? = nil,
		directoryURL: URL? = nil,
		accessoryViewBuilder: (() -> NSView)? = nil,
		onSelectFile: @escaping (URL) -> Void
	) -> Self {
		let panelInstance = SavePanelInstance(
			parent: self,
			isVisible: isVisible,
			message: message,
			prompt: prompt,
			allowedContentTypes: allowedContentTypes,
			canCreateDirectories: canCreateDirectories,
			isExtensionHidden: isExtensionHidden,
			showsHiddenFiles: showsHiddenFiles,
			directoryURL: directoryURL,
			accessoryViewBuilder: accessoryViewBuilder,
			onSelectFile: onSelectFile
		)
		self.usingViewStorage { $0.addWindowedContent(panelInstance) }
		return self
	}
}

@available(macOS, deprecated: 12.0, message: "Use -allowedContentTypes instead")
@MainActor
public extension NSView {
	/// Display a file save sheet
	/// - Parameters:
	///   - isVisible: A flag to make the panel visible
	///   - allowedFileTypes: An array of filename extensions or UTIs that represent the allowed file types for the panel.
	///   - message: The message text displayed in the panel.
	///   - prompt: The text to display in the default button.
	///   - canCreateDirectories: A Boolean value that indicates whether the panel displays UI for creating directories.
	///   - isExtensionHidden: A Boolean value that indicates whether to display filename extensions.
	///   - showsHiddenFiles: A Boolean value that indicates whether to display filename extensions.
	///   - directoryURL: The current directory shown in the panel.
	///   - accessoryViewBuilder: The builder to generate the accessory view for the panel
	///   - onSelectFile: Called when the user selects a file
	/// - Returns: self
	@discardableResult
	func fileExporter(
		isVisible: Bind<Bool>,
		allowedFileTypes: [String],
		message: String? = nil,
		prompt: String? = nil,
		canCreateDirectories: Bool? = nil,
		isExtensionHidden: Bool? = nil,
		showsHiddenFiles: Bool? = nil,
		directoryURL: URL? = nil,
		accessoryViewBuilder: (() -> NSView)? = nil,
		onSelectFile: @escaping (URL) -> Void
	) -> Self {
		let panelInstance = SavePanelInstance(
			parent: self,
			isVisible: isVisible,
			message: message,
			prompt: prompt,
			allowedContentTypes: allowedFileTypes,
			canCreateDirectories: canCreateDirectories,
			isExtensionHidden: isExtensionHidden,
			showsHiddenFiles: showsHiddenFiles,
			directoryURL: directoryURL,
			accessoryViewBuilder: accessoryViewBuilder,
			onSelectFile: onSelectFile
		)
		self.usingViewStorage { $0.addWindowedContent(panelInstance) }
		return self
	}
}

// MARK: - Private instance

@MainActor
private class SavePanelInstance: WindowedContentProtocol {
	weak var parent: NSView?
	let isVisible: Bind<Bool>
	let allowedContentTypes: [FileTypeIdentifier]
	let isExtensionHidden: Bool?
	let canCreateDirectories: Bool?
	let showsHiddenFiles: Bool?
	let message: String?
	let accessoryViewBuilder: (() -> NSView)?
	let onSelectFile: (URL) -> Void
	let directoryURL: URL?
	let prompt: String?

	private var currentPanel: NSSavePanel?

	init(
		parent: NSView,
		isVisible: Bind<Bool>,
		message: String?,
		prompt: String?,
		allowedContentTypes: [FileTypeIdentifier],
		canCreateDirectories: Bool?,
		isExtensionHidden: Bool?,
		showsHiddenFiles: Bool?,
		directoryURL: URL?,
		accessoryViewBuilder: (() -> NSView)? = nil,
		onSelectFile: @escaping (URL) -> Void
	) {
		self.parent = parent
		self.allowedContentTypes = allowedContentTypes
		self.message = message
		self.prompt = prompt
		self.isVisible = isVisible
		self.isExtensionHidden = isExtensionHidden
		self.canCreateDirectories = canCreateDirectories
		self.showsHiddenFiles = showsHiddenFiles
		self.directoryURL = directoryURL
		self.onSelectFile = onSelectFile
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
		Swift.print("deinit: SavePanelInstance")
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

		let savePanel = NSSavePanel()
		self.currentPanel = savePanel

		if #available(macOS 11.0, *) {
			let uttypes = self.allowedContentTypes.compactMap { $0 as? UTType }
			if uttypes.count > 0 {
				savePanel.allowedContentTypes = uttypes
			}
		}

		let strs = self.allowedContentTypes.compactMap { $0 as? String }
		if strs.count > 0 {
			// Backward support for macOS < 11
			savePanel.allowedFileTypes = strs
		}

		if let prompt {
			savePanel.prompt = prompt
		}
		if let canCreateDirectories {
			savePanel.canCreateDirectories = canCreateDirectories
		}
		if let isExtensionHidden {
			savePanel.isExtensionHidden = isExtensionHidden
		}
		if let showsHiddenFiles {
			savePanel.showsHiddenFiles = showsHiddenFiles
		}
		if let directoryURL {
			savePanel.directoryURL = directoryURL
		}

		savePanel.message = self.message

		if let fn = self.accessoryViewBuilder {
			savePanel.accessoryView = fn()
		}

		savePanel.beginSheetModal(for: containingWindow) { [weak self, weak savePanel] response in
			DispatchQueue.main.async {
				if let `self` = self,
					let url = savePanel?.url
				{
					self.didChooseFile(response, url: url)
					self.dismissSheet()
				}
			}
		}
	}

	private func didChooseFile(_ response: NSApplication.ModalResponse, url: URL) {
		if response == .OK {
			self.onSelectFile(url)
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
	let showSavePanel = Bind(false)
	let selectedFileText = Bind("")
	let selectedFile = Bind<URL?>(nil) { newValue in
		selectedFileText.wrappedValue = newValue?.description ?? "<no file selected>"
	}

	VStack {
		NSButton(title: "Save image...") { _ in
			showSavePanel.wrappedValue = true
		}
		.fileExporter(
			isVisible: showSavePanel,
			allowedContentTypes: [.image],
			message: "Message",
			prompt: "Save this thing!"
		) { selected in
			selectedFile.wrappedValue = selected
		}

		NSTextField(label: selectedFileText)
			.compressionResistancePriority(.defaultLow, for: .horizontal)
	}
	.padding(top: 40, left: 20, bottom: 20, right: 20)
	.debugFrames()
}

#endif

