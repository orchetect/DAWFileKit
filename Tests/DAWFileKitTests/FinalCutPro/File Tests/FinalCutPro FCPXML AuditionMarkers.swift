//
//  FinalCutPro FCPXML AuditionMarkers.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
@testable import DAWFileKit
import OTCore
import TimecodeKit

final class FinalCutPro_FCPXML_AuditionMarkers: FCPXMLTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try XCTUnwrap(loadFileContents(
            forResource: "AuditionMarkers",
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
        XCTAssertEqual(spine.storyElements.count, 1)
        
        let storyElements = spine.storyElements.zeroIndexed
        
        let audition = try XCTUnwrap(storyElements[safe: 0]?.fcpAsAudition)
        XCTAssertEqual(audition.offsetAsTimecode(), Self.tc("01:00:00:00", .fps29_97))
        XCTAssertEqual(audition.offsetAsTimecode()?.frameRate, .fps29_97)
        XCTAssertEqual(audition.clips.count, 2)
        
        // "active" audition
        let audition1 = try XCTUnwrap(audition.clips[safe: 0]?.fcpAsTitle)
        XCTAssertEqual(audition1.ref, "r2")
        XCTAssertEqual(audition1.name, "Basic Title 1")
        XCTAssertEqual(audition1.startAsTimecode(), Self.tc("01:00:00:00", .fps29_97))
        XCTAssertEqual(audition1.startAsTimecode()?.frameRate, .fps29_97)
        XCTAssertEqual(audition1.durationAsTimecode(), Self.tc("00:00:10:00", .fps29_97))
        XCTAssertEqual(audition1.durationAsTimecode()?.frameRate, .fps29_97)
        
        // first "inactive" audition
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
        #warning("> TODO: finish this - but can't test absolute timecodes without running element extraction")
        // XCTAssertEqual(a1Marker.context[.absoluteStart], Self.tc("01:00:05:00", .fps29_97))
        // XCTAssertEqual(a1Marker.context[.parentType], .story(.anyClip(.title)))
        // XCTAssertEqual(a1Marker.context[.parentName], "Basic Title 1")
        // XCTAssertEqual(a1Marker.context[.parentAbsoluteStart], Self.tc("01:00:00:00", .fps29_97))
        // XCTAssertEqual(a1Marker.context[.parentDuration], Self.tc("00:00:10:00", .fps29_97))
        // XCTAssertEqual(a1Marker.context[.ancestorEventName], "Test Event")
        // XCTAssertEqual(a1Marker.context[.ancestorProjectName], "AuditionMarkers")
        
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
        #warning("> TODO: finish this - but can't test absolute timecodes without running element extraction")
        // XCTAssertEqual(a2Marker.context[.absoluteStart], Self.tc("01:00:02:00", .fps29_97))
        // XCTAssertEqual(a2Marker.context[.parentType], .story(.anyClip(.title)))
        // XCTAssertEqual(a2Marker.context[.parentName], "Basic Title 2")
        // XCTAssertEqual(a2Marker.context[.parentAbsoluteStart], Self.tc("01:00:00:00", .fps29_97))
        // XCTAssertEqual(a2Marker.context[.parentDuration], Self.tc("00:00:10:00", .fps29_97))
        // XCTAssertEqual(a2Marker.context[.ancestorEventName], "Test Event")
        // XCTAssertEqual(a2Marker.context[.ancestorProjectName], "AuditionMarkers")
    }
    
    #warning("> TODO: uncomment and fix unit tests")
    
    func testExtractMarkers_activeAudition() throws {
        // load file
        let rawData = try fileContents
        
        // load
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try XCTUnwrap(fcpxml.allEvents().first)
        
        // extract markers
        let settings = FinalCutPro.FCPXML.ExtractionSettings(
            auditions: .active
        )
        let extractedMarkers = event.extractElements(preset: .markers, settings: settings)
        XCTAssertEqual(extractedMarkers.count, 1)
        
        let marker = try XCTUnwrap(extractedMarkers.zeroIndexed[safe: 0])
        XCTAssertEqual(marker.name, "Marker 1")
    }
    
    func testExtractMarkers_allAuditions() throws {
        // load file
        let rawData = try fileContents
        
        // load
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try XCTUnwrap(fcpxml.allEvents().first)
        
        // extract markers
        let settings = FinalCutPro.FCPXML.ExtractionSettings(
            auditions: .all
        )
        let extractedMarkers = event.extractElements(preset: .markers, settings: settings)
        XCTAssertEqual(extractedMarkers.count, 2)
        
        let marker1 = try XCTUnwrap(extractedMarkers.zeroIndexed[safe: 0])
        XCTAssertEqual(marker1.name, "Marker 1")
        
        let marker2 = try XCTUnwrap(extractedMarkers.zeroIndexed[safe: 1])
        XCTAssertEqual(marker2.name, "Marker 2")
    }
}

#endif
