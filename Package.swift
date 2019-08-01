// swift-tools-version:5.1

import PackageDescription

let package = Package(
	name: "Vaux",
	products: [
		.library(
			name: "Vaux",
			targets: [
				"Vaux"
			]
		)
	],
	dependencies: [],
	targets: [
		.target(
			name: "Vaux"
		),
		.testTarget(
			name: "VauxTests",
			dependencies: [
				"Vaux"
			]
		)
	]
)
