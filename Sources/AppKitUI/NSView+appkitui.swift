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
	/// A placeholder view for a nothing (empty) view
	///
	/// Used for detecting empty views within (eg.) a stackview
	static let empty = NSView()

	@inlinable
	var rootLayer: CALayer { self.layer! }

	/// The layout style when building a view with a content builder
	enum LayoutStyle {
		/// Attach the builder view to the edges of this view
		case fill
		/// Center the builder view within this view
		case centered
	}

	/// Create and initialize the content
	/// - Parameters:
	///   - layoutStyle: The layout style when building a view with a content builder
	///   - builder: The block to call to retrieve the content
	convenience init(layoutStyle: LayoutStyle, builder: () -> NSView) {
		self.init()
		self.translatesAutoresizingMaskIntoConstraints = false
		self.content(layoutStyle: layoutStyle, content: builder())
	}

	/// Create a view specifying the child subviews
	/// - Parameters:
	///   - subViewsBuilder: The block to call to retrieve the content
	convenience init(@NSViewsBuilder subViewsBuilder: () -> [NSView]) {
		self.init()
		self.translatesAutoresizingMaskIntoConstraints = false
		let subviews = subViewsBuilder()
		subviews.forEach { view in
			self.addChildView(view)
		}
	}

	/// Create a view containing the result of a view body generator
	/// - Parameter viewBodyGenerator: The view generator
	convenience init(_ viewBodyGenerator: AUIViewBodyGenerator) {
		self.init(layoutStyle: .fill, builder: { viewBodyGenerator.body })
	}
}

// MARK: - Advanced NSView

@MainActor
public extension NSView {
	/// Store this view into a separate variable
	@discardableResult
	func store<T: NSView>(in ctrl: inout T?) -> Self {
		ctrl = self as? T
		return self
	}

	/// Perform a block, passing the created control as the parameter
	@discardableResult
	func extras<T: NSView>(_ block: (T) -> Void) -> Self {
		if let v = self as? T {
			block(v)
		}
		else {
			let msg = "Cannot cast \(self) to type \(T.self) - ignoring 'extra' call. Internal error?"
			os_log("%@", log: logger, type: .debug, msg)
		}
		return self
	}

	/// Set the semantic context for this view and all subviews to the same as a macOS grouped form
	/// - Returns: self
	///
	/// See: [https://stackoverflow.com/a/79607626](https://stackoverflow.com/a/79607626)
	@discardableResult
	func formSemanticContent() -> Self {
		self.setValue(8, forKey: "semanticContext")
		return self
	}
}

// MARK: - Background and overlay views

@MainActor
public extension NSView {
	/// Overlay a view on top this view
	/// - Parameter overlayView: The view to overlay on top of this view
	/// - Returns: self
	///
	/// On order for an overlay to work, we have to add the overlay view as a subview for this view
	@discardableResult
	func overlay(_ overlayView: NSView) -> Self {
		self.translatesAutoresizingMaskIntoConstraints = false
		overlayView.translatesAutoresizingMaskIntoConstraints = false
		overlayView.pin(inside: self)
		return self
	}

	/// Overlay a view on this view
	/// - Parameter block: The view generator block
	/// - Returns: self
	///
	/// On order for an overlay to work, we have to add the overlay view as a subview for this view
	@discardableResult @inlinable
	func overlay(_ block: () -> NSView) -> Self {
		self.overlay(block())
	}

	/// Insert a background view behind this view
	/// - Parameter backgroundView: The view to use as the background for this view
	/// - Returns: The background view
	///
	/// Note: This function returns the **background view** in order for the z-order heirarchy to be maintained
	@discardableResult @inlinable
	func background<T: NSView>(_ backgroundView: T) -> T {
		backgroundView.overlay(self)
	}

	/// Insert a background view behind this view
	/// - Parameter block: The block that builds the background view
	/// - Returns: The background view
	///
	/// Note: This function returns the **background view** in order for the z-order heirarchy to be maintained
	@discardableResult @inlinable
	func background<T: NSView>(_ block: () -> T) -> T {
		self.background(block())
	}
}

