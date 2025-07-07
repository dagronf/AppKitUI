//
//  NSTokenField+appkitui.swift
//  AppKitUI
//
//  Created by Darren Ford on 19/7/2025.
//

import AppKit

/// A string-based Token Field that expands vertically to fit the content as needed
@MainActor
public extension NSTokenField {
	/// Create a TokenField
	/// - Parameters:
	///   - tokenStyle: The token style
	///   - content: The content to display as tokens. Each string in the array becomes a separate token in the field
	///   - updateOnEndEditingOnly: If true, only updates the binding content when the user ends editing in the field
	convenience init(
		tokenStyle: NSTokenField.TokenStyle = .default,
		content: Bind<[String]>,
		updateOnEndEditingOnly: Bool = false
	) {
		self.init()
		self.content(content)
	}
}

// MARK: - Actions

@MainActor
public extension NSTokenField {
	/// Called when the tokens change
	/// - Parameter block: The block to call when the tokens change
	/// - Returns: self
	@discardableResult
	func onChangeTokens(_ block: @escaping ([String]) -> Void) -> Self {
		self.usingTokenFieldStorage { $0.onChangeTokens = block }
		return self
	}

	/// Provide completions for a given string
	/// - Parameter completionsBlock: The completion block
	/// - Returns: self
	@discardableResult
	func completions(_ completionsBlock: @escaping (String) -> [String]) -> Self {
		self.usingTokenFieldStorage { $0.completionsBlock = completionsBlock }
		return self
	}

	/// Called to validate new token(s) before it they are added to the control
	/// - Parameter block: The validation block (passing the suggested token strings and the index where the token will be added)
	/// - Returns: self
	@discardableResult
	func onValidateAddToken(_ block: @escaping ([String], Int) -> [String]) -> Self {
		self.usingTokenFieldStorage { $0.onValidateAddTokenBlocks = block }
		return self
	}

	/// Does the specified token have a menu attached?
	/// - Parameter block: A block that returns true if the token has a menu attached
	/// - Returns: self
	@discardableResult
	func hasMenuForToken(_ block: @escaping (String) -> Bool) -> Self {
		self.usingTokenFieldStorage { $0.hasMenuForTokenBlock = block }
		return self
	}

	/// The menu for the specified token
	/// - Parameter menuBlock: A block that returns the menu associated with the particular token
	/// - Returns: self
	@discardableResult
	func menuForToken(_ menuBlock: @escaping (String) -> NSMenu?) -> Self {
		self.usingTokenFieldStorage { $0.menuForTokenBlock = menuBlock }
		return self
	}
}

// MARK: - Binding

@MainActor
public extension NSTokenField {

	/// Set the content for the token field
	/// - Parameter content: The content binding
	/// - Returns: self
	@discardableResult
	func content(_ content: Bind<[String]>) -> Self {
		self.onEndEditing { [weak self] _ in
			content.wrappedValue = (self?.objectValue as? [String]) ?? []
		}

		self.usingTokenFieldStorage { $0.content = content }

		self.objectValue = content.wrappedValue
		return self
	}
}

// MARK: - Storage

fileprivate extension NSTokenField {
	func usingTokenFieldStorage(_ block: @escaping (Storage) -> Void) {
		self.usingAssociatedValue(key: "__nstokenfield_bond", initialValue: { Storage(self) }, block)
	}

	@MainActor
	class Storage: NSObject, NSTokenFieldDelegate, @unchecked Sendable {
		weak var parent: NSTokenField?
		var content: Bind<[String]>?
		var onChangeTokens: (([String]) -> Void)?
		var completionsBlock: ((String) -> [String])?
		var onValidateAddTokenBlocks: (([String], Int) -> [String])?
		var hasMenuForTokenBlock: ((String) -> Bool)?
		var menuForTokenBlock: ((String) -> NSMenu?)?

		init(_ parent: NSTokenField) {
			self.parent = parent
			super.init()
			parent.delegate = self
		}
	}
}

fileprivate extension NSTokenField.Storage {
	func control(
		_ control: NSControl,
		textView: NSTextView,
		doCommandBy commandSelector: Selector
	) -> Bool {
		if commandSelector == #selector(NSTokenField.insertNewline(_:)) {
			if let newValue = self.parent?.objectValue as? [String] {
				self.content?.wrappedValue = newValue
				self.onChangeTokens?(newValue)
			}
		}
		return false
	}

	func tokenField(
		_ tokenField: NSTokenField,
		completionsForSubstring substring: String,
		indexOfToken tokenIndex: Int,
		indexOfSelectedItem selectedIndex: UnsafeMutablePointer<Int>?
	) -> [Any]? {
		guard let completionsBlock else { return nil }
		selectedIndex?.pointee = -1
		return completionsBlock(substring)
	}

	func tokenField(_ tokenField: NSTokenField, shouldAdd tokens: [Any], at index: Int) -> [Any] {
		guard let onValidateAddTokenBlocks else {
			return tokens
		}
		let tokens = tokens.map { $0 as! String }
		return onValidateAddTokenBlocks(tokens, index)
	}
}

