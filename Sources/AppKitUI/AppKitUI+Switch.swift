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

/// An NSSwitch equivalent supported back to 10.11
@MainActor
public class AUISwitch: NSControl {
	public override var acceptsFirstResponder: Bool { self.isEnabled }
	public override var canBecomeKeyView: Bool      { self.isEnabled }
	public override func drawFocusRingMask() {
		let cr = self.bounds.height / 2.0
		NSBezierPath(roundedRect: self.bounds, xRadius: cr, yRadius: cr).fill()
	}
	public override var focusRingMaskBounds: NSRect {
		return self.bounds
	}

	private let knob = CALayer()
	private let background = CALayer()
	private var _state = NSControl.StateValue.off

	/// The current position of the switch.
	@MainActor
	@objc public dynamic var state: NSControl.StateValue {
		get {
			_state
		}
		set {
			guard newValue != _state else { return }
			self._state = newValue
			animateSwitch()
			sendAction(action, to: target)
		}
	}

	/// Switch on-off state
	private var isOn: Bool { self._state != .off }

	public override var intrinsicContentSize: NSSize {
		switch controlSize {
		case .large: fallthrough
		case .regular:
			return NSSize(width: 38, height: 22)
		case .small:
			return NSSize(width: 32, height: 18)
		case .mini:
			return NSSize(width: 26, height: 15)
		default:
			// Unsupported control size?
			return NSSize(width: 38, height: 22)
		}
	}

	private var trackingMouseDown = false
	private var dragStartPoint: NSPoint = .zero
	private var initialKnobX: CGFloat = 0
	private var hasDragged = false

	private var kvoDidBecomeKey: NSObjectProtocol?
	private var kvoDidResignKey: NSObjectProtocol?

