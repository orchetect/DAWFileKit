//
//  FinalCutPro FCPXML Occlusion2.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
/* @testable */ import DAWFileKit
import OTCore
import TimecodeKit

final class FinalCutPro_FCPXML_Occlusion2: FCPXMLTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try XCTUnwrap(loadFileContents(
            forResource: "Occlusion2",
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
        XCTAssertEqual(spine.contents.count, 1)
        
        // story elements
        
        // title1 is 00:00:05:01 long
        
        guard case let .anyClip(.title(title1)) = spine.contents[safe: 0]
        else { XCTFail("Clip was not expected type.") ; return }
        
        XCTAssertEqual(title1.ref, "r2")
        XCTAssertEqual(title1.lane, nil)
        XCTAssertEqual(title1.offset, Self.tc("00:59:50:00", .fps25))
        XCTAssertEqual(title1.offset?.frameRate, .fps25)
        XCTAssertEqual(title1.name, "Basic Title 1")
        XCTAssertEqual(title1.start, Self.tc("01:00:00:00", .fps25))
        XCTAssertEqual(title1.duration, Self.tc("00:00:05:01", .fps25))
        XCTAssertEqual(title1.duration?.frameRate, .fps25)
        XCTAssertEqual(title1.context[.absoluteStart], Self.tc("00:59:50:00", .fps25))
        XCTAssertEqual(title1.context[.occlusion], .notOccluded)
        
        let title1Markers = title1.contents.annotations().markers()
        XCTAssertEqual(title1Markers.count, 0)
        
        // title2 is a child of title1, and is 00:05:37:11 long but in a different lane.
        // this allows Final Cut Pro to show the whole 5 min 37 sec 11 frames on the timeline,
        // however it hides markers on title2 that are out of bounds of title1.
        
        guard case let .anyClip(.title(title2)) = title1.contents[safe: 0]
        else { XCTFail("Clip was not expected type.") ; return }
        XCTAssertEqual(title2.ref, "r2")
        XCTAssertEqual(title2.lane, 1)
        XCTAssertEqual(title2.offset, Self.tc("01:00:00:00", .fps25))
        XCTAssertEqual(title2.offset?.frameRate, .fps25)
        XCTAssertEqual(title2.name, "Basic Title 2")
        XCTAssertEqual(title2.start, Self.tc("01:00:00:00", .fps25))
        XCTAssertEqual(title2.duration, Self.tc("00:05:37:11", .fps25))
        XCTAssertEqual(title2.duration?.frameRate, .fps25)
        XCTAssertEqual(title2.context[.absoluteStart], Self.tc("00:59:50:00", .fps25))
        XCTAssertEqual(title2.context[.occlusion], .partiallyOccluded)
        XCTAssertEqual(title2.context[.effectiveOcclusion], .partiallyOccluded)
        
        let title2Markers = title2.contents.annotations().markers()
        XCTAssertEqual(title2Markers.count, 2)
        
        let title2M1 = try XCTUnwrap(title2Markers[safe: 0])
        XCTAssertEqual(title2M1.name, "Visible on Main Timeline")
        XCTAssertEqual(title2M1.context[.absoluteStart], Self.tc("01:00:01:00", .fps25))
        XCTAssertEqual(title2M1.context[.occlusion], .notOccluded) // within title2
        XCTAssertEqual(title2M1.context[.effectiveOcclusion], .notOccluded) // main timeline
        
        // this marker is visible on main timeline because even though it's on an interior
        // title, the interior title is on its own lane so it's not occluded by the outer title.
        let title2M2 = try XCTUnwrap(title2Markers[safe: 1])
        XCTAssertEqual(title2M2.name, "Not Visible on Main Timeline")
        XCTAssertEqual(title2M2.context[.absoluteStart], Self.tc("01:01:30:00", .fps25))
        XCTAssertEqual(title2M2.context[.occlusion], .notOccluded) // within title2
        XCTAssertEqual(title2M2.context[.effectiveOcclusion], .notOccluded) // main timeline
    }
}

#endif
