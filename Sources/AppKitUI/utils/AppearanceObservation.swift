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

// A simple application appearance observer

@MainActor
class AppearanceObservation {
	init() {
		if #available(macOS 10.14, *) {
			// Start observing straight away
			self.observer = NSApp.observe(\.effectiveAppearance, options: [.new, .initial]) { [weak self] app, change in
				DispatchQueue.main.async {
					self?.reflectObservers()
				}
			}
		}
	}

	deinit {
		os_log("deinit: AppearanceObservation", log: logger, type: .debug)
	}

	/// Add a block to call when the appearance for the application changes
	/// - Parameter block: The block to call
	func registerAppearanceHandler(_ block: @escaping () -> Void) {
		assert(Thread.isMainThread)
		self.observations.append(block)
	}

	/// Called when the app's effective appearance has changed
	private func reflectObservers() {
		assert(Thread.isMainThread)
		self.observations.forEach { block in
			block()
		}
	}

	private var observer: NSKeyValueObservation? = nil
	private var observations: [() -> Void] = []
}
