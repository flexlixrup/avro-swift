// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
	name: "avro-swift",
	platforms: [.macOS(.v13), .iOS(.v16)],
	products: [
		// Products define the executables and libraries a package produces, making them visible to other packages.
		.library(
			name: "Avro",
			targets: ["Avro"]
		)
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-syntax.git", from: "600.0.0")
	],
	targets: [
		// Targets are the basic building blocks of a package, defining a module or a test suite.
		// Targets can depend on other targets in this package and products from dependencies.
		.target(
			name: "Avro",
			dependencies: [
				"AvroMacros"
			]
		),
		.executableTarget(name: "AvroExamples", dependencies: ["Avro"]),
		.macro(
			name: "AvroMacros",
			dependencies: [
				.product(name: "SwiftSyntax", package: "swift-syntax"),
				.product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
				.product(name: "SwiftCompilerPlugin", package: "swift-syntax")
			]
		),
		.testTarget(
			name: "AvroTests",
			dependencies: [
				"Avro", "AvroMacros"
			]
		)
	]
)