	public override var wantsUpdateLayer: Bool { true }

	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		setupLayers()
	}

	required init?(coder decoder: NSCoder) {
		super.init(coder: decoder)
		setupLayers()
	}

	public override func viewDidMoveToWindow() {
		super.viewDidMoveToWindow()
		if let w = self.window {
			self.kvoDidBecomeKey = NotificationCenter.default.addObserver(
				forName: NSWindow.didBecomeKeyNotification,
				object: w,
				queue: nil
			) { [weak self] _ in
				DispatchQueue.main.async {
					self?.reflectColors()
				}
			}

			self.kvoDidResignKey = NotificationCenter.default.addObserver(
				forName: NSWindow.didResignKeyNotification,
				object: w,
				queue: nil
			) { [weak self] _ in
				DispatchQueue.main.async {
					self?.reflectColors()
				}
			}
		}
		else {
			NotificationCenter.default.removeObserver(self, name: NSWindow.didBecomeKeyNotification, object: nil)
			NotificationCenter.default.removeObserver(self, name: NSWindow.didResignKeyNotification, object: nil)
			self.kvoDidBecomeKey = nil
			self.kvoDidResignKey = nil
		}
	}

	private func setupLayers() {
		self.wantsLayer = true
		guard let layer = self.layer else { return }

		background.frame = bounds
		background.cornerRadius = bounds.height / 2
		background.backgroundColor = self.backgroundColor_.cgColor
		background.borderColor = self.backgroundBorderColor_.cgColor
		background.borderWidth = 1

		layer.addSublayer(background)

		knob.frame = CGRect(x: 1, y: 1, width: bounds.height - 2, height: bounds.height - 2)
		knob.cornerRadius = knob.bounds.height / 2
		knob.backgroundColor = NSColor.white.withAlphaComponent(0.8).cgColor
		knob.shadowColor = NSColor.black.cgColor
		knob.shadowOpacity = 0.2
		knob.shadowOffset = CGSize(width: 0, height: -1)
		knob.shadowRadius = 1
		layer.addSublayer(knob)
	}

	public override func updateLayer() {
		super.updateLayer()
		self.reflectColors()

		if self.isEnabled {
			self.layer!.opacity = 1.0
		}
		else {
			self.layer!.opacity = 0.5
		}
	}

	public override func layout() {
		super.layout()
		self.background.frame = self.bounds
		self.background.cornerRadius = self.bounds.height / 2
		self.knob.frame = CGRect(
			x: self.isOn ? self.bounds.width - self.bounds.height + 1 : 1,
			y: 1,
			width: self.bounds.height - 2,
			height: self.bounds.height - 2)
		self.knob.cornerRadius = self.knob.bounds.height / 2

		self.reflectColors()
	}

	// MARK: - Colors

	private func reflectColors() {
		// Update colors
		self.background.backgroundColor = self.backgroundColor_.cgColor
		self.background.borderColor = self.backgroundBorderColor_.cgColor

		if self.isHighContrast {
			if self.isDarkMode {
				self.knob.backgroundColor = NSColor.white.withAlphaComponent(0.9).cgColor
			}
			else {
				self.knob.borderWidth = 1
				self.knob.borderColor = NSColor.black.cgColor
			}
		}
		else {
			self.knob.backgroundColor = NSColor.white.withAlphaComponent(0.9).cgColor
		}
	}

	private var backgroundColor_: NSColor {
		if isOn {
			if self.isWindowInFocus {
				return NSColor.standardAccentColor
			}
			else {
				return NSColor.tertiaryLabelColor
			}
		}
		else {
			return self.isDarkMode ? NSColor.white.withAlphaComponent(0.1) : NSColor.black.withAlphaComponent(0.1)
		}
	}

	private var backgroundBorderColor_: NSColor {
		if self.isHighContrast {
			return self.isDarkMode ? NSColor.white.withAlphaComponent(0.7) : NSColor.black.withAlphaComponent(0.7)
		}
		else {
			return self.isDarkMode ? NSColor.white.withAlphaComponent(0.1) : NSColor.black.withAlphaComponent(0.1)
		}
	}

	// MARK: - Keyboard handling

	public override func becomeFirstResponder() -> Bool {
		self.needsDisplay = true
		return true
	}

	public override func resignFirstResponder() -> Bool {
		self.needsDisplay = true
		return true
	}

	public override func keyDown(with event: NSEvent) {
		if event.keyCode == 49 { // space bar
			toggle()
		} else {
			super.keyDown(with: event)
		}
	}

	// MARK: - Mouse Events

	public override func mouseDown(with event: NSEvent) {
		if !self.isEnabled { return super.mouseDown(with: event) }
		self.trackingMouseDown = true
		self.hasDragged = false
		self.dragStartPoint = convert(event.locationInWindow, from: nil)
		self.initialKnobX = knob.frame.origin.x
	}

	public override func mouseDragged(with event: NSEvent) {
		guard trackingMouseDown else { return }

		let location = convert(event.locationInWindow, from: nil)
		let dx = location.x - dragStartPoint.x

		if !hasDragged && abs(dx) >= 2 {
			hasDragged = true
		}

		guard hasDragged else { return }

		var newX = initialKnobX + dx
		let minX: CGFloat = 1
		let maxX: CGFloat = bounds.width - bounds.height + 1
		newX = min(max(newX, minX), maxX)

		CATransaction.begin()
		CATransaction.setDisableActions(true)
		knob.frame.origin.x = newX
		background.backgroundColor = knobCenterX() > bounds.width / 2 ? NSColor.standardAccentColor.cgColor : self.backgroundColor_.cgColor
		CATransaction.commit()
	}

	public override func mouseUp(with event: NSEvent) {
		guard self.trackingMouseDown else { return }
		self.trackingMouseDown = false

		if self.hasDragged {
			let newState = knobCenterX() > self.bounds.width / 2
			setOn(newState, animated: true)
		} else {
			toggle()
		}
	}

	private func knobCenterX() -> CGFloat {
		return knob.frame.origin.x + knob.bounds.width / 2
	}

	private func toggle() {
		setOn(!isOn, animated: true)
	}

	private func setOn(_ on: Bool, animated: Bool = true) {
		guard on != isOn else { return }
		if animated {
			self.state = on ? .on : .off
		} else {
			self.state = on ? .on : .off
			let knobX = on ? bounds.width - bounds.height + 1 : 1
			knob.frame.origin.x = knobX
			background.backgroundColor = on ? NSColor.standardAccentColor.cgColor : self.backgroundColor_.cgColor
		}
	}

	private func animateSwitch() {
		let knobX: CGFloat = isOn ? bounds.width - bounds.height + 1 : 1
		let newColor = isOn ? NSColor.standardAccentColor.cgColor : self.backgroundColor_.cgColor

		// Animate knob movement
		let anim = CABasicAnimation(keyPath: "position.x")
		anim.fromValue = knob.position.x
		anim.toValue = knobX + knob.bounds.width / 2
		anim.duration = 0.2
		anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
		knob.add(anim, forKey: "position")
		knob.position.x = knobX + knob.bounds.width / 2

		// Animate background color
		let colorAnim = CABasicAnimation(keyPath: "backgroundColor")
		colorAnim.fromValue = background.backgroundColor
		colorAnim.toValue = newColor
		colorAnim.duration = 0.2
		colorAnim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
		background.add(colorAnim, forKey: "color")
		background.backgroundColor = newColor
	}



	// MARK: - Accessibility

	public override func accessibilityRole() -> NSAccessibility.Role? {
		return .checkBox
	}

	public override func accessibilityValue() -> Any? {
		return isOn ? 1 : 0
	}

	public override func accessibilityPerformPress() -> Bool {
		if isEnabled {
			toggle()
			return true
		}
		return false
	}

	public override func accessibilityLabel() -> String? {
		return super.accessibilityLabel() ?? "Switch"
	}
}

