// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "DAWFileKit",
    
    platforms: [
        .macOS(.v10_15), .iOS(.v10), .tvOS(.v10), .watchOS(.v6)
    ],
    
    products: [
        .library(
            name: "DAWFileKit",
            targets: ["DAWFileKit"]
        )
    ],
    
    dependencies: [
        .package(url: "https://github.com/orchetect/OTCore", from: "1.5.1"),
        .package(url: "https://github.com/orchetect/TimecodeKit", from: "2.0.8"),
        .package(url: "https://github.com/orchetect/MIDIKit.git", from: "0.9.5")
    ],
    
    targets: [
        .target(
            name: "DAWFileKit",
            dependencies: [
                "OTCore",
                "TimecodeKit",
                .productItem(name: "MIDIKitSMF", package: "MIDIKit", condition: nil)
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
