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

import AppKit.NSFont

@MainActor
public extension NSFont {

	/// Return a copy of this font with the specified size
	func size(_ size: Double) -> NSFont {
		NSFont(descriptor: self.fontDescriptor, size: size) ?? (self.copy() as! NSFont)
	}

	/// The standard system font
	static let system = NSFont.systemFont(ofSize: NSFont.systemFontSize)
	/// A small system font
	static let systemSmall = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
	/// A mini system font
	static let systemMini = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize - 2)
	/// System font at label size
	static let label = NSFont.systemFont(ofSize: NSFont.labelFontSize)

	/// The font you use for body text.
	static let body = NSFont.systemFont(ofSize: NSFont.systemFontSize)                          // 13
	/// The font you use for callouts.
	static let callout = NSFont.systemFont(ofSize: NSFont.systemFontSize - 1)                   // 12
	/// The font you use for standard captions.
	static let caption1 = NSFont.systemFont(ofSize: NSFont.systemFontSize - 3)                  // 10
	/// The font you use for alternate captions.
	static let caption2 = NSFont.systemFont(ofSize: NSFont.systemFontSize - 2.5)                // Appears to be 10.5?
	/// The font you use in footnotes.
	static let footnote = NSFont.systemFont(ofSize: NSFont.systemFontSize - 4)                  // 10?
	/// The font you use for headings.
	static let headline = NSFont.systemFont(ofSize: NSFont.systemFontSize, weight: .semibold)   // 13
	/// The font you use for subheadings.
	static let subheadline = NSFont.systemFont(ofSize: NSFont.systemFontSize - 2)               // 11
	/// The font you use for large titles.
	static let largeTitle = NSFont.systemFont(ofSize: NSFont.systemFontSize + 13)               // 26
	/// The font you use for first-level hierarchical headings.
	static let title1 = NSFont.systemFont(ofSize: NSFont.systemFontSize + 9)                    // 22
	/// The font you use for second-level hierarchical headings.
	static let title2 = NSFont.systemFont(ofSize: NSFont.systemFontSize + 4)                    // 17
	/// The font you use for third-level hierarchical headings.
	static let title3 = NSFont.systemFont(ofSize: NSFont.systemFontSize + 2)                    // 15
	/// A font with monospaced digits
	static let monospacedDigit = NSFont.monospacedDigitSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
	/// The font to use for monospaced text
	static let monospaced: NSFont = {
		if #available(macOS 10.15, *) {
			return NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
		}
		else {
			let f = NSFont.systemFont(ofSize: NSFont.systemFontSize)
			let descriptor = f.fontDescriptor.withSymbolicTraits(.monoSpace)
			return NSFont(descriptor: descriptor, size: NSFont.systemFontSize)!
		}
	}()
}

@MainActor
public extension NSFont {
	/// A bold representation of this font
	var bold: NSFont { self.withSymbolicTraits(.bold) }
	/// An italic representation of this font
	var italic: NSFont { self.withSymbolicTraits(.italic) }
	/// An condensed representation of this font
	var condensed: NSFont { self.withSymbolicTraits(.condensed) }
	/// An condensed representation of this font
	var expanded: NSFont { self.withSymbolicTraits(.expanded) }

	/// Return a copy of this font with the specified symbolic traits
	/// - Parameter traits: The traits to apply
	/// - Returns: A new NSFont
	func traits(_ traits: NSFontDescriptor.SymbolicTraits) -> NSFont {
		self.withSymbolicTraits(traits)
	}

	/// Returns a weight variant of this font
	func weight(_ weight: NSFont.Weight) -> NSFont {
		self.addingAttributes([
			NSFontDescriptor.AttributeName.traits: [
				NSFontDescriptor.TraitKey.weight: weight.rawValue,
			],
		])
	}
}

@MainActor
private extension NSFont {
	private func withSymbolicTraits(_ traits: NSFontDescriptor.SymbolicTraits) -> NSFont {
		var currentTraits = self.fontDescriptor.symbolicTraits
		currentTraits.insert(traits)
		let descriptor = self.fontDescriptor.withSymbolicTraits(currentTraits)
		return NSFont(descriptor: descriptor, size: self.pointSize) ?? (self.copy() as! NSFont)
	}

	private func addingAttributes(_ attributes: [NSFontDescriptor.AttributeName: Any]) -> NSFont {
		let descriptor = self.fontDescriptor.addingAttributes(attributes)
		return NSFont(descriptor: descriptor, size: self.pointSize) ?? (self.copy() as! NSFont)
	}
}


// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("Defined Fonts") {
	let _sampleText = "Sphinx of black quartz judge my vow (19.330)"
	NSGridView {
		NSGridView.Row {
			NSTextField(label: ".system")
				.font(.monospaced)
			NSTextField(label: _sampleText)
				.font(.system)
				.truncatesLastVisibleLine(true)
		}
		NSGridView.Row {
			NSTextField(label: ".systemSmall")
				.font(.monospaced)
			NSTextField(label: _sampleText)
				.font(.systemSmall)
		}

		NSGridView.Row {
			NSTextField(label: ".systemMini")
				.font(.monospaced)
			NSTextField(label: _sampleText)
				.font(.systemMini)
		}

		NSGridView.Row {
			NSTextField(label: ".body")
				.font(.monospaced)
			NSTextField(label: _sampleText)
				.font(.body)
		}
		NSGridView.Row {
			NSTextField(label: ".callout")
				.font(.monospaced)
			NSTextField(label: _sampleText)
				.font(.callout)
		}
		NSGridView.Row {
			NSTextField(label: ".caption1")
				.font(.monospaced)
			NSTextField(label: _sampleText)
				.font(.caption1)
		}
		NSGridView.Row {
			NSTextField(label: ".caption2")
				.font(.monospaced)
			NSTextField(label: _sampleText)
				.font(.caption2)
		}
		NSGridView.Row {
			NSTextField(label: ".footnote")
				.font(.monospaced)
			NSTextField(label: _sampleText)
				.font(.footnote)
		}
		NSGridView.Row {
			NSTextField(label: ".headline")
				.font(.monospaced)
			NSTextField(label: _sampleText)
				.font(.headline)
		}
		NSGridView.Row {
			NSTextField(label: ".subheadline")
				.font(.monospaced)
			NSTextField(label: _sampleText)
				.font(.subheadline)
		}
		NSGridView.Row {
			NSTextField(label: ".largeTitle")
				.font(.monospaced)
			NSTextField(label: _sampleText)
				.font(.largeTitle)
				.lineBreakMode(.byTruncatingTail)
				.truncatesLastVisibleLine(true)
		}
		NSGridView.Row {
			NSTextField(label: ".title1")
				.font(.monospaced)
			NSTextField(label: _sampleText)
				.font(.title1)
		}
		NSGridView.Row {
			NSTextField(label: ".title2")
				.font(.monospaced)
			NSTextField(label: _sampleText)
				.font(.title2)
		}
		NSGridView.Row {
			NSTextField(label: ".title3")
				.font(.monospaced)
			NSTextField(label: _sampleText)
				.font(.title3)
		}

		NSGridView.Row {
			NSTextField(label: ".monospaced")
				.font(.monospaced)
			NSTextField(label: _sampleText)
				.font(.monospaced)
		}

		NSGridView.Row {
			NSTextField(label: ".monospacedDigit")
				.font(.monospaced)
			NSTextField(label: _sampleText)
				.font(.monospacedDigit)
		}
	}
	.rowAlignment(.firstBaseline)
	.padding(top: 34, left: 20, bottom: 20, right: 20)
}


@available(macOS 14, *)
#Preview("Font Weights") {
	let _sampleText = "Sphinx of black quartz judge my vow (19.330)"
	VStack {
		NSGridView {
			NSGridView.Row {
				NSTextField(label: ".ultraLight")
					.font(.monospaced)
				NSTextField(label: _sampleText)
					.font(.system.weight(.ultraLight))
			}
			NSGridView.Row {
				NSTextField(label: ".thin")
					.font(.monospaced)
				NSTextField(label: _sampleText)
					.font(.system.weight(.thin))
			}
			NSGridView.Row {
				NSTextField(label: ".light")
					.font(.monospaced)
				NSTextField(label: _sampleText)
					.font(.system.weight(.light))
			}
			NSGridView.Row {
				NSTextField(label: ".regular")
					.font(.monospaced)
				NSTextField(label: _sampleText)
					.font(.system.weight(.regular))
			}
			NSGridView.Row {
				NSTextField(label: ".medium")
					.font(.monospaced)
				NSTextField(label: _sampleText)
					.font(.system.weight(.medium))
			}
			NSGridView.Row {
				NSTextField(label: ".semibold")
					.font(.monospaced)
				NSTextField(label: _sampleText)
					.font(.system.weight(.semibold))
			}
			NSGridView.Row {
				NSTextField(label: ".bold")
					.font(.monospaced)
				NSTextField(label: _sampleText)
					.font(.system.weight(.bold))
			}
			NSGridView.Row {
				NSTextField(label: ".heavy")
					.font(.monospaced)
				NSTextField(label: _sampleText)
					.font(.system.weight(.heavy))
			}
			NSGridView.Row {
				NSTextField(label: ".black")
					.font(.monospaced)
				NSTextField(label: _sampleText)
					.font(.system.weight(.black))
			}
		}
	}
}

@available(macOS 14, *)
#Preview("Font Size") {
	let _sampleText = "Sphinx of black quartz judge my vow"
	NSGridView(yPlacement: .center) {
		NSGridView.Row {
			NSTextField(label: "9")
				.font(.monospaced)
			NSTextField(label: _sampleText)
				.font(.system.size(9))
		}
		NSGridView.Row {
			NSTextField(label: "11")
				.font(.monospaced)
			NSTextField(label: _sampleText)
				.font(.system.size(11))
		}
		NSGridView.Row {
			NSTextField(label: "13")
				.font(.monospaced)
			NSTextField(label: _sampleText)
				.font(.system.size(13))
		}
		NSGridView.Row {
			NSTextField(label: "16")
				.font(.monospaced)
			NSTextField(label: _sampleText)
				.font(.system.size(16))
		}
		NSGridView.Row {
			NSTextField(label: "24")
				.font(.monospaced)
			NSTextField(label: _sampleText)
				.font(.system.size(24))
				.lineBreakMode(.byTruncatingTail)
				.compressionResistancePriority(.defaultLow, for: .horizontal)
		}
		NSGridView.Row {
			NSTextField(label: "48")
				.font(.monospaced)
			NSTextField(label: _sampleText)
				.font(.system.size(48))
				.lineBreakMode(.byTruncatingTail)
				.compressionResistancePriority(.defaultLow, for: .horizontal)
		}
		NSGridView.Row {
			NSTextField(label: "96")
				.font(.monospaced)
			NSTextField(label: _sampleText)
				.font(.system.size(96))
				.lineBreakMode(.byTruncatingTail)
				.compressionResistancePriority(.defaultLow, for: .horizontal)
		}
	}
	.padding()
}

#endif
