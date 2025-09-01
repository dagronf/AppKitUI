//
//  ButtonPane.swift
//  AppKitUI Demo
//
//  Created by Darren Ford on 17/7/2025.
//

import AppKit
import AppKitUI

private let __dummyText = """
In my younger and more vulnerable years my father gave me some advice that I’ve been turning over in my mind ever since.

“Whenever you feel like criticizing anyone,” he told me, “just remember that all the people in this world haven’t had the advantages that you’ve had.”

He didn’t say any more, but we’ve always been unusually communicative in a reserved way, and I understood that he meant a great deal more than that. In consequence, I’m inclined to reserve all judgements, a habit that has opened up many curious natures to me and also made me the victim of not a few veteran bores. The abnormal mind is quick to detect and attach itself to this quality when it appears in a normal person, and so it came about that in college I was unjustly accused of being a politician, because I was privy to the secret griefs of wild, unknown men. Most of the confidences were unsought—frequently I have feigned sleep, preoccupation, or a hostile levity when I realized by some unmistakable sign that an intimate revelation was quivering on the horizon; for the intimate revelations of young men, or at least the terms in which they express them, are usually plagiaristic and marred by obvious suppressions. Reserving judgements is a matter of infinite hope. I am still a little afraid of missing something if I forget that, as my father snobbishly suggested, and I snobbishly repeat, a sense of the fundamental decencies is parcelled out unequally at birth.

And, after boasting this way of my tolerance, I come to the admission that it has a limit. Conduct may be founded on the hard rock or the wet marshes, but after a certain point I don’t care what it’s founded on. When I came back from the East last autumn I felt that I wanted the world to be in uniform and at a sort of moral attention forever; I wanted no more riotous excursions with privileged glimpses into the human heart. Only Gatsby, the man who gives his name to this book, was exempt from my reaction—Gatsby, who represented everything for which I have an unaffected scorn. If personality is an unbroken series of successful gestures, then there was something gorgeous about him, some heightened sensitivity to the promises of life, as if he were related to one of those intricate machines that register earthquakes ten thousand miles away. This responsiveness had nothing to do with that flabby impressionability which is dignified under the name of the “creative temperament”—it was an extraordinary gift for hope, a romantic readiness such as I have never found in any other person and which it is not likely I shall ever find again. No—Gatsby turned out all right at the end; it is what preyed on Gatsby, what foul dust floated in the wake of his dreams that temporarily closed out my interest in the abortive sorrows and short-winded elations of men.
"""

class PlainTextPane: Pane {
	override func title() -> String { "Plain Text" }

	override func make(model: Model) -> NSView {
		let _textValue = Bind(__dummyText)
		let _wrapText = Bind(true)
		let _isEditable = Bind(false)
		let _isSelectable = Bind(true)
		let _selectedRange = Bind(NSRange.empty)
		let _selectedRangeString = Bind("")
		return VStack {
			HStack {
				NSButton.checkbox(title: "Wraps")
					.state(_wrapText)
				NSButton.checkbox(title: "Editable")
					.state(_isEditable)
				NSButton.checkbox(title: "Selectable")
					.state(_isSelectable)

				VDivider()

				HStack {
					NSTextField(label: "Selection:")
					NSTextField(content: _selectedRangeString)
						.width(80)
				}
				.isHidden(_isSelectable.toggled())

				NSView.Spacer()
			}
			.onChange(_selectedRange) { @MainActor newValue in
				_selectedRangeString.wrappedValue = "\(newValue)"
			}

			HDivider()

			AUIScrollingTextView(text: _textValue)
				.isEditable(_isEditable)
				.isSelectable(_isSelectable)
				.wrapsLines(_wrapText)
				.font(.monospaced)
				.selectedRange(_selectedRange)
		}
		.padding()
	}
}

#if DEBUG
@available(macOS 14, *)
#Preview("default") {
	PlainTextPane().make(model: Model())
		//.frame(width: 320, height: 200)
}
#endif
