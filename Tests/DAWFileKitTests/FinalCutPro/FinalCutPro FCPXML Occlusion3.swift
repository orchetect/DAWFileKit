//
//  FinalCutPro FCPXML Occlusion3.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
/* @testable */ import DAWFileKit
import OTCore
import TimecodeKit

final class FinalCutPro_FCPXML_Occlusion3: FCPXMLTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try XCTUnwrap(loadFileContents(
            forResource: "Occlusion3",
            withExtension: "fcpxml",
            subFolder: .fcpxmlExports
        ))
    } }
    
    func testParseAndOcclusion() throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // resources
        // let resources = fcpxml.resources()
        
        // events
        let events = fcpxml.allEvents()
        XCTAssertEqual(events.count, 1)
        
        let event = try XCTUnwrap(events[safe: 0])
        XCTAssertEqual(event.name, "Test Event")
        XCTAssertEqual(event.context[.occlusion], .notOccluded)
        
        // projects
        let projects = event.projects
        XCTAssertEqual(projects.count, 1)
        
        let project = try XCTUnwrap(projects.first)
        XCTAssertEqual(project.context[.occlusion], .notOccluded)
        
        // sequence
        let sequence = project.sequence
        XCTAssertEqual(sequence.context[.occlusion], .notOccluded)
        
        // spine
        let spine = sequence.spine
        XCTAssertEqual(spine.contents.count, 3)
        
        // sync-clip 1
        
        guard case let .anyClip(.syncClip(syncClip1)) = spine.contents[safe: 2]
        else { XCTFail("Clip was not expected type.") ; return }
        
        XCTAssertEqual(syncClip1.lane, nil)
        XCTAssertEqual(syncClip1.offset, Self.tc("00:59:58:09", .fps25))
        XCTAssertEqual(syncClip1.offset?.frameRate, .fps25)
        XCTAssertEqual(syncClip1.name, "1-X-1")
        XCTAssertEqual(
            syncClip1.start,
            try Self.tc("19:54:56:13", .fps25)
                .subtracting(.frames(0, subFrames: 1)) // TODO: subframes aliasing
        )
        XCTAssertEqual(syncClip1.duration, Self.tc("00:00:02:07", .fps25))
        XCTAssertEqual(syncClip1.duration?.frameRate, .fps25)
        XCTAssertEqual(syncClip1.context[.absoluteStart], Self.tc("00:59:58:09", .fps25))
        XCTAssertEqual(syncClip1.context[.occlusion], .notOccluded)
        XCTAssertEqual(syncClip1.context[.effectiveOcclusion], .notOccluded)
        
        let sc1Markers = syncClip1.contents.annotations().markers()
        XCTAssertEqual(sc1Markers.count, 1)
        
        let sc1Marker = try XCTUnwrap(sc1Markers[safe: 0])
        XCTAssertEqual(sc1Marker.name, "Marker 2")
        XCTAssertEqual(
            sc1Marker.context[.absoluteStart],
            try Self.tc("00:59:58:10", .fps25)
                .adding(.frames(0, subFrames: 1)) // TODO: subframes aliasing
        )
        XCTAssertEqual(sc1Marker.context[.occlusion], .notOccluded) // within syncclip1
        XCTAssertEqual(sc1Marker.context[.effectiveOcclusion], .notOccluded) // main timeline
        
        // sync-clip 2 (within sync-clip 1, on separate lane)
        
        guard case let .anyClip(.syncClip(syncClip2)) = syncClip1.contents[safe: 3]
        else { XCTFail("Clip was not expected type.") ; return }
        
        XCTAssertEqual(syncClip2.lane, 1)
        XCTAssertEqual(
            syncClip2.offset,
            try Self.tc("19:54:56:13", .fps25)
                .subtracting(.frames(0, subFrames: 1)) // TODO: subframes aliasing
        )
        XCTAssertEqual(syncClip2.offset?.frameRate, .fps25)
        XCTAssertEqual(syncClip2.name, "1-2-2 MOS")
        XCTAssertEqual(
            syncClip2.start,
            try Self.tc("19:19:01:08", .fps25)
                .subtracting(.frames(0, subFrames: 1)) // TODO: subframes aliasing
        )
        XCTAssertEqual(syncClip2.duration, Self.tc("00:00:02:07", .fps25))
        XCTAssertEqual(syncClip2.duration?.frameRate, .fps25)
        XCTAssertEqual(syncClip2.context[.absoluteStart], Self.tc("00:59:58:09", .fps25))
        XCTAssertEqual(syncClip2.context[.occlusion], .notOccluded)
        XCTAssertEqual(syncClip2.context[.effectiveOcclusion], .notOccluded)
        
        let sc2Markers = syncClip2.contents.annotations().markers()
        XCTAssertEqual(sc2Markers.count, 1)
        
        let sc2Marker = try XCTUnwrap(sc2Markers[safe: 0])
        XCTAssertEqual(sc2Marker.name, "Marker 1")
        XCTAssertEqual(sc2Marker.context[.absoluteStart], Self.tc("00:59:58:09", .fps25))
        XCTAssertEqual(sc2Marker.context[.occlusion], .notOccluded) // within syncclip2
        XCTAssertEqual(sc2Marker.context[.effectiveOcclusion], .notOccluded) // main timeline
    }
    
    /// Test main timeline markers extraction with limited occlusion conditions.
    func testExtractMarkers_MainTimeline_LimitedOcclusions() throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try XCTUnwrap(fcpxml.allEvents().first)
        
        // extract markers
        let extractedMarkers = event.extractElements(preset: .markers, settings: .mainTimeline)
        XCTAssertEqual(extractedMarkers.count, 2)
        
        XCTAssertEqual(
            extractedMarkers.map(\.name),
            ["Marker 1", "Marker 2"]
        )
    }
    
    /// Test main timeline markers extraction with all occlusion conditions.
    func testExtractMarkers_MainTimeline_AllOcclusions() throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try XCTUnwrap(fcpxml.allEvents().first)
        
        // extract markers
        var settings = FinalCutPro.FCPXML.ExtractionSettings.mainTimeline
        settings.occlusions = .allCases
        let extractedMarkers = event.extractElements(preset: .markers, settings: settings)
        XCTAssertEqual(extractedMarkers.count, 2)
        
        XCTAssertEqual(extractedMarkers.map(\.name), ["Marker 1", "Marker 2"])
    }
    
    /// Test deep markers extraction with all occlusion conditions.
    func testExtractMarkers_Deep_AllOcclusions() throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try XCTUnwrap(fcpxml.allEvents().first)
        
        // extract markers
        var settings = FinalCutPro.FCPXML.ExtractionSettings.deep()
        settings.occlusions = .allCases
        let extractedMarkers = event.extractElements(preset: .markers, settings: settings)
        XCTAssertEqual(extractedMarkers.count, 2)
        
        XCTAssertEqual(extractedMarkers.map(\.name), ["Marker 1", "Marker 2"])
    }
}

#endif