// MARK: - Setting the view's content

@MainActor
public extension NSView {
	/// Set the content of this view
	/// - Parameters:
	///   - layoutStyle: The layout style for the child view
	///   - padding: The padding to apply to between the child and this view
	///   - content: The view to add
	/// - Returns: self
	@discardableResult @inlinable
	func content(layoutStyle: LayoutStyle = .fill, padding: Double = 0, content: NSView) -> Self {
		switch layoutStyle {
		case .fill:
			self.content(fill: content, padding: padding)
		case .centered:
			self.content(center: content, padding: padding)
		}
	}

	/// Set the content of this view
	/// - Parameters:
	///   - layoutStyle: The layout style for the child view
	///   - padding: The padding to apply to between the child and this view
	///   - builder: The block called to generate the new content
	/// - Returns: self
	@discardableResult @inlinable
	func content(layoutStyle: LayoutStyle = .fill, padding: Double = 0, _ builder: () -> NSView) -> Self {
		self.content(layoutStyle: layoutStyle, padding: padding, content: builder())
	}

	/// Set the content for the view by attaching a child view as a subview to the edges of this view
	/// - Parameters:
	///   - content: The view's content
	///   - padding: The padding to apply between the subview and this view
	/// - Returns: self
	///
	/// NOTE: This call removes all existing subviews from this view!
	@discardableResult
	func content(fill content: NSView, padding: Double = 0) -> Self {
		self.content(fill: content, top: padding, left: padding, bottom: -padding, right: -padding)
	}

	/// Set the content for the view by attaching a child view as a subview to the edges of this view
	/// - Parameters:
	///   - content: The view's content
	///   - top: top padding
	///   - left: left (leading) padding
	///   - bottom: bottom padding
	///   - right: right (trailing) padding
	/// - Returns: self
	@discardableResult
	func content(fill content: NSView, top: Double = 0, left: Double = 0, bottom: Double = 0, right: Double = 0) -> Self {
		// Remove the existing content first
		self.subviews.forEach { $0.removeFromSuperview() }

		self.translatesAutoresizingMaskIntoConstraints = false
		content.translatesAutoresizingMaskIntoConstraints = false

		self.addSubview(content)

		self.addConstraint(NSLayoutConstraint(item: content, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: left))
		self.addConstraint(NSLayoutConstraint(item: content, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: right))
		self.addConstraint(NSLayoutConstraint(item: content, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: top))
		self.addConstraint(NSLayoutConstraint(item: content, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: bottom))

		return self
	}

	/// Set the content for the view by centering the child content within this view
	/// - Parameters:
	///   - content: The view's content
	///   - padding: The padding to apply between the subview and this view
	/// - Returns: self
	///
	/// NOTE: This call removes all existing subviews from this view!
	@discardableResult
	func content(center content: NSView, padding: Double = 0) -> Self {
		// Remove the existing content first
		self.subviews.forEach { $0.removeFromSuperview() }

		self.translatesAutoresizingMaskIntoConstraints = false
		content.translatesAutoresizingMaskIntoConstraints = false

		self.addSubview(content)

		// Center the child view within this view
		self.addConstraint(NSLayoutConstraint(item: content, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
		self.addConstraint(NSLayoutConstraint(item: content, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))

		// Make sure that the child view cannot expand beyond the bounds of the parent view
		self.addConstraint(NSLayoutConstraint(item: content, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: self, attribute: .leading, multiplier: 1, constant: padding))
		self.addConstraint(NSLayoutConstraint(item: content, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: self, attribute: .top, multiplier: 1, constant: padding))

		return self
	}
}

// MARK: - Adding child views to this view

@MainActor
public extension NSView {
	/// Set the layout style when this view is inserted as a subview within another view
	/// - Parameter layout: The layout style
	/// - Returns: self
	@discardableResult
	func subviewLayoutStyle(_ layout: LayoutStyle) -> Self {
		self.setArbitraryValue(layout, forKey: "subviewLayoutStyle")
		return self
	}

	/// Add a subview to this view
	/// - Parameter view: The view
	/// - Returns: self
	@discardableResult
	func addChildView(_ view: NSView) -> Self {
		view.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(view)

		let padding: Double = 0.0
		let layout: LayoutStyle = view.getArbitraryValue(forKey: "subviewLayoutStyle") ?? .fill
		if layout == .fill {
			self.addConstraint(NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: padding))
			self.addConstraint(NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -padding))
			self.addConstraint(NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: padding))
			self.addConstraint(NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -padding))
		}
		else if layout == .centered {
			// Center the child view within this view
			self.addConstraint(NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
			self.addConstraint(NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))

			// Make sure that the child view cannot expand beyond the bounds of the parent view
			self.addConstraint(NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: self, attribute: .leading, multiplier: 1, constant: padding))
			self.addConstraint(NSLayoutConstraint(item: view, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: self, attribute: .top, multiplier: 1, constant: padding))
		}
		else {
			fatalError()
		}

		return self
	}
}

