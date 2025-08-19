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

import AppKit.NSDatePicker
import os.log

@MainActor
public extension NSDatePicker {
	/// Create a date picker
	/// - Parameters:
	///   - date: The binding for the date
	///   - style: The date picker style
	///   - elements: The elements to display in the picker
	convenience init(date: Bind<Date>, style: NSDatePicker.Style? = nil, elements: NSDatePicker.ElementFlags? = nil) {
		self.init()
		self.date(date)
		self.dateValue = date.wrappedValue
		if let style {
			self.datePickerStyle = style
		}
		if let elements {
			self.datePickerElements = elements
		}
	}

	/// Create a date picker
	/// - Parameters:
	///   - date: The date to initially display
	///   - style: The date picker style
	///   - elements: The elements to display in the picker
	convenience init(date: Date, style: NSDatePicker.Style? = nil, elements: NSDatePicker.ElementFlags? = nil) {
		self.init()
		self.dateValue = date
		if let style {
			self.datePickerStyle = style
		}
		if let elements {
			self.datePickerElements = elements
		}
	}
}

// MARK: - Modifiers

public extension NSDatePicker {
	/// Set the date
	/// - Parameter date: The date
	/// - Returns: self
	@discardableResult @inlinable
	func date(_ date: Date) -> Self {
		self.dateValue = date
		return self
	}

	/// The calendar used by the date picker.
	/// - Parameter calendar: The calendar
	/// - Returns: self
	@discardableResult @inlinable
	func calendar(_ calendar: Calendar) -> Self {
		self.calendar = calendar
		return self
	}

	/// The date picker style
	/// - Parameter style: The style
	/// - Returns: self
	@discardableResult @inlinable
	func style(_ style: NSDatePicker.Style) -> Self {
		self.datePickerStyle = style
		return self
	}

	/// The elements to display within the control
	/// - Parameter elements: The date picker element flags
	/// - Returns: self
	@discardableResult @inlinable
	func elements(_ elements: NSDatePicker.ElementFlags) -> Self {
		self.datePickerElements = elements
		return self
	}

	/// The locale for the control
	/// - Parameter locale: The locale
	/// - Returns: self
	@discardableResult @inlinable
	func locale(_ locale: Locale) -> Self {
		self.locale = locale
		return self
	}

	/// The time zone for the conrol
	/// - Parameter zone: The time zone
	/// - Returns: self
	@discardableResult @inlinable
	func timeZone(_ zone: TimeZone) -> Self {
		self.timeZone = zone
		return self
	}

	/// Set the date range for the picker
	/// - Parameter range: The date range
	/// - Returns: self
	@discardableResult @inlinable
	func range(_ range: ClosedRange<Date>) -> Self {
		self.minDate = range.lowerBound
		self.maxDate = range.upperBound
		return self
	}

	/// The text color
	/// - Parameter color: The color
	/// - Returns: self
	@discardableResult @inlinable
	func textColor(_ color: NSColor) -> Self {
		self.textColor = color
		return self
	}

	/// Present a graphical calendar overlay when editing a calendar element within a text-field style date picker
	/// - Parameter value: If true presents the calendar overlay
	/// - Returns: self
	@available(macOS 10.15.4, *)
	@discardableResult @inlinable
	func presentsCalendarOverlay(_ value: Bool) -> Self {
		self.presentsCalendarOverlay = value
		return self
	}
}

// MARK: - Actions

@MainActor
public extension NSDatePicker {
	/// A block that gets called when the date changes
	/// - Parameter onDateChange: The block to call
	/// - Returns: self
	@discardableResult
	func onDateChange(_ onDateChange: @escaping (Date) -> Void) -> Self {
		self.usingDatePickerStorage { $0.onDateChange = onDateChange }
		return self
	}

	/// Provide a function to validate the date/time interval when the user changes
	/// - Parameter block: The validation block
	/// - Returns: self
	func validateDateChange(_ block: @escaping (Date, TimeInterval?) -> (Date?, TimeInterval?)) -> Self {
		self.usingDatePickerStorage { $0.validateDateChange = block }
		return self
	}
}

// MARK: - Bindings

@MainActor
public extension NSDatePicker {
	@discardableResult
	func date(_ date: Bind<Date>) -> Self {
		date.register(self) { @MainActor [weak self] newDate in
			guard let `self` = self else { return }
			if self.dateValue != newDate {
				self.dateValue = newDate
			}
		}
		self.usingDatePickerStorage { $0.date = date }
		self.dateValue = date.wrappedValue
		return self
	}

	/// Bind the locale
	/// - Parameter locale: The locale binding
	/// - Returns: self
	@discardableResult
	func locale(_ locale: Bind<Locale>) -> Self {
		locale.register(self) { @MainActor [weak self] newValue in
			self?.locale = newValue
		}
		self.locale = locale.wrappedValue
		return self
	}

	/// Bind the time zone
	/// - Parameter timeZone: The time zone binding
	/// - Returns: self
	@discardableResult
	func timeZone(_ timeZone: Bind<TimeZone>) -> Self {
		timeZone.register(self) { @MainActor [weak self] newValue in
			self?.timeZone = newValue
		}
		self.timeZone = timeZone.wrappedValue
		return self
	}
}

@MainActor
private extension NSDatePicker {
	func usingDatePickerStorage(_ block: @escaping (Storage) -> Void) {
		self.usingAssociatedValue(key: "__nsdatepickerbond", initialValue: { Storage(self) }, block)
	}

