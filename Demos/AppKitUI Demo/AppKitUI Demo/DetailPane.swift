//
//  DetailView.swift
//  AppKitUI Demo
//
//  Created by Darren Ford on 17/7/2025.
//

import AppKit
import AppKitUI

protocol Logger {
	@MainActor func log(_ content: Any)
}

class DetailPane: NSView {
	let model: Model
	init(model: Model) {
		self.model = model
		super.init(frame: .zero)
		self.setup()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	let detailView = NSView()

	func setup() {
		let detailSplit = HSplitView(dividerStyle: .thin) {
			detailView
				.minWidth(300)
			makeLoggingOutputView(model: model)
				.minHeight(120)
		}
		.holdingPriority(.init(100), forItemAtIndex: 0)
		.holdingPriority(.init(250), forItemAtIndex: 1)

		self.content(fill: detailSplit)

		self.onChange(model.selected) { [weak self] newSelection in
			self?.updatePane(newSelection)
		}

		// Set the initial pane
		self.updatePane(model.selected.wrappedValue)
	}

	func updatePane(_ newSelection: Int) {
		let pane: Pane
		if newSelection == -1 {
			pane = EmptyPane()
		}
		else {
			pane = self.model.panes.wrappedValue[newSelection]
		}
		self.detailView.content(fill: pane.make(model: model))
	}
}

private let trashImage__ = NSImage(named: "trash")!
	.isTemplate(true)
	.size(width: 10, height: 12)

@MainActor
private func makeLoggingOutputView(model: Model) -> NSView {
	let logging = LoggingView()
		.font(.monospaced.size(11))
	model.log = logging
	return VStack(spacing: 0) {
		logging

		HStack(spacing: 4) {
			NSButton(title: NSLocalizedString("Clear Log", comment: "")) { _ in
				logging.clear()
			}
			.bezelStyle(.accessoryBarAction)
			.image(trashImage__)
			.imageScaling(.scaleProportionallyDown)
			.imagePosition(.imageLeading)
			.controlSize(.small)
			.toolTip(NSLocalizedString("Clear log", comment: ""))
			.gravityArea(.leading)
		}
		.hugging(.init(10), for: .horizontal)
		.padding(4)
		.background(
			NSVisualEffectView()
		)
	}
}

@MainActor
class LoggingView: AUIScrollingTextView, Logger {

	override init() {
		super.init()

		self.isEditable(false)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func clear() {
		self.textView.textStorage?.mutableString.setString("")
	}
	func log(_ content: Any) {
		let string = "\(content)\n"
		let tv = self.textView

		let textStorage = tv.textStorage!

		// Use existing attributes or provided ones
		let textAttributes = tv.typingAttributes
		let attributedText = NSAttributedString(string: string, attributes: textAttributes)

		// Append the text
		textStorage.append(attributedText)

		// Scroll to show the new text
		let newRange = NSRange(location: textStorage.length, length: 0)
		tv.scrollRangeToVisible(newRange)

		// Optionally, you can also set the insertion point to the end
		tv.setSelectedRange(newRange)
	}
}

#if DEBUG
@available(macOS 14, *)
#Preview("DetailView") {
	DetailPane(model: Model())
		.frame(width: 600, height: 400)
}
#endif
