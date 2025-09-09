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

/// A simple view that provides a basic 'content unavailable' style view
@MainActor
public class AUIContentUnavailableView: NSView {
	/// Create a content unavailable view with a title
	/// - Parameter title: The title
	public init(title: String) {
		self.title = title
		super.init(frame: .zero)
		self.setup()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// Private

	private var title: String
	private var image: NSImage?
	private var imageView: NSImageView?

	private var textField: NSTextField?
	private var descriptionField: NSTextField?

	private var buttons: NSStackView?
}

@MainActor
private extension AUIContentUnavailableView {
	func setup() {

		self.translatesAutoresizingMaskIntoConstraints = false
		self.huggingPriority(.defaultLow, for: .horizontal)
		self.huggingPriority(.defaultLow, for: .vertical)

		let content =
			VStack(spacing: 24) {
				NSImageView()
					.store(in: &imageView)
					.isHidden(true)

				VStack(spacing: 4) {
					NSTextField(label: self.title)
						.store(in: &textField)
						.font(.title2.bold)
						.alignment(.center)
						.compressionResistancePriority(.defaultLow, for: .horizontal)

					NSTextField(label: "")
						.store(in: &descriptionField)
						.isHidden(true)
						.font(.system.weight(.light))
						.textColor(.secondaryLabelColor)
						.alignment(.center)
						.compressionResistancePriority(.defaultLow, for: .horizontal)
				}
				.detachesHiddenViews(true)

				HStack {
					NSView.empty
				}
				.isHidden(true)
				.store(in: &buttons)
			}
			.detachesHiddenViews(true)

		self.content(center: content, padding: 20)
	}
}

// MARK: - Modifiers

/// A simple view that provides a basic 'content unavailable' style view
@MainActor
public extension AUIContentUnavailableView {
	/// Set the description text
	/// - Parameter text: The text
	/// - Returns: self
	@discardableResult
	func description(_ text: String) -> Self {
		self.descriptionField?.stringValue = text
		self.descriptionField?.isHidden = false
		return self
	}

	/// Set the image to be displayed at the top of the view
	/// - Parameter image: The image
	/// - Returns: self
	@discardableResult
	func image(_ image: NSImage) -> Self {
		self.imageView?.image = image
		self.imageView?.isHidden = false
		return self
	}

	/// Set the title font
	@discardableResult
	func titleFont(_ font: NSFont) -> Self {
		self.textField?.font = font
		return self
	}

	/// Add a button to the bottom of the content view
	/// - Parameter button: The button
	/// - Returns: self
	@discardableResult
	func addButton(_ button: NSButton) -> Self {
		button.translatesAutoresizingMaskIntoConstraints = false
		self.buttons?.isHidden = false
		self.buttons?.addArrangedSubview(button)
		return self
	}
}

// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("basic") {
	AUIContentUnavailableView(title: "Content unavailable")
}

private let appIcon__ = NSImage(named: NSImage.everyoneName)!
	.isTemplate(true)
	.size(width: 48, height: 48)

@available(macOS 14, *)
#Preview("image") {
	AUIContentUnavailableView(title: "Content unavailable")
		.image(appIcon__)
		.debugFrames()
}

@available(macOS 14, *)
#Preview("image, desc") {
	AUIContentUnavailableView(title: "Empty Palette")
		.description("Add some colours to your new palette using the + button in the toolbar.")
		.image(appIcon__)
		.debugFrames()
}

@available(macOS 14, *)
#Preview("desc, button") {
	AUIContentUnavailableView(title: "No Internet")
		.description("Try checking the network cables, modem, and router or reconnecting to Wi-Fi.")
		.debugFrames()
}

@available(macOS 14, *)
#Preview("image, desc, button") {
	AUIContentUnavailableView(title: "No Internet")
		.description("Try checking the network cables, modem, and router or reconnecting to Wi-Fi.")
		.addButton(
			NSButton()
				.title("Try again")
				.onAction { _ in
					Swift.print("Pressed the try again button")
				}
		)
}

private let network__ = NSImage(named: NSImage.networkName)!
	.size(width: 64, height: 64)

@available(macOS 14, *)
#Preview("image, desc, buttons") {
	AUIContentUnavailableView(title: "No Internet")
		.image(network__)
		.titleFont(.title1.bold)
		.description("Try checking the network cables, modem, and router or reconnecting to Wi-Fi.")
		.addButton(
			NSButton()
				.identifier("2")
				.title("Cancel everything")
				.onAction { _ in
					Swift.print("Pressed the cancel everything button")
				}
		)
		.addButton(
			NSButton()
				.identifier("1")
				.title("Try again")
				.onAction { _ in
					Swift.print("Pressed the try again button")
				}
				.isDefaultButton(true)
		)
		.equalWidths(["1", "2"])
}

#endif