	@MainActor class Storage: NSObject, NSDatePickerCellDelegate {
		var date: Bind<Date>?
		var onDateChange: ((Date) -> Void)?
		var validateDateChange: ((Date, TimeInterval?) -> (Date?, TimeInterval?))?

		init(_ control: NSDatePicker) {
			super.init()

			control.delegate = self
			control.target = self
			control.action = #selector(actionCalled(_:))
		}

		deinit {
			os_log("deinit: NSDatePicker.Storage", log: logger, type: .debug)
		}

		@MainActor @objc func actionCalled(_ sender: NSDatePicker) {
			self.date?.wrappedValue = sender.dateValue
			self.onDateChange?(sender.dateValue)
		}

		func datePickerCell(
			_ datePickerCell: NSDatePickerCell,
			validateProposedDateValue proposedDateValue: AutoreleasingUnsafeMutablePointer<NSDate>,
			timeInterval proposedTimeInterval: UnsafeMutablePointer<TimeInterval>?
		) {
			if let onValidate = self.validateDateChange {
				let d: Date = proposedDateValue.pointee as Date
				let t: TimeInterval? = proposedTimeInterval?.pointee
				let r = onValidate(d, t)
				if let newDate = r.0 { proposedDateValue.pointee = newDate as NSDate }
				if let newTimeInterval = r.1 { proposedTimeInterval?.pointee = newTimeInterval }
			}
		}
	}
}

// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("default") {
	let fixedDate = Date()
	let date = Bind(Date())
	VStack {
		NSDatePicker(date: date)
			.onDateChange { Swift.print("Date changed -> \($0)")}

		NSDatePicker(date: date)
			.locale(Locale.current)
			.timeZone(TimeZone(identifier: "GMT")!)
			.textColor(.systemBlue)
			.presentsCalendarOverlay(true)

		NSDatePicker(date: date)
			.validateDateChange { d, t in
				if d < fixedDate {
					return (fixedDate, nil)
				}
				return (nil, nil)
			}

		VStack {
			NSGridView {
				NSGridView.Row(rowAlignment: .firstBaseline) {
					NSTextField(label: "Year Month")
					NSDatePicker(date: date, elements: .yearMonth)
				}
				NSGridView.Row(rowAlignment: .firstBaseline) {
					NSTextField(label: "Year Month Day")
					NSDatePicker(date: date, elements: .yearMonthDay)
				}
				NSGridView.Row(rowAlignment: .firstBaseline) {
					NSTextField(label: "Hour Minute Second")
					NSDatePicker(date: date, elements: .hourMinuteSecond)
				}
				NSGridView.Row(rowAlignment: .firstBaseline) {
					NSTextField(label: "Year Month Hour Minute")
					NSDatePicker(date: date, elements: [.hourMinute, .yearMonth])
				}
			}
		}
	}
}

@available(macOS 14, *)
#Preview("calendar") {
	let date = Bind(Date())
	VStack {
		NSDatePicker(date: date, style: .clockAndCalendar)
		NSGridView(yPlacement: .center) {
			NSGridView.Row {
				NSTextField(label: "Calendar only")
					.font(.title2.bold)
				NSTextField(label: "Clock only")
					.font(.title2.bold)
			}
			NSGridView.Row {
				NSDatePicker(date: date, style: .clockAndCalendar)
					.elements([.yearMonthDay])
					.timeZone(.gmt)
				NSDatePicker(date: date, style: .clockAndCalendar)
					.elements([.hourMinuteSecond])
					.timeZone(.gmt)
			}
		}
		.columnAlignment(.center, forColumns: 0 ... 1)
	}
	.onChange(date) { Swift.print($0) }
	.debugFrames()
}

func offset(for timeZone: TimeZone) -> String {
	var seconds = timeZone.secondsFromGMT()

	var result = "UTC"
	if seconds == 0 {
		return "UTC"
	}
	else if seconds < 0 {
		result += " -"
		seconds = abs(seconds)
	}
	else {
		result += " +"
	}

	let hrs: Int = seconds / 3600
	let mins: Int = (seconds % 3600) / 60

	result += "\(hrs)"
	if mins > 0 {
		result += ":"
		let m = String(format: "%02d", mins)
		result += m
	}

	return result
}

@available(macOS 14, *)
#Preview("timezones") {
	let date = Bind(Date())

	let local = TimeZone.current
	let gmt = TimeZone.gmt
	let newYork = TimeZone(identifier: "America/New_York")!
	let london = TimeZone(identifier: "Europe/London")!
	let nepal = TimeZone(identifier: "Asia/Kathmandu")!
	let newfoundland = TimeZone(identifier: "America/Goose_Bay")!
	let adelaide = TimeZone(identifier: "Australia/Adelaide")!
	let taiohae = TimeZone(identifier: "Pacific/Marquesas")!
	let timezones = [local, gmt, newYork, london, nepal, newfoundland, adelaide, taiohae]

	VStack {
		NSGridView(
			rows: timezones.map { tz in
				NSGridView.Row {
					NSTextField(label: tz.identifier + ":")
						.font(.system.weight(.medium))
					NSDatePicker(date: date)
						.timeZone(tz)
					NSTextField(label: "\(offset(for: tz))")
						.font(.monospaced.bold)
				}
			}
		)
		.rowAlignment(.firstBaseline)
		.columnAlignment(.trailing, forColumn: 0)

		NSButton(title: "reset") { _ in
			date.wrappedValue = Date()
		}
	}
}

#endif

