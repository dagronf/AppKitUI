# AppKitUI

An AppKit UI toolkit help you create and manage `NSView` content easily 

1. Remove dependence on requiring XIBs when creating UI views
2. Reduce boilerplate code when manually creating `NSView` UI content.
3. Easily bind data between controls

There is a demo application in the 'Demo' folder that demonstrates many of the controls and features of this package. 

Note that this beta level code!  Feedback and bug reports are always appreciated.

## Features

* Chainable properties for most AppKit NS- UI controls.
* Preview your AppKitUI user interface directly in Xcode's `#Preview` pane.
* Remove the need to create XIBs for laying out a view.
* Simplify building your UI, using a DSL similar to SwiftUI
* Easily handle moving and updating data between controls (eg. the value of an `NSSlider`)
* Compatible back to 10.13!

## Chainable AppKit controls

Most AppKit UI controls have added chaining functions for most of the control's properties.

This way you can create your control using a single statement.

For example :-

```swift
let commitButton = NSButton(title: "Commit")
   .bezelStyle(.push)
   .image(commitImage)
   .imagePosition(.imageLeading)
```

## Actions

AppKitUI adds actions to many AppKit controls, which allows you to handle control callbacks without having
to provide delegates or target/action pairs for the control.

### Example 1: Add a press handler to an `NSButton`

```
NSButton(title: "Present results")
   .onAction { [weak self] state in 
      // Do something when the button is pressed
   }
```

### Example 2: handle changes in an `NSTextField`

```swift
NSTextField(string: "Fish and chips")
   .width(200)
   .onChange { newText in
      // Do something with 'newText' when the text changes
   }
```

### Example 3: Handle color changes in an `NSColorWell`

```swift
let well = NSColorWell()
   .supportsAlpha(true)
   .color(.systemYellow)
   .onColorChange { [weak self] newColor in
      // Do something with 'newColor' when the color changes
   }
   .frame(width: 60, height: 60)
```

## Bindable Values

Many UI controls take and manipulate values (eg. an NSSlider). AppKitUI can bind these values betwen different controls 
to drastically simplify your UI code.

### Example 1: Basic NSSlider value

```
let dockSize = Bind(0.4)   // The initial value for the slider
let dockSizeSlider = NSSlider(dockSize, range: 0 ... 1)
                        .numberOfTickMarks(2)
```

Bindings can also specify delays for things such as update throttling or debouncing.

```swift
let delayedValue = Bind(20.0, delayType: .debounce(0.5))
let throttledValue = Bind(20.0, delayType: .throttle(0.5))
```

## UI Building

AppKitUI supports building nested child views, similar to SwiftUI.  Note that this only constructs
a view heirarachy.

```swift
func makeMyExcitingView() -> NSView {
   VStack {
      NSTextField(label: "The first line")
      NSButton(title: "Dance baby dance!") { _ in
         Swift.print("You clicked dance!") 
      }
      .tooltip("Do the important thing")
   }
}
```

There are a number of provided view structures :-

|  Type              |  Description              |
|--------------------|---------------------------|
| `VStack`           | A vertical NSStackView    |
| `HStack`           | A horizontal NSStackView  |
| `NSGridView`       | A grid                    |
| `Flow`             | A collection view that flows its child views horizontally, then moves to the next line when the row has run out of space |
| `TabView`          | A NSTabView               |
| `VSplitView`       | A vertical split view     |
| `HSplitView`       | A horizontal split view   |
| `ZStack`           | A z-order stack           |
| `ScrollView`       | A scroll container        |
| `LayoutContainer`  | A view container allowing arbitrary constraints between child views |

The fun part with this is that you can use Xcode previews to preview your NSView!

```swift
#if DEBUG

@MainActor
func makeDockSizeStack__(_ dockSize: Bind<Double>) -> NSView {
   VStack(alignment: .leading, spacing: 4) {
      NSTextField(label: "Size:")
      NSSlider(dockSize, range: 0 ... 1)
         .numberOfTickMarks(2)
      HStack {
         NSTextField(label: "Small")
            .font(.caption2)
            .gravityArea(.leading)
         NSView.Spacer()
         NSTextField(label: "Large")
            .font(.caption2)
            .gravityArea(.trailing)
      }
   }
}

@available(macOS 14, *)
#Preview("Simple slider") {
	let dockSize = Bind(0.1)
	makeDockSizeStack__(dockSize)
		.width(250)
}

#endif
```

Xcode previews require macOS 14, so you'll need to `@available` the preview.  The good thing is that this works
even if you are targeting macOS 10.13 (through the magic of backporting!).

You'll need to add the `DesignTime+PreviewBackport.swift` to your project for it to work.

Almost every source file for extending NS- controls has a preview (look in the `NS...+appkitui.swift` files in this package)

## NSFont conveniences

This set of extensions adds a collection of convenience properties and methods to NSFont, making it easier to work with common font styles, symbolic traits (such as bold or italic), and semantic text roles similar to those found in iOS (UIFont.TextStyle).
These extensions are designed to simplify font creation, provide consistency across your app’s UI, and reduce boilerplate when dealing with different weights, sizes, and symbolic traits.

These extensions provide:

* Semantic roles for text (body, headline, caption1, etc.).
* Convenient trait modifiers like `.bold`, `.italic`, `.monospaced`.
* Dynamic adjustments with `.size(_:)`, `.weight(_:)`, and `.traits(_)`.

### Semantic Fonts

Semantic system fonts let you specify fonts by role rather than point size.

* `NSFont.body` – Body text (13pt).
* `NSFont.callout` – Callouts (12pt).
* `NSFont.caption1` – Standard captions (10pt).
* `NSFont.caption2` – Alternate captions (≈10.5pt).
* `NSFont.footnote` – Footnotes (≈10pt).
* `NSFont.headline` – Headings (13pt, semibold).
* `NSFont.subheadline` – Subheadings (11pt).
* `NSFont.largeTitle` – Large titles (26pt).
* `NSFont.title1` – First-level titles (22pt).
* `NSFont.title2` – Second-level titles (17pt).
* `NSFont.title3` – Third-level titles (15pt).

### Monospaced Fonts

* `NSFont.monospacedDigit` – System font with monospaced digits.
* `NSFont.monospaced` – System monospaced font.

- On macOS 10.15+, uses monospacedSystemFont.
- On earlier macOS, falls back to a system font with .monoSpace traits.

## License

```
MIT License

Copyright (c) 2025 Darren Ford

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