// MARK: - Padding

@MainActor
public extension NSView {
	/// Add padding around this view by installing this view within a new NSView with contraints
	/// - Parameter padding: The padding value
	/// - Returns: A new NSView containing this view as a child view with the specified padding
	@discardableResult
	@objc func padding(_ padding: Double = 20) -> NSView {
		self.padding(top: padding, left: padding, bottom: padding, right: padding)
	}

	/// Add padding around this view by installing this view within a new NSView with contraints
	/// - Parameters:
	///   - top: Top padding
	///   - left: Left padding
	///   - bottom: Bottom padding
	///   - right: Right padding
	/// - Returns: A new NSView containing this view as a child view with the specified padding
	@objc func padding(top: Double = 0, left: Double = 0, bottom: Double = 0, right: Double = 0) -> NSView {
		let view = NSView()
		view.wantsLayer = true
		view.translatesAutoresizingMaskIntoConstraints = false
		self.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(self)

		view.addConstraint(NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: left))
		view.addConstraint(NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -right))
		view.addConstraint(NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: top))
		view.addConstraint(NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -bottom))

		return view
	}
}

// MARK: - Modifiers

@MainActor
public extension NSView {
	/// A Boolean value indicating whether the view’s autoresizing mask is translated into constraints for the
	/// constraint-based layout system.
	@discardableResult @inlinable
	func translatesAutoresizingMaskIntoConstraints(_ value: Bool) -> Self {
		self.translatesAutoresizingMaskIntoConstraints = value
		return self
	}

	/// Set the identifier for the ui item
	/// - Parameter id: The view's identifier
	/// - Returns: self
	@discardableResult @inlinable
	func identifier(_ id: AUIIdentifier) -> Self {
		self.identifier = id.identifier
		return self
	}

	/// Set the tooltip for the view
	/// - Parameter value: The tooltip string
	/// - Returns: self
	@discardableResult @inlinable
	func toolTip(_ value: String) -> Self {
		self.toolTip = value
		return self
	}

	/// Set the identifier for the ui item
	/// - Parameter value: If true, set the view as hidden
	/// - Returns: self
	@discardableResult @inlinable
	func isHidden(_ value: Bool) -> Self {
		self.isHidden = value
		return self
	}

	/// Set the alpha value for the view
	/// - Parameter value: The alpha value (clamped 0 ... 1)
	/// - Returns: self
	@discardableResult @inlinable
	func alphaValue(_ value: Double) -> Self {
		self.alphaValue = max(0, min(1, value))
		return self
	}

	/// Apply a drop shadow to this view
	/// - Parameters:
	///   - offset: The shadow’s relative position, which you specify with horizontal and vertical offset values.
	///   - color: The color of the shadow.
	///   - blurRadius: The blur radius of the shadow.
	/// - Returns: self
	@discardableResult
	func shadow(offset: CGSize? = nil, color: NSColor? = nil, blurRadius: Double? = nil) -> Self {
		let s = NSShadow()
		if let offset {
			s.shadowOffset = offset
		}
		if let color {
			s.shadowColor = color
		}
		if let blurRadius {
			s.shadowBlurRadius = blurRadius
		}
		self.shadow = s
		return self
	}

