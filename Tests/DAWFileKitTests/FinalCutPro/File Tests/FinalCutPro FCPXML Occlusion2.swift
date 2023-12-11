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
        let extractedEvent = event.element.fcpExtract()
        XCTAssertEqual(extractedEvent.value(forContext: .occlusion), .notOccluded)
        XCTAssertEqual(extractedEvent.value(forContext: .effectiveOcclusion), .notOccluded)
        
        // projects
        let projects = event.projects.zeroIndexed
        XCTAssertEqual(projects.count, 1)
        
        let project = try XCTUnwrap(projects[safe: 0])
        let extractedProject = event.element.fcpExtract()
        XCTAssertEqual(extractedProject.value(forContext: .occlusion), .notOccluded)
        XCTAssertEqual(extractedProject.value(forContext: .effectiveOcclusion), .notOccluded)
        
        // sequence
        let sequence = project.sequence
        let extractedSequence = sequence.element.fcpExtract()
        XCTAssertEqual(extractedSequence.value(forContext: .occlusion), .notOccluded)
        XCTAssertEqual(extractedSequence.value(forContext: .effectiveOcclusion), .notOccluded)
        
        // spine
        let spine = sequence.spine
        let storyElements = spine.storyElements.zeroIndexed
        XCTAssertEqual(storyElements.count, 1)
        
        // story elements
        
        // title1 is 00:00:05:01 long
        
        let title1 = try XCTUnwrap(storyElements[safe: 0]?.fcpAsTitle)
        XCTAssertEqual(title1.ref, "r2")
        XCTAssertEqual(title1.lane, nil)
        XCTAssertEqual(title1.offsetAsTimecode, Self.tc("00:59:50:00", .fps25))
        XCTAssertEqual(title1.offsetAsTimecode?.frameRate, .fps25)
        XCTAssertEqual(title1.name, "Basic Title 1")
        XCTAssertEqual(title1.startAsTimecode, Self.tc("01:00:00:00", .fps25))
        XCTAssertEqual(title1.durationAsTimecode, Self.tc("00:00:05:01", .fps25))
        XCTAssertEqual(title1.durationAsTimecode?.frameRate, .fps25)
        
        let extractedTitle1 = title1.element.fcpExtract()
        XCTAssertEqual(
            extractedTitle1.value(forContext: .absoluteStartAsTimecode),
            Self.tc("00:59:50:00", .fps25)
        )
        XCTAssertEqual(extractedTitle1.value(forContext: .occlusion), .notOccluded)
        XCTAssertEqual(extractedTitle1.value(forContext: .effectiveOcclusion), .notOccluded)
        
        let title1Markers = title1.storyElements.filter(whereFCPElement: .marker).zeroIndexed
        XCTAssertEqual(title1Markers.count, 0)
        
        // title2 is a child of title1, and is 00:05:37:11 long but in a different lane.
        // this allows Final Cut Pro to show the whole 5 min 37 sec 11 frames on the timeline,
        // however it hides markers on title2 that are out of bounds of title1.
        
        let title2 = try XCTUnwrap(title1.storyElements.zeroIndexed[safe: 0]?.fcpAsTitle)
        XCTAssertEqual(title2.ref, "r2")
        XCTAssertEqual(title2.lane, 1)
        XCTAssertEqual(title2.offsetAsTimecode, Self.tc("01:00:00:00", .fps25))
        XCTAssertEqual(title2.offsetAsTimecode?.frameRate, .fps25)
        XCTAssertEqual(title2.name, "Basic Title 2")
        XCTAssertEqual(title2.startAsTimecode, Self.tc("01:00:00:00", .fps25))
        XCTAssertEqual(title2.durationAsTimecode, Self.tc("00:05:37:11", .fps25))
        XCTAssertEqual(title2.durationAsTimecode?.frameRate, .fps25)
        
        let extractedTitle2 = title2.element.fcpExtract()
        XCTAssertEqual(
            extractedTitle2.value(forContext: .absoluteStartAsTimecode),
            Self.tc("00:59:50:00", .fps25)
        )
        XCTAssertEqual(extractedTitle2.value(forContext: .occlusion), .partiallyOccluded)
        XCTAssertEqual(extractedTitle2.value(forContext: .effectiveOcclusion), .partiallyOccluded)
        
        let title2StoryElements = title2.storyElements.zeroIndexed
        XCTAssertEqual(title2StoryElements.count, 2)
        
        let title2Markers = title2StoryElements.filter(whereFCPElement: .marker).zeroIndexed
        XCTAssertEqual(title2Markers.count, 2)
        
        let title2M1 = try XCTUnwrap(title2Markers[safe: 0])
        XCTAssertEqual(title2M1.name, "Visible on Main Timeline")
        
        let extractedTitle2M1 = title2M1.element.fcpExtract()
        XCTAssertEqual(
            extractedTitle2M1.value(forContext: .absoluteStartAsTimecode),
            Self.tc("01:00:01:00", .fps25)
        )
        XCTAssertEqual(extractedTitle2M1.value(forContext: .occlusion), .notOccluded) // within title2
        XCTAssertEqual(extractedTitle2M1.value(forContext: .effectiveOcclusion), .notOccluded) // main timeline
        
        // this marker is visible on main timeline because even though it's on an interior
        // title, the interior title is on its own lane so it's not occluded by the outer title.
        let title2M2 = try XCTUnwrap(title2Markers[safe: 1])
        
        XCTAssertEqual(title2M2.name, "Not Visible on Main Timeline")
        
        let extractedTitle2M2 = title2M2.element.fcpExtract()
        XCTAssertEqual(
            extractedTitle2M2.value(forContext: .absoluteStartAsTimecode),
            Self.tc("01:01:30:00", .fps25)
        )
        XCTAssertEqual(extractedTitle2M2.value(forContext: .occlusion), .notOccluded) // within title2
        XCTAssertEqual(extractedTitle2M2.value(forContext: .effectiveOcclusion), .notOccluded) // main timeline
    }
}

#endif