fileprivate extension NSTokenField.Storage {
	func tokenField(_ tokenField: NSTokenField, hasMenuForRepresentedObject representedObject: Any) -> Bool {
		guard
			let fn = self.hasMenuForTokenBlock,
			let str = representedObject as? String
		else {
			return false
		}
		return fn(str)
	}

	func tokenField(_ tokenField: NSTokenField, menuForRepresentedObject representedObject: Any) -> NSMenu? {
		guard
			let fn = self.menuForTokenBlock,
			let str = representedObject as? String
		else {
			return nil
		}
		return fn(str)
	}
}

#if DEBUG
@available(macOS 14, *)
#Preview("default") {
	let tokenField = Bind<[String]>(["red", "green", "blue", "cyan", "magenta", "yellow"])
	let tokenField3 = Bind<[String]>(["Australia", "Isle of Man", "Wallis & Futuna"])
	let autocompleteValues = allCountries().sorted(by: <)
	let emailTokens = Bind<[String]>(["caterpillar@womble.com", "flutterby@womble.com"])

	VStack {
		NSBox(title: "TokenField update on end editing only") {
			VStack {
				NSTokenField(content: tokenField)
					.wraps(true)
					.lineBreakMode(.byWordWrapping)
					.truncatesLastVisibleLine(false)
					.huggingPriority(.init(1), for: .horizontal)
					.compressionResistancePriority(.defaultLow, for: .horizontal)

				HStack(alignment: .firstBaseline) {
					NSTextField(label: "Tokens:")
						.font(.system.bold)
					NSTextField(label: tokenField.stringValue())
						.huggingPriority(.init(1), for: .horizontal)
						.compressionResistancePriority(.defaultLow, for: .horizontal)
				}
			}
		}
		.huggingPriority(.init(1), for: .horizontal)

		NSBox(title: "TokenField with completions (basic web color names)") {
			VStack {
				NSTokenField(content: tokenField3)
					.wraps(true)
					.lineBreakMode(.byWordWrapping)
					.truncatesLastVisibleLine(false)
					.completions { str in autocompleteValues.filter { $0.localizedCaseInsensitiveContains(str) } }
					.huggingPriority(.init(1), for: .horizontal)
					.compressionResistancePriority(.defaultLow, for: .horizontal)

				HStack(alignment: .firstBaseline) {
					NSTextField(label: "Tokens:")
						.font(.system.bold)

					NSTextField(label: tokenField3.stringValue())
						.huggingPriority(.init(1), for: .horizontal)
						.compressionResistancePriority(.defaultLow, for: .horizontal)
				}
			}
		}
		.huggingPriority(.init(1), for: .horizontal)

		NSBox(title: "TokenField with menus") {
			VStack {
				NSTokenField(content: emailTokens)
					.wraps(true)
					.lineBreakMode(.byWordWrapping)
					.truncatesLastVisibleLine(false)
					.hasMenuForToken { _ in true }
					.menuForToken { token in
						NSMenu(title: "email actions") {
							NSMenuItem(title: "Send email…") { token in
								let alert = NSAlert()
								alert.messageText = "Sending email to '\(token)'"
								alert.runModal()
							}
							NSMenuItem(title: "Send file…") { token in
								let alert = NSAlert()
								alert.messageText = "Sending file to '\(token)'"
								alert.runModal()
							}
							NSMenuItem.separator()
							NSMenuItem(title: "Delete contact…") { token in
								let alert = NSAlert()
								alert.messageText = "Deleting contact '\(token)'"
								alert.runModal()
							}
						}
					}

					.huggingPriority(.init(1), for: .horizontal)
					.compressionResistancePriority(.defaultLow, for: .horizontal)

				HStack(alignment: .firstBaseline) {
					NSTextField(label: "Tokens:")
						.font(.system.bold)

					NSTextField(label: tokenField3.stringValue())
						.huggingPriority(.init(1), for: .horizontal)
						.compressionResistancePriority(.defaultLow, for: .horizontal)
				}
			}
		}
		.huggingPriority(.init(1), for: .horizontal)
	}
	.distribution(.fill)
	.padding()
}

func allCountries() -> [String] {
	let bg = NSLocale.current as NSLocale
	return NSLocale.isoCountryCodes.compactMap { bg.displayName(forKey: .countryCode, value: $0) }
}

#endif
