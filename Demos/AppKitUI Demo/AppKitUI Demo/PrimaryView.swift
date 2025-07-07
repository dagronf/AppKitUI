//
//  PrimaryView.swift
//  AppKitUI Demo
//
//  Created by Darren Ford on 17/7/2025.
//

import AppKit
import AppKitUI

class PrimaryView: NSView {
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
		self.translatesAutoresizingMaskIntoConstraints = false
		let primary = VSplitView(dividerStyle: .thin) {
			ListView(model: model)
				.minWidth(200)
			DetailPane(model: model)
		}
		.holdingPriority(.init(250), forItemAtIndex: 0)
		.holdingPriority(.init(100), forItemAtIndex: 1)
		
		self.content(fill: primary)
	}
}

#if DEBUG
@available(macOS 14, *)
#Preview("Primary") {
	NSView(layoutStyle: .fill) {
		PrimaryView(model: Model())
	}
	.frame(width: 640, height: 480)
}
#endif