	/// Mark the view as wanting a CALayer
	/// - Parameter value: If true, adds a CALayer to the NSView
	/// - Returns: self
	@discardableResult @inlinable
	func wantsLayer(_ value: Bool) -> Self {
		self.wantsLayer = value
		return self
	}

	/// Set the user interface layout direction
	/// - Parameter value: The direction
	/// - Returns: self
	@discardableResult
	func userInterfaceLayoutDirection(_ value: NSUserInterfaceLayoutDirection) -> Self {
		for subview in self.allSubviews() {
			subview.userInterfaceLayoutDirection = value
			subview.needsLayout = true
		}
		return self
	}
}

// MARK: Binding

@MainActor
public extension NSView {
	/// Bind the hidden state for the control
	@discardableResult
	func isHidden(_ isHidden: Bind<Bool>) -> Self {
		isHidden.register(self) { @MainActor [weak self] newValue in
			self?.isHidden = newValue
		}
		self.isHidden = isHidden.wrappedValue
		return self
	}
}

// MARK: - onChange handlers

@MainActor
public extension NSView {
	/// Supply a block to be called when a binding value changes
	/// - Parameters:
	///   - item: The bind value
	///   - block: The block to call with the new value
	/// - Returns: self
	///
	/// The callback block will be called on the main actor
	@discardableResult
	func onChange<T>(_ item: Bind<T>, _ block: @escaping (T) -> Void) -> Self {
		item.register(self) { @MainActor newValue in
			assert(Thread.isMainThread)
			block(newValue)
		}
		return self
	}
}

// MARK: - Setting the view's layer background stroke and fill

@MainActor
public extension NSView {
	/// Set the background corner radius
	/// - Parameter value: The corner radius
	/// - Returns: self
	@discardableResult @inlinable
	func backgroundCornerRadius(_ value: Double) -> Self {
		self.wantsLayer = true
		self.layer!.cornerRadius = value
		return self
	}

	// MARK: Background fill

	/// Set the background fill color by setting the view's layer background color property
	/// - Parameter fillColor: The fill color
	/// - Returns: self
	@discardableResult
	func backgroundFill(_ fillColor: NSColor) -> Self {
		self.wantsLayer = true
		self.rootLayer.backgroundColor = self.effectiveCGColor(color: fillColor)
		self.onViewAppearanceChange { @MainActor [weak self] in
			self?.rootLayer.backgroundColor = self?.effectiveCGColor(color: fillColor)
		}
		return self
	}

	/// Set the background fill color
	/// - Parameter fillColor: The fill color
	/// - Returns: self
	@discardableResult
	func backgroundFill(_ fillColor: DynamicColor) -> Self {
		self.wantsLayer = true
		self.rootLayer.backgroundColor = fillColor.effectiveCGColor(for: self)
		self.onViewAppearanceChange { @MainActor [weak self] in
			self?.rootLayer.backgroundColor = fillColor.effectiveCGColor(for: self)
		}
		return self
	}

	// MARK: Background stroke

	/// Set the background border stroke
	/// - Parameters:
	///   - borderColor: The color for the border
	///   - lineWidth: The line width
	/// - Returns: self
	@discardableResult
	func backgroundBorder(_ borderColor: NSColor, lineWidth: Double) -> Self {
		self.wantsLayer = true
		self.rootLayer.borderColor = borderColor.cgColor
		self.rootLayer.borderWidth = lineWidth
		self.onViewAppearanceChange { @MainActor [weak self] in
			self?.rootLayer.borderColor = borderColor.effectiveCGColor(for: self)
		}
		return self
	}

