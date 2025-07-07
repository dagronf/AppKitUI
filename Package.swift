// swift-tools-version: 5.9

import PackageDescription

let package = Package(
	name: "AppKitUI",
	platforms: [
		.macOS(.v10_13),
		//.macOS(.v14)
	],
	products: [
		.library(
			name: "AppKitUI",
			targets: ["AppKitUI"]),
	],
	targets: [
		.target(
			name: "AppKitUI"),
		.testTarget(
			name: "AppKitUITests",
			dependencies: ["AppKitUI"]
		),
	]
)
