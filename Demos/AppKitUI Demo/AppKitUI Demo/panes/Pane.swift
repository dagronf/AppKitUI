//
//  Pane.swift
//  AppKitUI Demo
//
//  Created by Darren Ford on 17/7/2025.
//

import AppKit
import AppKitUI

class Pane: Equatable {
	func title() -> String { fatalError() }
	@MainActor func make(model: Model) -> NSView { fatalError()}
	static func == (lhs: Pane, rhs: Pane) -> Bool {
		return lhs.title() < rhs.title()
	}
}
