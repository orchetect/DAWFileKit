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

final class FinalCutPro_FCPXML_TwoClipsMarkers: FCPXMLTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    var fileContents: Data { get throws {
        try XCTUnwrap(loadFileContents(
            forResource: "TwoClipsMarkers",
            withExtension: "fcpxml",
            subFolder: .fcpxmlExports
        ))
    } }
    
    var expectedTitle1Marker: FinalCutPro.FCPXML.Marker { get throws {
        FinalCutPro.FCPXML.Marker(
            start: Self.tc("01:00:04:15", .fps29_97),
            duration: Self.tc("00:00:00:01", .fps29_97),
            name: "Marker 1",
            metaData: .standard,
            note: nil
        )
    } }
    
    var expectedTitle2Marker: FinalCutPro.FCPXML.Marker { get throws {
        FinalCutPro.FCPXML.Marker(
            start: Self.tc("01:00:07:00", .fps29_97),
            duration: Self.tc("00:00:00:01", .fps29_97),
            name: "Marker 3",
            metaData: .standard,
            note: nil
        )
    } }
    
    var expectedGapMarker: FinalCutPro.FCPXML.Marker { get throws {
        FinalCutPro.FCPXML.Marker(
            start: Self.tc("01:00:01:12", .fps29_97),
            duration: try Timecode(.rational(1, 48000), at: .fps29_97, base: .max80SubFrames),
            name: "Marker 2",
            metaData: .standard,
            note: nil
        )
    } }
    
    /// Test markers contained on two clips in the same sequence, as well as a marker in a gap
    /// between the clips.
    func testParse() throws {
        // load file
        
        let rawData = try fileContents
        
        // load
        
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        
        let events = try XCTUnwrap(fcpxml.allEvents())
        XCTAssertEqual(events.count, 1)
        
        let event = try XCTUnwrap(events.first)
        
        // project
        
        let projects = event.projects
        XCTAssertEqual(projects.count, 1)
        
        let project = try XCTUnwrap(projects.first)
        
        // sequence
        
        let sequence = project.sequence
        
        XCTAssertEqual(sequence.formatID, "r1")
        XCTAssertEqual(sequence.startTimecode, Self.tc("01:00:00:00", .fps29_97))
        XCTAssertEqual(sequence.startTimecode?.frameRate, .fps29_97)
        XCTAssertEqual(sequence.startTimecode?.subFramesBase, .max80SubFrames)
        XCTAssertEqual(sequence.duration, Self.tc("00:00:30:00", .fps29_97))
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
        XCTAssertEqual(title1.offset, Self.tc("01:00:00:00", .fps29_97))
        XCTAssertEqual(title1.offset?.frameRate, .fps29_97)
        XCTAssertEqual(title1.name, "Basic Title 1")
        XCTAssertEqual(title1.start, Self.tc("01:00:00:00", .fps29_97))
        XCTAssertEqual(title1.start?.frameRate, .fps29_97)
        XCTAssertEqual(title1.duration, Self.tc("00:00:10:00", .fps29_97))
        XCTAssertEqual(title1.duration?.frameRate, .fps29_97)
        
        // clip 2 - gap
        
        XCTAssertEqual(gap.offset, Self.tc("01:00:10:00", .fps29_97))
        XCTAssertEqual(gap.offset?.frameRate, .fps29_97)
        XCTAssertEqual(gap.name, "Gap")
        XCTAssertEqual(gap.start, Self.tc("00:59:56:12", .fps29_97))
        XCTAssertEqual(gap.start?.frameRate, .fps29_97)
        XCTAssertEqual(gap.duration, Self.tc("00:00:10:00", .fps29_97))
        XCTAssertEqual(gap.duration?.frameRate, .fps29_97)
        
        // clip 3 - title
        
        XCTAssertEqual(title2.ref, "r2")
        XCTAssertEqual(title2.offset, Self.tc("01:00:20:00", .fps29_97))
        XCTAssertEqual(title2.offset?.frameRate, .fps29_97)
        XCTAssertEqual(title2.name, "Basic Title 2")
        XCTAssertEqual(title2.start, Self.tc("01:00:00:00", .fps29_97))
        XCTAssertEqual(title2.start?.frameRate, .fps29_97)
        XCTAssertEqual(title2.duration, Self.tc("00:00:10:00", .fps29_97))
        XCTAssertEqual(title2.duration?.frameRate, .fps29_97)
        
        // markers in title 1
        
        let title1Markers = title1.contents.annotations().markers()
        
        // start is 4 seconds 15 frames elapsed in the title's local timeline.
        // the gap's local timeline starts at 01:00:00:00 so the marker's start is 01:00:04:15.
        XCTAssertEqual(title1Markers.count, 1)
        let title1Marker = try XCTUnwrap(title1Markers[safe: 0])
        XCTAssertEqual(title1Marker, try expectedTitle1Marker)
        
        // markers in gap
        
        let gapMarkers = gap.contents.annotations().markers()
        
        // start is 5 seconds elapsed in the gap's local timeline.
        // the gap's local timeline starts at 00:59:56:12 so the marker's start is 01:00:01:12.
        // also, it seems that the duration is reduced to 1 audio sample at 48kHz - perhaps
        // in a gap, FCP reduces timing resolution to audio sample rate instead of video frame rate?
        XCTAssertEqual(gapMarkers.count, 1)
        let gapMarker = try XCTUnwrap(gapMarkers[safe: 0])
        XCTAssertEqual(gapMarker, try expectedGapMarker)
        
        // markers in title 2
        
        let title2Markers = title2.contents.annotations().markers()
        
        // start is 7 seconds elapsed in the title's local timeline.
        // the gap's local timeline starts at 01:00:00:00 so the marker's start is 01:00:07:00.
        XCTAssertEqual(title2Markers.count, 1)
        let title2Marker = try XCTUnwrap(title2Markers[safe: 0])
        XCTAssertEqual(title2Marker, try expectedTitle2Marker)
    }
    
    func testExtractMarkers() throws {
        // load file
        
        let rawData = try fileContents
        
        // load
        
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        
        let event = try XCTUnwrap(fcpxml.allEvents().first)
        
        // extract markers
        
        let extractedMarkers = event.extractMarkers(
            settings: FinalCutPro.FCPXML.ExtractionSettings(
                // deep: true,
                excludeTypes: [],
                auditionMask: .activeAudition
            ),
            ancestorsOfParent: []
        )
        XCTAssertEqual(extractedMarkers.count, 3)
        
        let extractedTitle1Marker = try XCTUnwrap(extractedMarkers[safe: 0])
        XCTAssertEqual(extractedTitle1Marker, try expectedTitle1Marker)
        XCTAssertEqual(extractedTitle1Marker.context[.ancestorEventName], "Test Event")
        XCTAssertEqual(extractedTitle1Marker.context[.ancestorProjectName], "TwoClipsMarkers")
        XCTAssertEqual(
            extractedTitle1Marker.context[.absoluteStart],
            Self.tc("01:00:04:15", .fps29_97)
        )
        XCTAssertEqual(extractedTitle1Marker.context[.parentType], .story(.anyClip(.title)))
        XCTAssertEqual(extractedTitle1Marker.context[.parentName], "Basic Title 1")
        XCTAssertEqual(
            extractedTitle1Marker.context[.parentAbsoluteStart],
            Self.tc("01:00:00:00", .fps29_97)
        )
        XCTAssertEqual(
            extractedTitle1Marker.context[.parentDuration],
            Self.tc("00:00:10:00", .fps29_97)
        )
        
        let extractedGapMarker = try XCTUnwrap(extractedMarkers[safe: 1])
        XCTAssertEqual(extractedGapMarker, try expectedGapMarker)
        XCTAssertEqual(extractedGapMarker.context[.ancestorEventName], "Test Event")
        XCTAssertEqual(extractedGapMarker.context[.ancestorProjectName], "TwoClipsMarkers")
        XCTAssertEqual(
            extractedGapMarker.context[.absoluteStart],
            Self.tc("01:00:15:00", .fps29_97)
        )
        XCTAssertEqual(extractedGapMarker.context[.parentType], .story(.anyClip(.gap)))
        XCTAssertEqual(extractedGapMarker.context[.parentName], "Gap")
        XCTAssertEqual(
            extractedGapMarker.context[.parentAbsoluteStart],
            Self.tc("01:00:10:00", .fps29_97)
        )
        XCTAssertEqual(
            extractedGapMarker.context[.parentDuration],
            Self.tc("00:00:10:00", .fps29_97)
        )
        
        let extractedTitle2Marker = try XCTUnwrap(extractedMarkers[safe: 2])
        XCTAssertEqual(extractedTitle2Marker, try expectedTitle2Marker)
        XCTAssertEqual(extractedTitle2Marker.context[.ancestorEventName], "Test Event")
        XCTAssertEqual(extractedTitle2Marker.context[.ancestorProjectName], "TwoClipsMarkers")
        XCTAssertEqual(
            extractedTitle2Marker.context[.absoluteStart],
            Self.tc("01:00:27:00", .fps29_97)
        )
        XCTAssertEqual(extractedTitle2Marker.context[.parentType], .story(.anyClip(.title)))
        XCTAssertEqual(extractedTitle2Marker.context[.parentName], "Basic Title 2")
        XCTAssertEqual(
            extractedTitle2Marker.context[.parentAbsoluteStart],
            Self.tc("01:00:20:00", .fps29_97)
        )
        XCTAssertEqual(
            extractedTitle2Marker.context[.parentDuration],
            Self.tc("00:00:10:00", .fps29_97)
        )
    }
    
    func testExtractMarkers_ExcludeTitle() throws {
        // load file
        
        let rawData = try fileContents
        
        // load
        
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        
        let event = try XCTUnwrap(fcpxml.allEvents().first)
        
        // extract markers
        
        let extractedMarkers = event.extractMarkers(
            settings: FinalCutPro.FCPXML.ExtractionSettings(
                // deep: true,
                excludeTypes: [.story(.anyClip(.title))],
                auditionMask: .activeAudition
            ), 
            ancestorsOfParent: []
        )
        XCTAssertEqual(extractedMarkers.count, 1)
        
        let extractedGapMarker = try XCTUnwrap(extractedMarkers[safe: 0])
        XCTAssertEqual(extractedGapMarker, try expectedGapMarker)
    }
    
    func testExtractMarkers_ExcludeGap() throws {
        // load file
        
        let rawData = try fileContents
        
        // load
        
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        
        let event = try XCTUnwrap(fcpxml.allEvents().first)
        
        // extract markers
        
        let extractedMarkers = event.extractMarkers(
            settings: FinalCutPro.FCPXML.ExtractionSettings(
                // deep: true,
                excludeTypes: [.story(.anyClip(.gap))],
                auditionMask: .activeAudition
            ),
            ancestorsOfParent: []
        )
        XCTAssertEqual(extractedMarkers.count, 2)
        
        let extractedTitle1Marker = try XCTUnwrap(extractedMarkers[safe: 0])
        XCTAssertEqual(extractedTitle1Marker, try expectedTitle1Marker)
        
        let extractedTitle2Marker = try XCTUnwrap(extractedMarkers[safe: 1])
        XCTAssertEqual(extractedTitle2Marker, try expectedTitle2Marker)
    }
    
    func testExtractMarkers_ExcludeGapAndTitle() throws {
        // load file
        
        let rawData = try fileContents
        
        // load
        
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        
        let event = try XCTUnwrap(fcpxml.allEvents().first)
        
        // extract markers
        
        let extractedMarkers = event.extractMarkers(
            settings: FinalCutPro.FCPXML.ExtractionSettings(
                // deep: true,
                excludeTypes: [.story(.anyClip(.gap)), .story(.anyClip(.title))],
                auditionMask: .activeAudition
            ),
            ancestorsOfParent: []
        )
        XCTAssertEqual(extractedMarkers.count, 0)
    }
}

#endif
