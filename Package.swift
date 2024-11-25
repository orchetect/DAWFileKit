// swift-tools-version:5.5
// (be sure to update the .swift-version file when this Swift version changes)

import PackageDescription

let package = Package(
    name: "DAWFileKit",
    platforms: [
        .macOS(.v10_15), .iOS(.v10), .tvOS(.v10), .watchOS(.v6)
    ],
    products: [
        .library(name: "DAWFileKit", targets: ["DAWFileKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/orchetect/OTCore", from: "1.6.0"),
        .package(url: "https://github.com/orchetect/TimecodeKit", from: "2.3.3"),
        .package(url: "https://github.com/orchetect/MIDIKit", from: "0.9.9")
    ],
    targets: [
        .target(
            name: "DAWFileKit",
            dependencies: [
                "OTCore",
                "TimecodeKit",
                .product(name: "MIDIKitSMF", package: "MIDIKit")
            ]
        ),
        .testTarget(
            name: "DAWFileKitTests",
            dependencies: ["DAWFileKit"],
            resources: [
                .copy("Cubase/Resources/Cubase TrackArchive XML Exports"),
                .copy("ProTools/Resources/PT Session Text Exports"),
                .copy("FinalCutPro/Resources/FCPXML Exports")
            ]
        )
    ]
)
