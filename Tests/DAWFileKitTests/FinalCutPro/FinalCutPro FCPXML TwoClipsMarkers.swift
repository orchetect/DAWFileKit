//
//  FinalCutPro FCPXML TwoClipsMarkers.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

/* @testable */ import DAWFileKit
import OTCore
import TimecodeKit
import XCTest

class FinalCutPro_FCPXML_TwoClipsMarkers: XCTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    /// Test markers contained on two clips in the same sequence, as well as a marker in a gap
    /// between the clips.
    func testFCPXML_TwoClipsMarkers() throws {
        // load file
        
        let filename = "TwoClipsMarkers"
        let rawData = try XCTUnwrap(loadFileContents(
            forResource: filename,
            withExtension: "fcpxml",
            subFolder: .fcpxmlExports
        ))
        
        // load
        
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // events
        
        let project = try XCTUnwrap(fcpxml.projects().first)
        
        // sequence
        
        let sequence = project.sequence
        
        XCTAssertEqual(sequence.format, "r1")
        XCTAssertEqual(sequence.start, try Timecode(.components(h: 1), at: .fps29_97, base: .max80SubFrames))
        XCTAssertEqual(sequence.start?.frameRate, .fps29_97)
        XCTAssertEqual(sequence.start?.subFramesBase, .max80SubFrames)
        XCTAssertEqual(sequence.duration, try Timecode(.components(s: 30), at: .fps29_97, base: .max80SubFrames))
        XCTAssertEqual(sequence.audioLayout, .stereo)
        XCTAssertEqual(sequence.audioRate, .rate48kHz)
        
        // spine
        
        let spine = sequence.spine
        
        // clips
        
        guard case let .anyClip(.title(title1)) = try XCTUnwrap(spine.elements[safe: 0]),
              case let .anyClip(.gap(gap)) = try XCTUnwrap(spine.elements[safe: 1]),
              case let .anyClip(.title(title2)) = try XCTUnwrap(spine.elements[safe: 2])
        else { return }
        
        // clip 1 - title
        
        XCTAssertEqual(title1.ref, "r2")
        XCTAssertEqual(title1.offset, try Timecode(.components(h: 1), at: .fps29_97, base: .max80SubFrames))
        XCTAssertEqual(title1.offset?.frameRate, .fps29_97)
        XCTAssertEqual(title1.name, "Basic Title 1")
        XCTAssertEqual(title1.start, try Timecode(.components(h: 1), at: .fps29_97, base: .max80SubFrames))
        XCTAssertEqual(title1.start?.frameRate, .fps29_97)
        XCTAssertEqual(title1.duration, try Timecode(.components(s: 10), at: .fps29_97, base: .max80SubFrames))
        XCTAssertEqual(title1.duration?.frameRate, .fps29_97)
        
        // clip 2 - gap
        
        XCTAssertEqual(gap.offset, try Timecode(.components(h: 1, s: 10), at: .fps29_97, base: .max80SubFrames))
        XCTAssertEqual(gap.offset?.frameRate, .fps29_97)
        XCTAssertEqual(gap.name, "Gap")
        XCTAssertEqual(gap.start, try Timecode(.components(h: 0, m: 59, s: 56, f: 12), at: .fps29_97, base: .max80SubFrames))
        XCTAssertEqual(gap.start?.frameRate, .fps29_97)
        XCTAssertEqual(gap.duration, try Timecode(.components(s: 10), at: .fps29_97, base: .max80SubFrames))
        XCTAssertEqual(gap.duration?.frameRate, .fps29_97)
        
        // clip 3 - title
        
        XCTAssertEqual(title2.ref, "r2")
        XCTAssertEqual(title2.offset, try Timecode(.components(h: 1, s: 20), at: .fps29_97, base: .max80SubFrames))
        XCTAssertEqual(title2.offset?.frameRate, .fps29_97)
        XCTAssertEqual(title2.name, "Basic Title 2")
        XCTAssertEqual(title2.start, try Timecode(.components(h: 1), at: .fps29_97, base: .max80SubFrames))
        XCTAssertEqual(title2.start?.frameRate, .fps29_97)
        XCTAssertEqual(title2.duration, try Timecode(.components(s: 10), at: .fps29_97, base: .max80SubFrames))
        XCTAssertEqual(title2.duration?.frameRate, .fps29_97)
        
        // markers in title 1
        
        // start is 4 seconds 15 frames elapsed in the title's local timeline.
        // the gap's local timeline starts at 01:00:00:00 so the marker's start is 01:00:04:15.
        XCTAssertEqual(title1.markers.count, 1)
        let title1Marker = try XCTUnwrap(title1.markers[safe: 0])
        let expectedTitle1Marker = FinalCutPro.FCPXML.Marker(
            start: try Timecode(.components(h: 01, m: 00, s: 04, f: 15), at: .fps29_97, base: .max80SubFrames),
            duration: try Timecode(.components(f: 1), at: .fps29_97, base: .max80SubFrames),
            name: "Marker 1",
            metaData: .standard,
            note: nil
        )
        XCTAssertEqual(title1Marker, expectedTitle1Marker)
        
        // markers in gap
        
        // start is 5 seconds elapsed in the gap's local timeline.
        // the gap's local timeline starts at 00:59:56:12 so the marker's start is 01:00:01:12.
        // also, it seems that the duration is reduced to 1 audio sample at 48kHz - perhaps
        // in a gap, FCP reduces timing resolution to audio sample rate instead of video frame rate?
        XCTAssertEqual(gap.markers.count, 1)
        let gapMarker = try XCTUnwrap(gap.markers[safe: 0])
        let expectedGapMarker = FinalCutPro.FCPXML.Marker(
            start: try Timecode(.components(h: 01, m: 00, s: 01, f: 12), at: .fps29_97, base: .max80SubFrames),
            duration: try Timecode(.rational(1, 48000), at: .fps29_97, base: .max80SubFrames),
            name: "Marker 2",
            metaData: .standard,
            note: nil
        )
        XCTAssertEqual(gapMarker, expectedGapMarker)
        
        // markers in title 2
        
        // start is 7 seconds elapsed in the title's local timeline.
        // the gap's local timeline starts at 01:00:00:00 so the marker's start is 01:00:07:00.
        XCTAssertEqual(title2.markers.count, 1)
        let title2Marker = try XCTUnwrap(title2.markers[safe: 0])
        let expectedTitle2Marker = FinalCutPro.FCPXML.Marker(
            start: try Timecode(.components(h: 01, m: 00, s: 07, f: 00), at: .fps29_97, base: .max80SubFrames),
            duration: try Timecode(.components(f: 1), at: .fps29_97, base: .max80SubFrames),
            name: "Marker 3",
            metaData: .standard,
            note: nil
        )
        XCTAssertEqual(title2Marker, expectedTitle2Marker)
        
        // extract markers
        
        let extractedMarkers = project
            .extractMarkers(settings: FCPXMLMarkersExtractionSettings(
                // deep: true,
                excludeTypes: [],
                auditionMask: .activeAudition
            ))
        XCTAssertEqual(extractedMarkers.count, 3)
        
        let extractedTitle1Marker = try XCTUnwrap(extractedMarkers[safe: 0])
        XCTAssertEqual(extractedTitle1Marker.marker, expectedTitle1Marker)
        XCTAssertEqual(
            extractedTitle1Marker.absoluteStart,
            try Timecode(.components(h: 01, m: 00, s: 04, f: 15), at: .fps29_97, base: .max80SubFrames)
        )
        XCTAssertEqual(extractedTitle1Marker.parentType, .title)
        XCTAssertEqual(extractedTitle1Marker.parentName, "Basic Title 1")
        
        let extractedGapMarker = try XCTUnwrap(extractedMarkers[safe: 1])
        XCTAssertEqual(extractedGapMarker.marker, expectedGapMarker)
        XCTAssertEqual(
            extractedGapMarker.absoluteStart,
            try Timecode(.components(h: 01, m: 00, s: 15, f: 00), at: .fps29_97, base: .max80SubFrames)
        )
        XCTAssertEqual(extractedGapMarker.parentType, .gap)
        XCTAssertEqual(extractedGapMarker.parentName, "Gap")
        
        let extractedTitle2Marker = try XCTUnwrap(extractedMarkers[safe: 2])
        XCTAssertEqual(extractedTitle2Marker.marker, expectedTitle2Marker)
        XCTAssertEqual(
            extractedTitle2Marker.absoluteStart,
            try Timecode(.components(h: 01, m: 00, s: 27, f: 00), at: .fps29_97, base: .max80SubFrames)
        )
        XCTAssertEqual(extractedTitle2Marker.parentType, .title)
        XCTAssertEqual(extractedTitle2Marker.parentName, "Basic Title 2")
    }
}

#endif
