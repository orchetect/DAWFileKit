# DAWFileKit

<p>
<a href="https://developer.apple.com/swift">
<img src="https://img.shields.io/badge/Swift%205.3-compatible-orange.svg?style=flat"
     alt="Swift 5.3 compatible" /></a>
<a href="#installation">
<img src="https://img.shields.io/badge/SPM-compatible-orange.svg?style=flat"
     alt="Swift Package Manager (SPM) compatible" /></a>
<a href="https://developer.apple.com/swift">
<img src="https://img.shields.io/badge/platform-macOS%2010.12%20|%20iOS%2010-green.svg?style=flat"
     alt="Platform - macOS 10.12 | iOS 10" /></a>
<a href="#contributions">
<img src="https://img.shields.io/badge/Linux-not%20tested-black.svg?style=flat"
     alt="Linux - not tested" /></a>
<a href="https://github.com/orchetect/DAWFileKit/blob/master/LICENSE">
<img src="http://img.shields.io/badge/license-MIT-blue.svg?style=flat" 
     alt="License: MIT" /></a>
</p>

A Swift library for reading and writing common import/export file formats between popular DAW applications.

## Supported File Formats

|                  Format                  |  Read   |  Write  |
| :--------------------------------------: | :-----: | :-----: |
|        Cubase: Track Archive XML         |  yes†   |  yes†   |
|    Pro Tools: Session Info Text file     |   yes   |   n/a   |
|               Logic Pro X‡               | future? | future? |
|            Digital Performer‡            | future? | future? |
| (more platforms may be added in future)‡ |         |         |

*† Full read/write support for Cubase Track Archive XML files is implemented for tracks with absolute timebase, as well as tracks with musical timebase where the tempo track uses only 'Jump' tempo events and there are no 'Ramp' tempo events*

*‡ Research is needed to determine what file formats are common and the viability of their implementation*

## Dependencies

The library implicitly makes use of [TimecodeKit](https://github.com/orchetect/TimecodeKit) as the format to represent timecode values read/written from the files.

## Documentation

No formal documentation yet.

## Unit Tests

Core unit tests implemented. More exhaustive tests can be added in future.

## Known Issues

### Cubase: Track Archive XML

- Ascertaining the absolute time position of events on tracks that are in musical timebase when the tempo track contains 'Ramp' tempo event(s) is currently not possible. The internal curve function that Cubase uses to calculate tempo ramps is not intuitive (ie: not linear or any obvious known curve function), and it may be a proprietary function. So this may never be possible with this library. The workaround is to not use 'Ramp' tempo events in a session, or if that is unavoidable, move/copy events to a track that is using absolute timebase which can be interpreted reliably with this library.
- Track Archive XML file read/write has not been tested with Nuendo yet but it is likely that it should work the same as with Cubase.

### Pro Tools: Session Info Text file

- Currently, the parser relies on certain export options to be selected when exporting a Session Text file from Pro Tools so that the parser can read it correctly. Additional routines/heuristics need to be added to add ruggedness to the parser so that it can detect all of the various export options based on the text file contents, and successfully parse the file regardless and/or output meaningful error conditions that describe why the file may not be in a parsable format.

- [ ] Add subframes capability
- [ ] Check frame rate strings PT outputs to Session Info text file and ensure parser reads them correctly
- [ ] Handle *new-line* and *tab* characters in Markers list name/comment fields (Pro Tools allows them to be inserted or pasted from the clipboard when editing markers)
- [ ] Add parsing modes specific for "TextEdit 'TEXT'" and "UTF-8 'TEXT'" File Format encodings
  - [ ] Analyze to see how extended characters are being encoded or (assumed to be) lossily converted to meaningless characters ("É" for "…", "Ñ" for "—", etc.)
  - [ ] Improve lossy character fix/replacement heuristic

## Affiliation

The author(s) have no affiliation with Avid, Steinberg, or any other company relating to the software packages that are mentioned in this library. This library is built based on easily discernable open file data formats and at no time has reverse-engineering been employed to intuit their format or implementation. The goal of this library is to promote easier interoperability for developers with these common and useful data file formats.

The library is provided as-is with no warranties. See the [LICENSE](https://github.com/orchetect/DAWFileKit/blob/master/LICENSE) for more details.

## Author

Coded by a bunch of 🐹 hamsters in a trenchcoat that calls itself [@orchetect](https://github.com/orchetect).

## License

Licensed under the MIT license. See [LICENSE](https://github.com/orchetect/DAWFileKit/blob/master/LICENSE) for details.

## Contributions

Contributions are welcome. Feel free to post an Issue to discuss.

