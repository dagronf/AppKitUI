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

// NSView appearance routines

@available(macOS 10.14, *)
private let darkMode__ = NSAppearance(named: .darkAqua)!
private let lightMode__ = NSAppearance(named: .aqua)!

// MARK: - Modifiers

@MainActor
public extension NSView {
	/// Set the dark mode state for the view
	/// - Parameter value: If true, mark the view appearance as dark mode
	/// - Returns: self
	@discardableResult
	func isDarkMode(_ value: Bool) -> Self {
		if #available(macOS 10.14, *) {
			CATransaction.setDisableActions(true)
			self.appearance = value ? darkMode__ : lightMode__
		}
		else {
			self.appearance = lightMode__
		}
		return self
	}
}

// MARK: - Bindings

@MainActor
public extension NSView {
	/// Set the dark mode state for the view
	/// - Parameter value: The dark mode binding for the view
	/// - Returns: self
	@discardableResult
	func isDarkMode(_ value: Bind<Bool>) -> Self {
		guard #available(macOS 10.14, *) else { return self }
		value.register(self) { @MainActor [weak self] newState in
			self?.isDarkMode(newState)
		}
		self.isDarkMode(value.wrappedValue)
		return self
	}
}

// MARK: - Actions

@MainActor
public extension NSView {
	/// Call a block when the **application's** appearance changes
	/// - Parameter block: The block to call
	/// - Returns: self
	func onAppearanceChange(_ block: @escaping () -> Void) -> Self {
		self.usingViewStorage {
			$0.registerApplicationAppearanceHandler(block)
		}
		return self
	}

	/// Call a block when this **view's** appearance changes
	/// - Parameter block: The block to call
	/// - Returns: self
	///
	/// If all you need is to detect the application's appearance changing
	/// then it's more performant to use `onAppearanceChange` instead
	@discardableResult
	func onViewAppearanceChange(_ block: @escaping () -> Void) -> Self {
		self.usingViewStorage {
			$0.registerAppearanceHandler(block)
		}
		return self
	}
}
