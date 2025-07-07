//
//  PaneListView.swift
//  AppKitUI Demo
//
//  Created by Darren Ford on 17/7/2025.
//

import AppKit
import AppKitUI

class ListView: NSView {
	let model: Model
	init(model: Model) {
		self.model = model
		super.init(frame: .zero)
		self.setup()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setup() {
		let primaryList =
		NSVisualEffectView(material: .sidebar) {
			ScrollView {
				List(self.model.panes) { pane in
					HStack {
						NSTextField(label: pane.title())
					}
				}
				.selection(model.selected)
				.backgroundColor(.clear)
			}
			.borderType(.noBorder)
		}
		.huggingPriority(.defaultLow, for: .vertical)

		.minWidth(150)
		.maxWidth(300)

		self.content(fill: primaryList)
	}
}

#if DEBUG
@available(macOS 14, *)
#Preview("Primary") {
	ListView(model: Model())
		//.frame(width: 320, height: 200)
}
#endif
