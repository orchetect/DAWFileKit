// swift-tools-version:5.3

import PackageDescription

let package = Package(
	
	name: "DAWFileKit",
	
	platforms: [.macOS(.v10_12), .iOS(.v10)],
	
	products: [
		
		.library(
			name: "DAWFileKit",
			targets: ["DAWFileKit"])
		
	],
	
	dependencies: [
		
		.package(url: "https://github.com/orchetect/OTCore", from: "1.1.6"),
		.package(url: "https://github.com/orchetect/TimecodeKit", from: "1.0.10")
		
	],
	
	targets: [
		
		.target(
			name: "DAWFileKit",
			dependencies: ["OTCore", "TimecodeKit"]),
		
		.testTarget(
			name: "DAWFileKitTests",
			dependencies: ["DAWFileKit"],
			resources: [.copy("Pro Tools/Resources/PTSessionTextExports")]),
		
	]
	
)
