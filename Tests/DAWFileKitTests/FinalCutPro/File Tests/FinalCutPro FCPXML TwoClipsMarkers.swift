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
    
    /// Test markers contained on two clips in the same sequence, as well as a marker in a gap
    /// between the clips.
    func testParse() throws {
        // load file
        
        let rawData = try fileContents
        
        // load
        
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        
        let events = fcpxml.allEvents()
        XCTAssertEqual(events.count, 1)
        
        let event = try XCTUnwrap(events[safe: 0])
        XCTAssertEqual(event.name, "Test Event")
        
        // project
        
        let projects = event.projects.zeroIndexed
        XCTAssertEqual(projects.count, 1)
        
        let project = try XCTUnwrap(projects[safe: 0])
        
        // sequence
        
        let sequence = try XCTUnwrap(project.sequence)
        
        XCTAssertEqual(sequence.format, "r1")
        XCTAssertEqual(sequence.tcStartAsTimecode(), Self.tc("01:00:00:00", .fps29_97))
        XCTAssertEqual(sequence.tcStartAsTimecode()?.frameRate, .fps29_97)
        XCTAssertEqual(sequence.tcStartAsTimecode()?.subFramesBase, .max80SubFrames)
        XCTAssertEqual(sequence.durationAsTimecode(), Self.tc("00:00:30:00", .fps29_97))
        XCTAssertEqual(sequence.audioLayout, .stereo)
        XCTAssertEqual(sequence.audioRate, .rate48kHz)
        
        // spine
        
        let spine = try XCTUnwrap(sequence.spine)
        
        let storyElements = spine.storyElements.zeroIndexed
        XCTAssertEqual(storyElements.count, 3)
        
        // clips
        
        let title1 = try XCTUnwrap(storyElements[safe: 0]?.fcpAsTitle)
        let gap = try XCTUnwrap(storyElements[safe: 1]?.fcpAsGap)
        let title2 = try XCTUnwrap(storyElements[safe: 2]?.fcpAsTitle)
        
        // clip 1 - title
        
        XCTAssertEqual(title1.ref, "r2")
        XCTAssertEqual(title1.offsetAsTimecode(), Self.tc("01:00:00:00", .fps29_97))
        XCTAssertEqual(title1.offsetAsTimecode()?.frameRate, .fps29_97)
        XCTAssertEqual(title1.name, "Basic Title 1")
        XCTAssertEqual(title1.startAsTimecode(), Self.tc("01:00:00:00", .fps29_97))
        XCTAssertEqual(title1.startAsTimecode()?.frameRate, .fps29_97)
        XCTAssertEqual(title1.durationAsTimecode(), Self.tc("00:00:10:00", .fps29_97))
        XCTAssertEqual(title1.durationAsTimecode()?.frameRate, .fps29_97)
        
        // clip 2 - gap
        
        XCTAssertEqual(gap.offsetAsTimecode(), Self.tc("01:00:10:00", .fps29_97))
        XCTAssertEqual(gap.offsetAsTimecode()?.frameRate, .fps29_97)
        XCTAssertEqual(gap.name, "Gap")
        XCTAssertEqual(gap.startAsTimecode(), Self.tc("00:59:56:12", .fps29_97))
        XCTAssertEqual(gap.startAsTimecode()?.frameRate, .fps29_97)
        XCTAssertEqual(gap.durationAsTimecode(), Self.tc("00:00:10:00", .fps29_97))
        XCTAssertEqual(gap.durationAsTimecode()?.frameRate, .fps29_97)
        
        // clip 3 - title
        
        XCTAssertEqual(title2.ref, "r2")
        XCTAssertEqual(title2.offsetAsTimecode(), Self.tc("01:00:20:00", .fps29_97))
        XCTAssertEqual(title2.offsetAsTimecode()?.frameRate, .fps29_97)
        XCTAssertEqual(title2.name, "Basic Title 2")
        XCTAssertEqual(title2.startAsTimecode(), Self.tc("01:00:00:00", .fps29_97))
        XCTAssertEqual(title2.startAsTimecode()?.frameRate, .fps29_97)
        XCTAssertEqual(title2.durationAsTimecode(), Self.tc("00:00:10:00", .fps29_97))
        XCTAssertEqual(title2.durationAsTimecode()?.frameRate, .fps29_97)
        
        // markers in title 1
        
        let title1Markers = title1.contents
            .filter(whereFCPElement: .marker)
            .zeroIndexed
        
        // start is 4 seconds 15 frames elapsed in the title's local timeline.
        // the gap's local timeline starts at 01:00:00:00 so the marker's start is 01:00:04:15.
        XCTAssertEqual(title1Markers.count, 1)
        let title1Marker = try XCTUnwrap(title1Markers[safe: 0])
        XCTAssertEqual(title1Marker.startAsTimecode(), Self.tc("01:00:04:15", .fps29_97))
        XCTAssertEqual(title1Marker.durationAsTimecode(), Self.tc("00:00:00:01", .fps29_97))
        XCTAssertEqual(title1Marker.name, "Marker 1")
        XCTAssertEqual(title1Marker.configuration, .standard)
        XCTAssertEqual(title1Marker.note, nil)
        
        // markers in gap
        
        let gapMarkers = gap.contents
            .filter(whereFCPElement: .marker)
            .zeroIndexed
        
        // start is 5 seconds elapsed in the gap's local timeline.
        // the gap's local timeline starts at 00:59:56:12 so the marker's start is 01:00:01:12.
        // also, it seems that the duration is reduced to 1 audio sample at 48kHz - perhaps
        // in a gap, FCP reduces timing resolution to audio sample rate instead of video frame rate?
        XCTAssertEqual(gapMarkers.count, 1)
        let gapMarker = try XCTUnwrap(gapMarkers[safe: 0])
        XCTAssertEqual(gapMarker.startAsTimecode(), Self.tc("01:00:01:12", .fps29_97))
        XCTAssertEqual(
            gapMarker.durationAsTimecode(),
            try Timecode(.rational(1, 48000), at: .fps29_97, base: .max80SubFrames)
        )
        XCTAssertEqual(gapMarker.name, "Marker 2")
        XCTAssertEqual(gapMarker.configuration, .standard)
        XCTAssertEqual(gapMarker.note, nil)
        
        // markers in title 2
        
        let title2Markers = title2.contents
            .filter(whereFCPElement: .marker)
            .zeroIndexed
        
        // start is 7 seconds elapsed in the title's local timeline.
        // the gap's local timeline starts at 01:00:00:00 so the marker's start is 01:00:07:00.
        XCTAssertEqual(title2Markers.count, 1)
        let title2Marker = try XCTUnwrap(title2Markers[safe: 0])
        XCTAssertEqual(title2Marker.startAsTimecode(), Self.tc("01:00:07:00", .fps29_97))
        XCTAssertEqual(title2Marker.durationAsTimecode(), Self.tc("00:00:00:01", .fps29_97))
        XCTAssertEqual(title2Marker.name, "Marker 3")
        XCTAssertEqual(title2Marker.configuration, .standard)
        XCTAssertEqual(title2Marker.note, nil)
        
        // test single-element extraction
        let title2MarkerExtracted = title2Marker.element.fcpExtract()
        XCTAssertEqual(
            title2MarkerExtracted.value(forContext: .absoluteStartAsTimecode()),
            Self.tc("01:00:27:00", .fps29_97)
        )
    }
    
    func testExtractMarkers() throws {
        // load file
        
        let rawData = try fileContents
        
        // load
        
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        
        let event = try XCTUnwrap(fcpxml.allEvents().first)
        
        // extract markers
        
        let extractedMarkers = event
            .extractElements(preset: .markers, settings: .init())
            .zeroIndexed
        XCTAssertEqual(extractedMarkers.count, 3)
        
        let extractedTitle1Marker = try XCTUnwrap(extractedMarkers[safe: 0])
        XCTAssertEqual(extractedTitle1Marker.name, "Marker 1") // basic identity check
        XCTAssertEqual(extractedTitle1Marker.value(forContext: .ancestorEventName), "Test Event")
        XCTAssertEqual(extractedTitle1Marker.value(forContext: .ancestorProjectName), "TwoClipsMarkers")
        XCTAssertEqual(
            extractedTitle1Marker.value(forContext: .absoluteStartAsTimecode()),
            Self.tc("01:00:04:15", .fps29_97)
        )
        XCTAssertEqual(extractedTitle1Marker.value(forContext: .parentType), .title)
        XCTAssertEqual(extractedTitle1Marker.value(forContext: .parentName), "Basic Title 1")
        XCTAssertEqual(
            extractedTitle1Marker.value(forContext: .parentAbsoluteStartAsTimecode()),
            Self.tc("01:00:00:00", .fps29_97)
        )
        XCTAssertEqual(
            extractedTitle1Marker.value(forContext: .parentDurationAsTimecode()),
            Self.tc("00:00:10:00", .fps29_97)
        )
        
        let extractedGapMarker = try XCTUnwrap(extractedMarkers[safe: 1])
        XCTAssertEqual(extractedGapMarker.name, "Marker 2") // basic identity check
        XCTAssertEqual(extractedGapMarker.value(forContext: .ancestorEventName), "Test Event")
        XCTAssertEqual(extractedGapMarker.value(forContext: .ancestorProjectName), "TwoClipsMarkers")
        XCTAssertEqual(
            extractedGapMarker.value(forContext: .absoluteStartAsTimecode()),
            Self.tc("01:00:15:00", .fps29_97)
        )
        XCTAssertEqual(extractedGapMarker.value(forContext: .parentType), .gap)
        XCTAssertEqual(extractedGapMarker.value(forContext: .parentName), "Gap")
        XCTAssertEqual(
            extractedGapMarker.value(forContext: .parentAbsoluteStartAsTimecode()),
            Self.tc("01:00:10:00", .fps29_97)
        )
        XCTAssertEqual(
            extractedGapMarker.value(forContext: .parentDurationAsTimecode()),
            Self.tc("00:00:10:00", .fps29_97)
        )
        
        let extractedTitle2Marker = try XCTUnwrap(extractedMarkers[safe: 2])
        XCTAssertEqual(extractedTitle2Marker.name, "Marker 3")
        XCTAssertEqual(extractedTitle2Marker.value(forContext: .ancestorEventName), "Test Event")
        XCTAssertEqual(extractedTitle2Marker.value(forContext: .ancestorProjectName), "TwoClipsMarkers")
        XCTAssertEqual(
            extractedTitle2Marker.value(forContext: .absoluteStartAsTimecode()),
            Self.tc("01:00:27:00", .fps29_97)
        )
        XCTAssertEqual(extractedTitle2Marker.value(forContext: .parentType), .title)
        XCTAssertEqual(extractedTitle2Marker.value(forContext: .parentName), "Basic Title 2")
        XCTAssertEqual(
            extractedTitle2Marker.value(forContext: .parentAbsoluteStartAsTimecode()),
            Self.tc("01:00:20:00", .fps29_97)
        )
        XCTAssertEqual(
            extractedTitle2Marker.value(forContext: .parentDurationAsTimecode()),
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
        let settings = FinalCutPro.FCPXML.ExtractionSettings(
            excludedTraversalTypes: [.title]
        )
        let extractedMarkers = event
            .extractElements(preset: .markers, settings: settings)
            .zeroIndexed
        XCTAssertEqual(extractedMarkers.count, 1)
        
        let extractedGapMarker = try XCTUnwrap(extractedMarkers[safe: 0])
        XCTAssertEqual(extractedGapMarker.name, "Marker 2")
    }
    
    func testExtractMarkers_ExcludeGap() throws {
        // load file
        let rawData = try fileContents
        
        // load
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try XCTUnwrap(fcpxml.allEvents().first)
        
        // extract markers
        let settings = FinalCutPro.FCPXML.ExtractionSettings(
            excludedTraversalTypes: [.gap]
        )
        let extractedMarkers = event
            .extractElements(preset: .markers, settings: settings)
            .zeroIndexed
        XCTAssertEqual(extractedMarkers.count, 2)
        
        let extractedTitle1Marker = try XCTUnwrap(extractedMarkers[safe: 0])
        XCTAssertEqual(extractedTitle1Marker.name, "Marker 1")
        
        let extractedTitle2Marker = try XCTUnwrap(extractedMarkers[safe: 1])
        XCTAssertEqual(extractedTitle2Marker.name, "Marker 3")
    }
    
    func testExtractMarkers_ExcludeGapAndTitle() throws {
        // load file
        let rawData = try fileContents
        
        // load
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try XCTUnwrap(fcpxml.allEvents().first)
        
        // extract markers
        let settings = FinalCutPro.FCPXML.ExtractionSettings(
            excludedTraversalTypes: [.gap, .title]
        )
        let extractedMarkers = event
            .extractElements(preset: .markers, settings: settings)
            .zeroIndexed
        XCTAssertEqual(extractedMarkers.count, 0)
    }
}

#endif