// MARK: - Modifiers

@MainActor
public extension AUISwitch {
	/// Set the state for the control
	/// - Parameter state: The new state
	/// - Returns: self
	@discardableResult @inlinable
	func state(_ state: NSControl.StateValue) -> Self {
		self.state = state
		return self
	}

	/// Set the on/off state for the control
	/// - Parameter state: The new state
	/// - Returns: self
	@discardableResult @inlinable
	func state(_ state: Bool) -> Self {
		self.state = state ? .on : .off
		return self
	}
}

// MARK: - Actions

@MainActor
public extension AUISwitch {
	/// Set the block callback when the user interacts with the switch
	/// - Parameter block: The block to call, passing the new state
	/// - Returns: self
	@discardableResult
	func onAction(_ block: @escaping (NSControl.StateValue) -> Void) -> Self {
		self.usingStorage { $0.action = block }
		return self
	}
}

// MARK: - Bindings

@MainActor
public extension AUISwitch {
	@discardableResult
	func state(_ state: Bind<NSControl.StateValue>) -> Self {
		state.register(self) { @MainActor [weak self] newValue in
			if newValue != self?.state {
				self?.state = newValue
			}
		}
		self.state = state.wrappedValue

		self.usingStorage { h in
			h.state = state
		}

		return self
	}

	@discardableResult
	func state(_ state: Bind<Bool>) -> Self {
		state.register(self) { @MainActor [weak self] newValue in
			self?.state = newValue ? .on : .off
		}
		self.state = state.wrappedValue ? NSControl.StateValue.on : NSControl.StateValue.off

		self.usingStorage { h in
			h.onOffState = state
		}

		return self
	}
}

private extension AUISwitch {
	@MainActor class Storage {
		var onOffState: Bind<Bool>?
		var state: Bind<NSControl.StateValue>?
		var action: ((NSControl.StateValue) -> Void)?

		init(_ control: AUISwitch) {
			control.target = self
			control.action = #selector(actionCalled(_:))
		}

		deinit {
			os_log("deinit: AUISwitch.Storage", log: logger, type: .debug)
		}

		@objc func actionCalled(_ sender: AUISwitch) {
			self.state?.wrappedValue = sender.state
			self.onOffState?.wrappedValue = sender.state == .on
			self.action?(sender.state)
		}
	}

	func usingStorage(_ block: @escaping (Storage) -> Void) {
		self.usingAssociatedValue(key: "__auiswitchbond", initialValue: { Storage(self) }, block)
	}
}


// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("default") {
	let stateLarge = Bind(false)
	let stateRegular = Bind(false)
	let stateSmall = Bind(false)
	let stateMini = Bind(false)

	let enabled = Bind(true)

	NSView(layoutStyle: .centered) {
		VStack {
			NSButton.checkbox(title: "Enable Second Column")
				.state(enabled)
			NSGridView {
				NSGridView.Row {
					NSSwitch()
						.state(stateLarge)
						.controlSize(.large)
					AUISwitch()
						.state(stateLarge)
						.controlSize(.large)
						.isEnabled(enabled)
				}
				
				NSGridView.Row {
					NSSwitch()
						.state(stateRegular)
						.controlSize(.regular)
					AUISwitch()
						.state(stateRegular)
						.controlSize(.regular)
						.isEnabled(enabled)
				}
				NSGridView.Row {
					NSSwitch()
						.state(stateSmall)
						.controlSize(.small)
					AUISwitch()
						.state(stateSmall)
						.controlSize(.small)
						.isEnabled(enabled)
				}
				NSGridView.Row {
					NSSwitch()
						.state(stateMini)
						.controlSize(.mini)
					AUISwitch()
						.state(stateMini)
						.controlSize(.mini)
						.isEnabled(enabled)
				}
			}
		}
	}
	.padding()
}

#endif
