// swift-tools-version:5.3

import PackageDescription

let package = Package(
	
	name: "DAWFileKit",
	
    platforms: [
        .macOS(.v10_12), .iOS(.v10), .tvOS(.v10), .watchOS(.v6)
    ],
    
    products: [
		.library(
			name: "DAWFileKit",
			targets: ["DAWFileKit"])
	],
	
	dependencies: [
		.package(url: "https://github.com/orchetect/OTCore", from: "1.1.18"),
		.package(url: "https://github.com/orchetect/TimecodeKit", from: "1.2.6")
	],
	
	targets: [
		.target(
			name: "DAWFileKit",
			dependencies: ["OTCore", "TimecodeKit"]),
		
		.testTarget(
			name: "DAWFileKitTests",
			dependencies: ["DAWFileKit"],
			resources: [
                .copy("Cubase/Resources/Cubase TrackArchive XML"),
                .copy("Pro Tools/Resources/PT Session Text Exports")
            ])
	]
	
)