	/// Set the background border stroke
	/// - Parameters:
	///   - borderColor: The color for the border
	///   - lineWidth: The line width
	/// - Returns: self
	@discardableResult
	func backgroundBorder(_ borderColor: DynamicColor, lineWidth: Double) -> Self {
		self.wantsLayer = true
		self.rootLayer.borderColor = borderColor.effectiveCGColor(for: self)
		self.rootLayer.borderWidth = lineWidth
		self.onViewAppearanceChange { @MainActor [weak self] in
			self?.rootLayer.borderColor = borderColor.effectiveCGColor(for: self)
		}
		return self
	}
}

// MARK: - View builders

@resultBuilder
public enum NSViewsBuilder {
	static func buildBlock() -> [NSView] { [] }
}

public extension NSViewsBuilder {
	static func buildBlock(_ settings: NSView...) -> [NSView] {
		settings
	}

	static func buildBlock(_ settings: [NSView]) -> [NSView] {
		settings
	}

	static func buildOptional(_ component: [NSView]?) -> [NSView] {
		component ?? []
	}

	/// Add support for if statements.
	static func buildEither(first components: [NSView]) -> [NSView] {
		components
	}

	static func buildEither(second components: [NSView]) -> [NSView] {
		components
	}

	/// Add support for loops.
	static func buildArray(_ components: [[NSView]]) -> [NSView] {
		components.flatMap { $0 }
	}
}

// MARK: - Debug frames

@MainActor
public extension NSView {
	/// Draw a debugging border for this view
	/// - Parameter color: The drawing color
	/// - Returns: self
	@discardableResult
	func debugFrame(_ color: CGColor? = nil) -> Self {
		let color = color ?? CGColor(red: 1, green: 0, blue: 0, alpha: 0.4)
		self.wantsLayer = true
		self.layer.usingUnwrappedValue {
			$0.borderColor = color
			$0.borderWidth = 0.5
			$0.backgroundColor = color.copy(alpha: 0.02)
		}
		return self
	}

	/// Draw a debugging border for this view
	/// - Parameter color: The drawing color
	/// - Returns: self
	@discardableResult @inlinable
	func debugFrame(_ color: NSColor) -> Self {
		self.debugFrame(color.cgColor)
	}

	/// Draw a debugging border for this view and all of its subviews
	/// - Parameter color: The drawing color
	/// - Returns: self
	@discardableResult
	func debugFrames(_ color: CGColor? = nil) -> Self {
		self.allSubviews().forEach { $0.debugFrame(color) }
		return self
	}

	/// Draw a debugging border for this view and all of its subviews
	/// - Parameter color: The drawing color
	/// - Returns: self
	@discardableResult
	func debugFrames(_ color: NSColor) -> Self {
		self.allSubviews().forEach { $0.debugFrame(color) }
		return self
	}
}

// MARK: - Observing frame changes

@MainActor
public extension NSView {
	/// Call a block when the frame of a view changes
	/// - Parameters:
	///   - delayType: The delay to apply to the callback
	///   - block: The block to call, passing the view's frame
	/// - Returns: self
	@discardableResult
	func onFrameChange(delayType: DelayingCallType = .none, _ block: @escaping (NSRect) -> Void) -> Self {
		self.usingViewStorage {
			$0.registerFrameChangeHandler(parent: self, delayType: delayType, block)
		}
		return self
	}
}

// MARK: - Storage

/// Windowed content associated with a view (eg. alerts, sheets etc)
protocol WindowedContentProtocol { }

@MainActor
extension NSView {
	func usingViewStorage(_ block: @escaping (Storage) -> Void) {
		self.usingAssociatedValue(key: "__nsview_bond", initialValue: { Storage(parent: self) }, block)
	}

	@MainActor
	class Storage {
		private weak var parent: NSView?

		init(parent: NSView) {
			self.parent = parent
		}

		func addWindowedContent(_ content: WindowedContentProtocol) {
			self.windowedContent.append(content)
		}

