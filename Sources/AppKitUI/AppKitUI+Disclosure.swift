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

/// A disclosure view
@MainActor
public class AUIDisclosure: NSView {
	/// Create a disclosure view
	/// - Parameters:
	///   - title: The disclosure title
	///   - builder: The builder for the disclosure content
	public init(title: String, builder: @escaping () -> NSView) {
		super.init(frame: .zero)
		self.setup(title: title, builder: builder)
	}

	@available(*, unavailable)
	public required init?(coder: NSCoder) {
		fatalError()
	}

	private func setup(title: String, builder: @escaping () -> NSView) {
		self.translatesAutoresizingMaskIntoConstraints = false

		let disclosureTitleView =
			NSVisualEffectView(material: .sidebar, blendingMode: .withinWindow) {
				HStack {
					DisclosureButton()
						.state(_internalState)
					NSTextField(label: "")
						.store(in: &self.titleField)
						.content(title)
					NSView.Spacer()
				}
				.store(in: &titleHStack)
				.edgeInsets(NSEdgeInsets(top: 0, left: 4, bottom: 0, right: 0))
				.spacing(4)
				.onClickGesture { [weak self] in
					self?._internalState.toggle()
				}
			}

		let content =
			HStack {
				builder()
					.padding(8)
				NSView.Spacer()
			}
			.spacing(0)
			.isHidden(_internalState.inverted()) // .oneWayTransform { $0 == false })
			//.isHidden(_internalState.oneWayTransform { $0 == false })

		let stackView = VStack {
			disclosureTitleView
			content
		}
		.spacing(0)
		.hugging(.defaultHigh, for: .vertical)

		self.addSubview(stackView)

		self.addConstraint(NSLayoutConstraint(item: stackView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
		self.addConstraint(NSLayoutConstraint(item: stackView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0))
		self.addConstraint(NSLayoutConstraint(item: stackView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
		self.addConstraint(NSLayoutConstraint(item: stackView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
	}

	private weak var titleHStack: NSStackView?
	private weak var titleField: NSTextField?
	private weak var contentStack: NSStackView?
	private weak var disclosureButton: DisclosureButton?

	private var font: NSFont?
	// Track the connection between the header disclosure and the visibility of the content
	private let _internalState = Bind(false) { Swift.print("newstate = \($0)") }
	public var state: Bind<Bool>?
	private let title = Bind("Disclosure")
}

// MARK: - Modifiers

@MainActor
public extension AUIDisclosure {
	/// Set the title font
	/// - Parameter font: The font
	/// - Returns: self
	@discardableResult
	func font(_ font: NSFont) -> Self {
		self.titleField?.font(font)
		return self
	}

	/// Set the height for the title
	/// - Parameter height: The height
	/// - Returns: self
	@discardableResult
	func titleHeight(_ height: Double) -> Self {
		self.titleHStack?.height(height)
		return self
	}
}

// MARK: - Bindings

@MainActor
public extension AUIDisclosure {
	/// Set the title font
	/// - Parameter font: The font
	/// - Returns: self
	@discardableResult
	func state(_ state: Bind<Bool>) -> Self {
		self.state = state
		self._internalState.reflect(state)
		return self
	}
}

// MARK: - Custom Disclosure

@MainActor
private class DisclosureButton: NSButton {
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		self.setup()
	}
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.setup()
	}
	func setup() {
		self.bezelStyle(.disclosure)
			.buttonType(.pushOnPushOff)
			.imagePosition(.imageOnly)
	}
	override func resetCursorRects() {
		super.resetCursorRects()
		self.addCursorRect(self.bounds, cursor: .pointingHand)
	}
}

// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("default") {
	let date = Bind(Date())
	let isVisible = Bind(true)
	ScrollView(fitHorizontally: true) {
		VStack(spacing: 2) {
			AUIDisclosure(title: "First one") {
				HStack {
					NSButton(title: "Wheeeee")
					Spacer()
					NSButton.checkbox(title: "Caterpillar and noodles")
				}
			}
			.font(.title3.weight(.semibold))
			.titleHeight(24)
			.state(isVisible)

			HDivider()

			AUIDisclosure(title: "Second one") {
				VStack {
					NSDatePicker(date: date, style: .clockAndCalendar)
						.elements([.yearMonthDay])
						.timeZone(.gmt)
				}
				.alignment(.leading)
			}
			.font(.title3.weight(.semibold))
			.titleHeight(24)

			Spacer()
		}
	}
	.borderType(.grooveBorder)
	.padding(30)
}

#endif
