//
//  FinalCutPro FCPXML AuditionMarkers2.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
@testable import DAWFileKit
import SwiftExtensions
import TimecodeKit

final class FinalCutPro_FCPXML_AuditionMarkers2: FCPXMLTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try XCTUnwrap(loadFileContents(
            forResource: "AuditionMarkers2",
            withExtension: "fcpxml",
            subFolder: .fcpxmlExports
        ))
    } }
    
    func testParse() throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // version
        XCTAssertEqual(fcpxml.version, .ver1_11)
        
        // resources
        let resources = fcpxml.root.resources
        XCTAssertEqual(resources.childElements.count, 2)
        
        // events
        let events = fcpxml.allEvents()
        XCTAssertEqual(events.count, 1)
        
        let event = try XCTUnwrap(events[safe: 0])
        
        // project
        let projects = event.projects.zeroIndexed
        XCTAssertEqual(projects.count, 1)
        
        // let project = try XCTUnwrap(projects[safe: 0])
        
        // sequence
        let sequence = try XCTUnwrap(projects[safe: 0]?.sequence)
        
        // story elements (clips etc.)
        
        let spine = try XCTUnwrap(sequence.spine)
        XCTAssertEqual(spine.storyElements.count, 2)
        
        let storyElements = spine.storyElements.zeroIndexed
        
        let audition = try XCTUnwrap(storyElements[safe: 1]?.fcpAsAudition)
        XCTAssertEqual(audition.offsetAsTimecode(), Self.tc("01:00:01:00", .fps29_97))
        XCTAssertEqual(audition.offsetAsTimecode()?.frameRate, .fps29_97)
        XCTAssertEqual(audition.clips.count, 2)
        
        // "active" audition - was resized
        let audition1 = try XCTUnwrap(audition.clips[safe: 0]?.fcpAsTitle)
        XCTAssertEqual(audition1.ref, "r2")
        XCTAssertEqual(audition1.name, "Basic Title 1")
        XCTAssertEqual(audition1.startAsTimecode(), Self.tc("01:00:02:00", .fps29_97))
        XCTAssertEqual(audition1.startAsTimecode()?.frameRate, .fps29_97)
        XCTAssertEqual(audition1.durationAsTimecode(), Self.tc("00:00:08:00", .fps29_97))
        XCTAssertEqual(audition1.durationAsTimecode()?.frameRate, .fps29_97)
        
        // first "inactive" audition - was not resized
        let audition2 = try XCTUnwrap(audition.clips[safe: 1]?.fcpAsTitle)
        XCTAssertEqual(audition2.ref, "r2")
        XCTAssertEqual(audition2.name, "Basic Title 2")
        XCTAssertEqual(audition2.startAsTimecode(), Self.tc("01:00:00:00", .fps29_97))
        XCTAssertEqual(audition2.startAsTimecode()?.frameRate, .fps29_97)
        XCTAssertEqual(audition2.durationAsTimecode(), Self.tc("00:00:10:00", .fps29_97))
        XCTAssertEqual(audition2.durationAsTimecode()?.frameRate, .fps29_97)
        
        // markers
        
        let audition1Markers = audition1.contents
            .filter(whereFCPElement: .marker)
            .zeroIndexed
        XCTAssertEqual(audition1Markers.count, 1)
        
        let a1Marker = try XCTUnwrap(audition1Markers[safe: 0])
        XCTAssertEqual(a1Marker.startAsTimecode(), Self.tc("01:00:05:00", .fps29_97))
        XCTAssertEqual(a1Marker.durationAsTimecode(), Self.tc("00:00:00:01", .fps29_97))
        XCTAssertEqual(a1Marker.name, "Marker 1")
        XCTAssertEqual(a1Marker.configuration, .standard)
        XCTAssertEqual(a1Marker.note, nil)
        
        let audition2Markers = audition2.contents
            .filter(whereFCPElement: .marker)
            .zeroIndexed
        
        XCTAssertEqual(audition2Markers.count, 1)
        
        let a2Marker = try XCTUnwrap(audition2Markers[safe: 0])
        XCTAssertEqual(a2Marker.startAsTimecode(), Self.tc("01:00:02:00", .fps29_97))
        XCTAssertEqual(a2Marker.durationAsTimecode(), Self.tc("00:00:00:01", .fps29_97))
        XCTAssertEqual(a2Marker.name, "Marker 2")
        XCTAssertEqual(a2Marker.configuration, .standard)
        XCTAssertEqual(a2Marker.note, nil)
    }
    
    func testExtractMarkers_activeAudition() async throws {
        // load file
        let rawData = try fileContents
        
        // load
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try XCTUnwrap(fcpxml.allEvents().first)
        
        // extract markers
        let scope = FinalCutPro.FCPXML.ExtractionScope(
            auditions: .active
        )
        let extractedMarkers = await event.extract(preset: .markers, scope: scope)
        XCTAssertEqual(extractedMarkers.count, 1)
        
        let marker = try XCTUnwrap(extractedMarkers.zeroIndexed[safe: 0])
        XCTAssertEqual(marker.name, "Marker 1")
    }
    
    func testExtractMarkers_allAuditions() async throws {
        // load file
        let rawData = try fileContents
        
        // load
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try XCTUnwrap(fcpxml.allEvents().first)
        
        // extract markers
        let scope = FinalCutPro.FCPXML.ExtractionScope(
            auditions: .all
        )
        let extractedMarkers = await event.extract(preset: .markers, scope: scope)
        XCTAssertEqual(extractedMarkers.count, 2)
        
        let marker1 = try XCTUnwrap(extractedMarkers.zeroIndexed[safe: 0])
        XCTAssertEqual(marker1.name, "Marker 1")
        XCTAssertEqual(marker1.value(forContext: .absoluteStartAsTimecode()), Self.tc("01:00:04:00", .fps29_97))
        XCTAssertEqual(marker1.value(forContext: .parentType), .title)
        XCTAssertEqual(marker1.value(forContext: .parentName), "Basic Title 1")
        XCTAssertEqual(marker1.value(forContext: .parentAbsoluteStartAsTimecode()), Self.tc("01:00:01:00", .fps29_97))
        XCTAssertEqual(marker1.value(forContext: .parentDurationAsTimecode()), Self.tc("00:00:08:00", .fps29_97))
        XCTAssertEqual(marker1.value(forContext: .ancestorEventName), "Test Event")
        XCTAssertEqual(marker1.value(forContext: .ancestorProjectName), "AuditionMarkers2")
        
        let marker2 = try XCTUnwrap(extractedMarkers.zeroIndexed[safe: 1])
        XCTAssertEqual(marker2.name, "Marker 2")
        XCTAssertEqual(marker2.value(forContext: .absoluteStartAsTimecode()), Self.tc("01:00:03:00", .fps29_97))
        XCTAssertEqual(marker2.value(forContext: .parentType), .title)
        XCTAssertEqual(marker2.value(forContext: .parentName), "Basic Title 2")
        XCTAssertEqual(marker2.value(forContext: .parentAbsoluteStartAsTimecode()), Self.tc("01:00:01:00", .fps29_97))
        XCTAssertEqual(marker2.value(forContext: .parentDurationAsTimecode()), Self.tc("00:00:10:00", .fps29_97))
        XCTAssertEqual(marker2.value(forContext: .ancestorEventName), "Test Event")
        XCTAssertEqual(marker2.value(forContext: .ancestorProjectName), "AuditionMarkers2")
    }
}

#endif
