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

/// Methods for applying `CIFilter`s to a view
///
/// NOTE: if you apply a filter to a view and then change the filter's input parameters the result is undefined.
/// To change the filter you need to create a NEW filter and replace the existing one.
///
/// See: https://developer.apple.com/documentation/quartzcore/calayer/filters
@MainActor
public extension NSView {
	/// Set a filter to apply to the contents of this view's layer
	/// - Parameter filter: The filter
	/// - Returns: self
	@discardableResult @inlinable
	func filter(_ filter: CIFilter) -> Self {
		self.filters([filter])
	}

	/// Set an array of Core Image filters to apply to the contents of the layer and its sublayers
	/// - Parameter filters: The filters to apply
	@discardableResult
	func filters(_ filters: [CIFilter]) -> Self {
		self.assureWantsLayer()
		self.layer!.filters = filters
		return self
	}

	/// Set a filter to apply to the background of this view's layer
	/// - Parameter filter: The filter
	/// - Returns: self
	@discardableResult @inlinable
	func backgroundFilter(_ filter: CIFilter) -> Self {
		self.backgroundFilters([filter])
	}

	/// Set an array of Core Image filters to apply to the contents of the layer and its sublayers
	/// - Parameter filters: The filters to apply
	@discardableResult
	func backgroundFilters(_ filters: [CIFilter]) -> Self {
		self.assureWantsLayer()
		self.layer!.backgroundFilters = filters
		return self
	}
}

// MARK: - Bindings

@MainActor
public extension NSView {
	/// Set the filters to apply to the layer
	/// - Parameter filters: The filters binder
	/// - Returns: self
	@discardableResult
	func filters(_ filters: Bind<[CIFilter]>) -> Self {
		self.assureWantsLayer()
		filters.register(self) { @MainActor [weak self] newFilters in
			self?.layer!.filters = newFilters
		}
		self.layer!.filters = filters.wrappedValue
		return self
	}

	/// Set the filter to apply to the layer
	/// - Parameter filter: The filter binder
	/// - Returns: self
	@discardableResult @inlinable
	func filter(_ filter: Bind<CIFilter>) -> Self {
		self.filters(filter.oneWayTransform { [$0] })
	}

	/// Set the filters to apply to the layer
	/// - Parameter filters: The filters binder
	/// - Returns: self
	@discardableResult
	func backgroundFilters(_ filters: Bind<[CIFilter]>) -> Self {
		self.assureWantsLayer()
		filters.register(self) { @MainActor [weak self] newFilters in
			self?.layer!.backgroundFilters = newFilters
		}
		self.layer!.backgroundFilters = filters.wrappedValue
		return self
	}

	/// Set the filter to apply to the layer
	/// - Parameter filter: The filter binder
	/// - Returns: self
	@discardableResult @inlinable
	func backgroundFilter(_ filter: Bind<CIFilter>) -> Self {
		self.backgroundFilters(filter.oneWayTransform { [$0] })
	}
}

@MainActor
internal extension NSView {
	@inlinable func assureWantsLayer() {
		if self.layer == nil {
			self.wantsLayer = true
		}
	}
}

// MARK: - Previews

#if DEBUG

private let mono = CIFilter(name: "CIPhotoEffectMono", parameters: [:])!
private let sepia = CIFilter(name: "CISepiaTone", parameters: [:])!
private let boxBlur = CIFilter(name: "CIBoxBlur", parameters: [:])!
private let crystallize = CIFilter(name: "CICrystallize", parameters: [:])!

private func makeSepiaFilter(_ intensity: Double) -> CIFilter {
	CIFilter(name: "CISepiaTone", parameters: [ "inputIntensity": intensity ])!
}

@available(macOS 14, *)
#Preview("default") {
	VStack {
		HStack {
			AUIImage(named: NSImage.colorPanelName)
				.frame(dimension: 80)
			AUIImage(named: NSImage.colorPanelName)
				.frame(dimension: 80)
				.filter(sepia)
			AUIImage(named: NSImage.colorPanelName)
				.frame(dimension: 80)
				.filter(mono)
			AUIImage(named: NSImage.colorPanelName)
				.frame(dimension: 80)
				.filter(boxBlur)
			AUIImage(named: NSImage.colorPanelName)
				.frame(dimension: 80)
				.filter(crystallize)
		}

		HStack {
			let filter = Bind(makeSepiaFilter(0.25))
			let amount = Bind<Double>(0.25) { newValue in
				filter.wrappedValue = makeSepiaFilter(newValue)
			}

			AUIImage(named: NSImage.colorPanelName)
				.frame(dimension: 80)
				.filter(filter)
			NSSlider(amount, range: 0.0 ... 1.0)
				.width(300)
		}
	}
}

#endif