		// Set up the application aooearance change handler
		func registerAppearanceHandler(_ block: @escaping () -> Void) {
			guard #available(macOS 10.14, *) else { return }
			self.appearanceObserver?.registerAppearanceHandler(block)
		}

		// Set up the application aooearance change handler
		func registerApplicationAppearanceHandler(_ block: @escaping () -> Void) {
			guard #available(macOS 10.14, *) else { return }
			self.applicationAppearanceObserver?.registerAppearanceHandler(block)
		}

		// Set up the frame change handler
		func registerFrameChangeHandler(
			parent: NSView,
			delayType: DelayingCallType,
			_ block: @escaping (NSRect) -> Void
		) {
			guard self.frameChangeBlock == nil else { return }
			parent.postsFrameChangedNotifications = true
			self.frameChangeBlock = block

			let delay = delayType.make()

			self.frameObservation = NotificationCenter.default.addObserver(
				forName: NSView.frameDidChangeNotification,
				object: parent,
				queue: .main
			) { [weak self, weak parent] notification in
				DispatchQueue.main.async {
					guard let `self` = self, let parent, let call = self.frameChangeBlock else { return }
					let frame = parent.frame
					delay.perform {
						call(frame)
					}
				}
			}
		}

		deinit {
			os_log("deinit: NSView.Storage", log: logger, type: .debug)
			self.windowedContent = []
			self.frameObservation = nil
			self.frameChangeBlock = nil
		}

		/// Only create the appearance observer if we need it
		private lazy var appearanceObserver: ViewAppearanceObservation? = {
			guard let parent = self.parent else { return nil }
			return ViewAppearanceObservation(view: parent)
		}()

		/// Only create the appearance observer if we need it
		private lazy var applicationAppearanceObserver: AppearanceObservation? = {
			return AppearanceObservation()
		}()

		private var windowedContent: [WindowedContentProtocol] = []
		private var frameChangeBlock: ((NSRect) -> Void)?
		private var frameObservation: NSObjectProtocol?
	}
}

// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("background") {
	HStack {
		NSTextField(label: "This is a test")
			.padding(20)
			.background(
				Rectangle(cornerRadius: 8)
					.fill(color: .systemBlue)
			)

		Rectangle()
			.fill(.gradient(color: .systemPurple))
			.stroke(.systemPurple, lineWidth: 1.5)
			.overlay(
				NSTextField(label: "This is a test")
					.padding(8)
			)

		VStack {
			NSTextField(label: "Top layer")
			NSButton(title: "The button!")
				.bezelStyle(.accessoryBar)
			NSTextField(label: "Bottom layer")
		}
		.padding(12)
		.background(
			Rectangle(cornerRadius: 8)
				.fill(.gradient(color: .systemPink))
		)
	}
}

@available(macOS 14, *)
#Preview("shadows") {
	HStack(spacing: 20) {
		NSView()
			.backgroundFill(.systemRed)
			.shadow(offset: CGSize(width: 1, height: -1), color: .textColor, blurRadius: 3)
			.frame(width: 50, height: 50)
		NSView()
			.backgroundFill(.systemGreen)
			.shadow(offset: CGSize(width: 0, height: 0), color: .textColor, blurRadius: 5)
			.frame(width: 50, height: 50)
		NSView()
			.backgroundFill(.systemBlue)
			.shadow(offset: CGSize(width: -2, height: 2), color: .textColor, blurRadius: 3)
			.frame(width: 50, height: 50)
		NSView()
			.backgroundFill(.systemYellow)
			.backgroundCornerRadius(5)
			.shadow(offset: CGSize(width: 0, height: 0), color: .black, blurRadius: 10)
			.frame(width: 50, height: 50)
		NSView()
			.backgroundBorder(.textColor, lineWidth: 2)
			.backgroundFill(.quaternaryLabelColor)
			.frame(width: 50, height: 50)
		NSView()
			.backgroundBorder(DynamicColor(dark: .systemRed, light: .systemBlue), lineWidth: 2)
			.frame(width: 50, height: 50)
	}
}

#endif
