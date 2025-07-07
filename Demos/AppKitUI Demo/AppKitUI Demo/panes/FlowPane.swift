
import AppKit
import AppKitUI

@MainActor
class FlowPane: Pane {
	override func title() -> String { "Flow" }
	override func make(model: Model) -> NSView {

		let tags = ["#earth", "#universe", "#space", "#black_hole", "#meteor", "#sulky", "#weeble"]

		return ScrollView(borderType: .noBorder) {

			VStack(spacing: 16) {

				NSBox(title: "Basic links") {
					Flow {
						for tag in tags {
							NSButton.link(title: tag) { _ in
								model.log("[Basic links] - Pressed \(tag)")
							}
							.toolTip(tag)
						}
					}
				}
				.titlePosition(.atTop)
				.huggingPriority(.init(rawValue: 10), for: .horizontal)


				NSBox(title: "Left to right layout") {
					Flow(minimumLineSpacing: 1, minimumInteritemSpacing: 1) {
						for tag in tags {
							NSButton(title: tag) { _ in
								model.log("[LTR] - Pressed \(tag)")
							}
						}
					}
				}
				.huggingPriority(.init(rawValue: 10), for: .horizontal)

				NSBox(title: "Right to left layout") {
					Flow(minimumLineSpacing: 1, minimumInteritemSpacing: 1) {
						for tag in tags {
							NSButton(title: tag) { _ in
								model.log("[RTL] - Pressed \(tag)")
							}
						}
					}
					.layoutDirection(.rightToLeft)
				}
				.huggingPriority(.init(rawValue: 10), for: .horizontal)

				NSBox(title: "Padding") {
					Flow(minimumLineSpacing: 4, minimumInteritemSpacing: 4) {
						for tag in tags {
							NSButton(title: tag) { _ in
								model.log("[Padding] - Pressed \(tag)")
							}
						}
					}
					.padding(top: 4, left: 8, bottom: 12, right: 16)
				}
				.huggingPriority(.init(rawValue: 10), for: .horizontal)


				NSBox(title: "Flow layout with a lot of different sized children") {
					Flow {
						NSButton(title: "one")
						NSTextField(label: "This is a test!!").font(.title2)
							.truncatesLastVisibleLine(true)
							.compressionResistancePriority(.defaultLow, for: .horizontal)
						NSButton(title: "two")
						AUISwitch()

						NSButton.radioGroup(orientation: .vertical)
							.items(["first", "second", "third"])

						NSButton(title: "four")
						NSButton(title: "five")

						NSTextField(label: "Plain text").font(.body)
						NSTextField(label: "Bold text").font(.body.bold)
						NSTextField(label: "Italic text").font(.body.italic)
						NSTextField(label: "Bold Italic text").font(.body.bold.italic)
						NSTextField(label: "Heavy text").font(.body.weight(.heavy))
						NSTextField(label: "Black Italic text").font(.body.weight(.black).italic)
						VStack(alignment: .leading) {
							NSTextField(label: "Monospaced").font(.monospaced)
							NSTextField(label: "Monospaced Bold").font(.monospaced.bold)
						}
					}
					.padding(8)
					.debugFrames(.systemPurple)
				}
				.huggingPriority(.init(rawValue: 10), for: .horizontal)
			}
			.padding()
		}
	}
}

#if DEBUG
@available(macOS 14, *)
#Preview("FlowPane") {
	FlowPane().make(model: Model())
		.frame(width: 640, height: 480)
}
#endif
