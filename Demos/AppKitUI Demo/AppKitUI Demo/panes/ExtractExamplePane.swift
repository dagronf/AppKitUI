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
import AppKitUI

class ExtractExamplePane: Pane {
	override func title() -> String { "Extract DVD Example" }
	@MainActor
	override func make(model: Model) -> NSView {
		return NSView(layoutStyle: .centered) {

			let source = Bind("BD-RE BUFFALO")
			let sourceFile = Bind("/VIDEO_TS/VTS_01_1.VOB")

			let byteCount = Bind<Int64>(6467400)
			let byteFormatter: ByteCountFormatter = {
				let b = ByteCountFormatter()
				b.countStyle = .file
				return b
			}()

			let readRate = Bind<Int64>(5600000)

			let outputPath = Bind(FileManager.default.temporaryDirectory)
			let outputSize = Bind<Int64>(5600000)

			let freeSpace = Bind<Int64>(200000000)

			return VStack {
				NSGridView(columnSpacing: 8) {
					NSGridView.Row {
						NSTextField(label: "Source:")
							.font(.system.weight(.bold))
						NSTextField(label: source)
					}
					NSGridView.Row {
						NSTextField(label: "Source file:")
							.font(.system.weight(.bold))
						NSTextField(label: sourceFile)
					}
					NSGridView.Row {
						NSTextField(label: "Source size:")
							.font(.system.weight(.bold))
						NSTextField(label: byteCount.byteFormatted(byteFormatter))
					}
					NSGridView.Row {
						NSTextField(label: "Read rate:")
							.font(.system.weight(.bold))
						HStack(spacing: 0) {
							NSTextField(label: readRate.byteFormatted(byteFormatter))
							NSTextField(label: "/s")
						}
					}
					NSGridView.Row {
						NSTextField(label: "Output file:")
							.font(.system.weight(.bold))
						NSPathControl(fileURL: outputPath)
							.pathStyle(.popUp)
							.huggingPriority(.init(10), for: .horizontal)
							.compressionResistancePriority(.defaultLow, for: .horizontal)
					}
					NSGridView.Row {
						NSTextField(label: "Output size:")
							.font(.system.weight(.bold))
						NSTextField(label: outputSize.byteFormatted(byteFormatter))
					}
					NSGridView.Row {
						NSTextField(label: "Free space:")
							.font(.system.weight(.bold))
						NSTextField(label: freeSpace.byteFormatted(byteFormatter))
					}
				}
				.rowAlignment(.firstBaseline)
				.columnAlignment(.trailing, forColumn: 0)
				//.debugFrames()
			}
		}
	}
}

#if DEBUG
@available(macOS 14, *)
#Preview("Example") {
	ExtractExamplePane().make(model: Model())
}
#endif
