// swift-tools-version: 5.8
// (be sure to update the .swift-version file when this Swift version changes)

import PackageDescription

let package = Package(
    name: "DAWFileKit",
    platforms: [
        .macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)
    ],
    products: [
        .library(name: "DAWFileKit", targets: ["DAWFileKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/orchetect/OTCore", from: "1.7.7"),
        .package(url: "https://github.com/orchetect/TimecodeKit", from: "2.3.3"),
        .package(url: "https://github.com/orchetect/MIDIKit", from: "0.10.4")
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
                .copy("FinalCutPro/Resources/FCPXML Exports"),
                .copy("SRT/Resources/SRT Files")
            ]
        )
    ]
)
