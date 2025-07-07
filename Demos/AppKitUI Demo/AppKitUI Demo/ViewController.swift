//
//  ViewController.swift
//  AppKitUI Demo
//
//  Created by Darren Ford on 17/7/2025.
//

import Cocoa
import AppKitUI

class ViewController: NSViewController {

	let model = Model()


	override func loadView() {
		self.view = PrimaryView(model: model)
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}
}
