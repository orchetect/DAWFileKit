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
        let resources = fcpxml.resources()
        XCTAssertEqual(resources.count, 2)
        
        // events
        let events = fcpxml.allEvents()
        XCTAssertEqual(events.count, 1)
        
        // project
        let projects = try XCTUnwrap(events[safe: 0]).projects
        XCTAssertEqual(projects.count, 1)
        let project = try XCTUnwrap(projects[safe: 0])
        
        // sequence
        let sequence = project.sequence
        
        // story elements (clips etc.)
        
        let spine = sequence.spine
        XCTAssertEqual(spine.elements.count, 1)
                
        guard case let .anyClip(.audition(audition)) = try XCTUnwrap(spine.elements[safe: 0])
        else { XCTFail("Clip was not expected type.") ; return }
        XCTAssertEqual(audition.clips.count, 2)
        
        XCTAssertEqual(audition.offset, Self.tc("01:00:00:00", .fps29_97))
        XCTAssertEqual(audition.offset?.frameRate, .fps29_97)
        
        // "active" audition
        guard case let .title(audition1) = try XCTUnwrap(audition.clips[safe: 0])
        else { XCTFail("Clip was not expected type.") ; return }
        
        XCTAssertEqual(audition1.ref, "r2")
        XCTAssertEqual(audition1.name, "Basic Title 1")
        XCTAssertEqual(audition1.start, Self.tc("01:00:00:00", .fps29_97))
        XCTAssertEqual(audition1.start?.frameRate, .fps29_97)
        XCTAssertEqual(audition1.duration, Self.tc("00:00:10:00", .fps29_97))
        XCTAssertEqual(audition1.duration?.frameRate, .fps29_97)
        
        // first "inactive" audition
        guard case let .title(audition2) = try XCTUnwrap(audition.clips[safe: 1])
        else { XCTFail("Clip was not expected type.") ; return }
        
        XCTAssertEqual(audition2.ref, "r2")
        XCTAssertEqual(audition2.name, "Basic Title 2")
        XCTAssertEqual(audition2.start, Self.tc("01:00:00:00", .fps29_97))
        XCTAssertEqual(audition2.start?.frameRate, .fps29_97)
        XCTAssertEqual(audition2.duration, Self.tc("00:00:10:00", .fps29_97))
        XCTAssertEqual(audition2.duration?.frameRate, .fps29_97)
        
        // markers
        
        let audition1Markers = audition1.contents.annotations().markers()
        XCTAssertEqual(audition1Markers.count, 1)
        
        let a1Marker = try XCTUnwrap(audition1Markers[safe: 0])
        XCTAssertEqual(a1Marker.start, Self.tc("01:00:05:00", .fps29_97))
        XCTAssertEqual(a1Marker.duration, Self.tc("00:00:00:01", .fps29_97))
        XCTAssertEqual(a1Marker.name, "Marker 1")
        XCTAssertEqual(a1Marker.metaData, .standard)
        XCTAssertEqual(a1Marker.note, nil)
        XCTAssertEqual(a1Marker.context[.absoluteStart], Self.tc("01:00:05:00", .fps29_97))
        XCTAssertEqual(a1Marker.context[.parentType], .story(.anyClip(.title)))
        XCTAssertEqual(a1Marker.context[.parentName], "Basic Title 1")
        XCTAssertEqual(a1Marker.context[.parentAbsoluteStart], Self.tc("01:00:00:00", .fps29_97))
        XCTAssertEqual(a1Marker.context[.parentDuration], Self.tc("00:00:10:00", .fps29_97))
        XCTAssertEqual(a1Marker.context[.ancestorEventName], "Test Event")
        XCTAssertEqual(a1Marker.context[.ancestorProjectName], "AuditionMarkers")
        
        let audition2Markers = audition2.contents.annotations().markers()
        XCTAssertEqual(audition2Markers.count, 1)
        
        let a2Marker = try XCTUnwrap(audition2Markers[safe: 0])
        XCTAssertEqual(a2Marker.start, Self.tc("01:00:02:00", .fps29_97))
        XCTAssertEqual(a2Marker.duration, Self.tc("00:00:00:01", .fps29_97))
        XCTAssertEqual(a2Marker.name, "Marker 2")
        XCTAssertEqual(a2Marker.metaData, .standard)
        XCTAssertEqual(a2Marker.note, nil)
        XCTAssertEqual(a2Marker.context[.absoluteStart], Self.tc("01:00:02:00", .fps29_97))
        XCTAssertEqual(a2Marker.context[.parentType], .story(.anyClip(.title)))
        XCTAssertEqual(a2Marker.context[.parentName], "Basic Title 2")
        XCTAssertEqual(a2Marker.context[.parentAbsoluteStart], Self.tc("01:00:00:00", .fps29_97))
        XCTAssertEqual(a2Marker.context[.parentDuration], Self.tc("00:00:10:00", .fps29_97))
        XCTAssertEqual(a2Marker.context[.ancestorEventName], "Test Event")
        XCTAssertEqual(a2Marker.context[.ancestorProjectName], "AuditionMarkers")
    }
    
    func testExtractMarkers_activeAudition() throws {
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
        XCTAssertEqual(extractedMarkers.count, 1)
        
        let marker = try XCTUnwrap(extractedMarkers[safe: 0])
        XCTAssertEqual(marker.name, "Marker 1")
    }
    
    func testExtractMarkers_allAudition() throws {
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
                auditionMask: .allAuditions
            ),
            ancestorsOfParent: []
        )
        XCTAssertEqual(extractedMarkers.count, 2)
        
        let marker1 = try XCTUnwrap(extractedMarkers[safe: 0])
        XCTAssertEqual(marker1.name, "Marker 1")
        
        let marker2 = try XCTUnwrap(extractedMarkers[safe: 1])
        XCTAssertEqual(marker2.name, "Marker 2")
    }
}

#endif
