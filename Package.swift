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
        .package(url: "https://github.com/orchetect/swift-extensions", from: "2.0.0"),
        .package(url: "https://github.com/orchetect/TimecodeKit", from: "2.3.4"),
        .package(url: "https://github.com/orchetect/MIDIKit", from: "0.10.5")
    ],
    targets: [
        .target(
            name: "DAWFileKit",
            dependencies: [
                .product(name: "SwiftExtensions", package: "swift-extensions"),
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
