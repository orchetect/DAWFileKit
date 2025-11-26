# swift-daw-file-tools

[![Platforms - macOS 10.15+ | iOS 10+ | tvOS 10+ | visionOS 1+](https://img.shields.io/badge/platforms-macOS%2010.15+%20|%20iOS%2010+%20|%20tvOS%2010+%20|%20visionOS%201+-lightgrey.svg?style=flat)](https://developer.apple.com/swift) ![Swift 5.5-6.0](https://img.shields.io/badge/Swift-5.5–6.0-orange.svg?style=flat) [![Xcode 13-16](https://img.shields.io/badge/Xcode-13–16-blue.svg?style=flat)](https://developer.apple.com/swift) [![License: MIT](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat)](https://github.com/orchetect/swift-daw-file-tools/blob/main/LICENSE)

A Swift library for reading and writing common import/export file formats between popular DAW and video editing applications with the ability to convert between formats.

## Supported File Formats

|              Format               |  Read   |  Write  |
| :-------------------------------: | :-----: | :-----: |
|     Cubase: Track Archive XML     |  yes†   |  yes†   |
| Pro Tools: Session Info text file |   yes   |   n/a   |
|        Standard MIDI File         | planned |   yes   |
|           Logic Pro X‡            | future? | future? |
|    Final Cut Pro XML (FCPXML)     |   yes   |   yes   |
|        Adobe Premiere XML         | future? | future? |
|         SubRip SRT File           |   yes   |   yes   |

*† Full read/write support for Cubase Track Archive XML files is implemented for tracks with absolute timebase, as well as tracks with musical timebase where the tempo track uses only 'Jump' tempo events and there are no 'Ramp' tempo events.*

*‡ Research is needed for Logic Pro X to determine what file formats are common and the viability of their implementation*.

## Installation

### Swift Package Manager (SPM)

To add this package to an Xcode app project, use:

 `https://github.com/orchetect/swift-daw-file-tools` as the URL.

To add this package to a Swift package, add the dependency to your package and target in Package.swift:

```swift
let package = Package(
    dependencies: [
        .package(url: "https://github.com/orchetect/swift-daw-file-tools", from: "0.7.0")
    ],
    targets: [
        .target(
            dependencies: [
                .product(name: "DAWFileTools", package: "swift-daw-file-tools")
            ]
        )
    ]
)
```

## Dependencies

- [TimecodeKit](https://github.com/orchetect/TimecodeKit) to represent timecode values
- [MIDIKit](https://github.com/orchetect/MIDIKit) to read/write Standard MIDI Files

## Documentation

No formal documentation yet.

## Unit Tests

Core unit tests implemented. More exhaustive tests can be added in future.

## Known Issues

### Cubase: Track Archive XML

- Ascertaining the absolute time position of events on tracks that are in musical timebase when the tempo track contains 'Ramp' tempo event(s) is currently not possible. The internal curve function that Cubase uses to calculate tempo ramps is not intuitive (ie: not linear or any obvious known curve function), and it may be a proprietary function. So this may never be possible with this library. The workaround is to not use 'Ramp' tempo events in a session, or if that is unavoidable, move/copy events to a track that is using absolute timebase which can be interpreted reliably with this library.

### Final Cut Pro XML

- Basic support is implemented. More complete support may come in a future library update.

## Affiliation

The author(s) have no affiliation with Apple, Avid, Steinberg, or any other company relating to the software packages that are mentioned in this library. This library is built based on open file data format such as text, XML and MIDI. No reverse-engineering of software was involved in implementation of this library. The goal is to promote easier interoperability for developers with these common and useful data file formats.

The library is provided as-is with no warranties. See the [LICENSE](https://github.com/orchetect/swift-daw-file-tools/blob/master/LICENSE) for more details.

## Author

Coded by a bunch of 🐹 hamsters in a trenchcoat that calls itself [@orchetect](https://github.com/orchetect).

## License

Licensed under the MIT license. See [LICENSE](https://github.com/orchetect/swift-daw-file-tools/blob/master/LICENSE) for details.

## Community & Support

Please do not email maintainers for technical support. Several options are available for issues and questions:

- Questions and feature ideas can be posted to [Discussions](https://github.com/orchetect/swift-daw-file-tools/discussions).
- If an issue is a verifiable bug with reproducible steps it may be posted in [Issues](https://github.com/orchetect/swift-daw-file-tools/issues).

## Contributions

Contributions are welcome. Posting in [Discussions](https://github.com/orchetect/swift-daw-file-tools/discussions) first prior to new submitting PRs for features or modifications is encouraged.

## Legacy

This repository was formerly known as DAWFileKit.
