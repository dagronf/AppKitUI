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

@MainActor
public extension NSView {
	/// A placeholder view for a nothing (empty) view
	///
	/// Used for detecting empty views within (eg.) a stackview
	static let empty = NSView()

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
		self.content(layoutStyle: layoutStyle, content: builder())
	}

	/// Create a view containing the result of a view body generator
	/// - Parameter viewBodyGenerator: The view generator
	convenience init(_ viewBodyGenerator: AUIViewBodyGenerator) {
		self.init(layoutStyle: .fill, builder: { viewBodyGenerator.body })
	}

	/// Store this control
	@discardableResult @inlinable
	func store<View>(in ctrl: inout View?) -> Self where View: NSView {
		ctrl = self as? View
		return self
	}

	/// Perform a block, passing the created control as the parameter
	@discardableResult @inlinable
	func extras<View>(_ block: (View) -> Void) -> Self where View: NSView {
		if let v = self as? View {
			block(v)
		}
		else {
			Swift.print("Cannot cast \(self) to type \(View.self) - ignoring 'extra' call. Internal error?")
		}
		return self
	}

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

	/// Set the content for the view by attaching a child view to the edges of this view
	/// - Parameter content: The view's content
	/// - Returns: self
	@discardableResult
	func content(fill content: NSView, padding: Double = 0) -> Self {

		// Remove the existing content first
		self.subviews.forEach { $0.removeFromSuperview() }

		self.translatesAutoresizingMaskIntoConstraints = false
		content.translatesAutoresizingMaskIntoConstraints = false

		self.addSubview(content)

		self.addConstraint(NSLayoutConstraint(item: content, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: padding))
		self.addConstraint(NSLayoutConstraint(item: content, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -padding))
		self.addConstraint(NSLayoutConstraint(item: content, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: padding))
		self.addConstraint(NSLayoutConstraint(item: content, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -padding))

		return self
	}

	/// Set the content for the view by centering the child content within this view
	/// - Parameter content: The view's content
	/// - Returns: self
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

	/// Add padding around this view by installing this view within a new NSView with contraints
	/// - Parameter padding: The padding value
	/// - Returns: self
	@objc func padding(_ padding: Double = 20) -> NSView {
		let view = NSView()
		view.wantsLayer = true
		view.translatesAutoresizingMaskIntoConstraints = false
		self.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(self)

		view.addConstraint(NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: padding))
		view.addConstraint(NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -padding))
		view.addConstraint(NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: padding))
		view.addConstraint(NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -padding))

		return view
	}

	/// Add padding around this view by installing this view within a new NSView with contraints
	/// - Parameters:
	///   - top: Top padding
	///   - left: Left padding
	///   - bottom: Bottom padding
	///   - right: Right padding
	/// - Returns: A new NSView containging this view as a child view with the specified padding
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

	/// A Boolean value indicating whether the view’s autoresizing mask is translated into constraints for the
	/// constraint-based layout system.
	@discardableResult @inlinable
	func translatesAutoresizingMaskIntoConstraints(_ value: Bool) -> Self {
		self.translatesAutoresizingMaskIntoConstraints = value
		return self
	}

	/// Set the identifier for the ui item
	/// - Parameter str: The identifier as a string
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

	/// Mark the view as wanting a CALayer
	/// - Parameter value: If true, adds a CALayer to the NSView
	/// - Returns: self
	@discardableResult @inlinable
	func wantsLayer(_ value: Bool) -> Self {
		self.wantsLayer = value
		return self
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
		let color = color ?? CGColor(red: 1, green: 0, blue: 0, alpha: 1)
		self.wantsLayer = true
		self.layer.usingUnwrappedValue {
			$0.borderColor = color
			$0.borderWidth = 0.5
			$0.backgroundColor = color.copy(alpha: 0.05)
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
	/// Supply a block to be called when a Bonded value changes
	/// - Parameters:
	///   - item: The bonded value
	///   - block: The block to call with the new value
	/// - Returns: self
	///
	/// There is no guarantee that the callback block will be called on any particular thread.
	@discardableResult
	func onChange<T>(_ item: Bind<T>, _ block: @escaping (T) -> Void) -> Self {
		item.register(self) { newValue in
			block(newValue)
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

// MARK: - Setting the layer background stroke and fill

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

	/// Set the background fill color
	/// - Parameter fillColor: The fill color
	/// - Returns: self
	@discardableResult @inlinable
	func backgroundFill(_ fillColor: NSColor) -> Self {
		self.wantsLayer = true
		self.layer!.backgroundColor = fillColor.cgColor
		return self
	}

	/// Set the background border stroke
	/// - Parameters:
	///   - borderColor: The color for the border
	///   - lineWidth: The line width
	/// - Returns: self
	@discardableResult @inlinable
	func backgroundBorder(_ borderColor: NSColor, lineWidth: Double) -> Self {
		self.wantsLayer = true
		self.layer!.borderColor = borderColor.cgColor
		self.layer!.borderWidth = lineWidth
		return self
	}

	/// Apply a checkerboard effect to the background of this view
	/// - Parameters:
	///   - color1: color 1
	///   - color2: color 2
	///   - dimension: The dimension of each check
	/// - Returns: self
	///
	/// Setting the background filter also sets `masksToBounds` on the NSView.
	@discardableResult
	func checkerboardBackground(color1: NSColor = .white, color2: NSColor = .black, dimension: Double = 8) -> Self {
		if let filter = CIFilter(name: "CICheckerboardGenerator") {
			self.wantsLayer = true

			let width = NSNumber(value: Float(dimension))
			let center = CIVector(cgPoint: CGPoint(x: 0, y: 0))
			let darkColor = CIColor(cgColor: color1.cgColor)
			let lightColor = CIColor(cgColor: color2.cgColor)
			let sharpness = NSNumber(value: 1.0)

			filter.setDefaults()
			filter.setValue(width, forKey: "inputWidth")
			filter.setValue(center, forKey: "inputCenter")
			filter.setValue(darkColor, forKey: "inputColor0")
			filter.setValue(lightColor, forKey: "inputColor1")
			filter.setValue(sharpness, forKey: "inputSharpness")

			self.backgroundFilters.append(filter)
			self.layer?.masksToBounds = true
		}
		return self
	}
}

// MARK: - Storage

@MainActor
internal extension NSView {

	func usingViewStorage(_ block: @escaping (Storage) -> Void) {
		self.usingAssociatedValue(key: "__nsview_bond", initialValue: { Storage() }, block)
	}

	@MainActor
	class Storage {
		var windowedContent: [WindowedContentProtocol] = []

		func addWindowedContent(_ content: WindowedContentProtocol) {
			self.windowedContent.append(content)
		}
	}
}

// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("checkerboard") {
	HStack {
		NSView()
			.identifier("1")
			.checkerboardBackground(color1: .white.withAlphaComponent(0.1), color2: .black.withAlphaComponent(0.1))
			.onClickGesture {
				Swift.print("User clicked 1")
			}
		NSView()
			.identifier("2")
			.checkerboardBackground(color1: .blue.withAlphaComponent(0.1), color2: .red.withAlphaComponent(0.1))
			.onClickGesture {
				Swift.print("User clicked 2")
			}
	}
	.equalWidths(["1", "2"])
	.equalHeights(["1", "2"])
	.padding(8)
	.debugFrames()
}

#endif

