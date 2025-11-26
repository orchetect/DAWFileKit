//
//  FinalCutPro FCPXML Occlusion3.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
/* @testable */ import DAWFileTools
import SwiftExtensions
import TimecodeKitCore

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
    
    func testParseAndOcclusion() async throws {
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
        let extractedEvent = await event.element.fcpExtract()
        XCTAssertEqual(extractedEvent.value(forContext: .occlusion), .notOccluded)
        XCTAssertEqual(extractedEvent.value(forContext: .effectiveOcclusion), .notOccluded)
        
        // projects
        let projects = event.projects.zeroIndexed
        XCTAssertEqual(projects.count, 1)
        
        let project = try XCTUnwrap(projects[safe: 0])
        let extractedProject = await event.element.fcpExtract()
        XCTAssertEqual(extractedProject.value(forContext: .occlusion), .notOccluded)
        XCTAssertEqual(extractedProject.value(forContext: .effectiveOcclusion), .notOccluded)
        
        // sequence
        let sequence = project.sequence
        let extractedSequence = await sequence.element.fcpExtract()
        XCTAssertEqual(extractedSequence.value(forContext: .occlusion), .notOccluded)
        XCTAssertEqual(extractedSequence.value(forContext: .effectiveOcclusion), .notOccluded)
        
        // spine
        let spine = sequence.spine
        let storyElements = spine.storyElements.zeroIndexed
        XCTAssertEqual(storyElements.count, 3)
        
        // sync-clip 1
        
        let syncClip1 = try XCTUnwrap(storyElements[safe: 2]?.fcpAsSyncClip)
        XCTAssertEqual(syncClip1.name, "1-X-1")
        XCTAssertEqual(syncClip1.lane, nil)
        XCTAssertEqual(syncClip1.offsetAsTimecode(), Self.tc("00:59:58:09", .fps25))
        XCTAssertEqual(syncClip1.offsetAsTimecode()?.frameRate, .fps25)
        XCTAssertEqual(
            syncClip1.startAsTimecode(),
            Self.tc("19:54:56:13", .fps25)
        )
        XCTAssertEqual(syncClip1.durationAsTimecode(), Self.tc("00:00:02:07", .fps25))
        XCTAssertEqual(syncClip1.durationAsTimecode()?.frameRate, .fps25)
        let extractedSyncClip1 = await syncClip1.element.fcpExtract()
        XCTAssertEqual(
            extractedSyncClip1.value(forContext: .absoluteStartAsTimecode()),
            Self.tc("00:59:58:09", .fps25)
        )
        XCTAssertEqual(extractedSyncClip1.value(forContext: .occlusion), .notOccluded)
        XCTAssertEqual(extractedSyncClip1.value(forContext: .effectiveOcclusion), .notOccluded)
        
        let sc1Markers = syncClip1.storyElements.filter(whereFCPElement: .marker).zeroIndexed
        XCTAssertEqual(sc1Markers.count, 1)
        
        let sc1Marker = try XCTUnwrap(sc1Markers[safe: 0])
        XCTAssertEqual(sc1Marker.name, "Marker 2")
        let extractedSC1Marker = await sc1Marker.element.fcpExtract()
        XCTAssertEqual(
            extractedSC1Marker.value(forContext: .absoluteStartAsTimecode()),
            Self.tc("00:59:58:10", .fps25)
        )
        XCTAssertEqual(extractedSC1Marker.value(forContext: .occlusion), .notOccluded) // within syncclip1
        XCTAssertEqual(extractedSC1Marker.value(forContext: .effectiveOcclusion), .notOccluded) // main timeline
        
        // sync-clip 2 (within sync-clip 1, on separate lane)
        
        let syncClip1StoryElements = syncClip1.storyElements.zeroIndexed
        
        let syncClip2 = try XCTUnwrap(syncClip1StoryElements[safe: 3]?.fcpAsSyncClip)
        XCTAssertEqual(syncClip2.name, "1-2-2 MOS")
        XCTAssertEqual(syncClip2.lane, 1)
        XCTAssertEqual(
            syncClip2.offsetAsTimecode(),
            Self.tc("19:54:56:13", .fps25)
        )
        XCTAssertEqual(syncClip2.offsetAsTimecode()?.frameRate, .fps25)
        XCTAssertEqual(
            syncClip2.startAsTimecode(),
            Self.tc("19:19:01:08", .fps25)
        )
        XCTAssertEqual(syncClip2.durationAsTimecode(), Self.tc("00:00:02:07", .fps25))
        XCTAssertEqual(syncClip2.durationAsTimecode()?.frameRate, .fps25)
        let extractedSyncClip2 = await syncClip2.element.fcpExtract()
        XCTAssertEqual(
            extractedSyncClip2.value(forContext: .absoluteStartAsTimecode()),
            Self.tc("00:59:58:09", .fps25)
        )
        XCTAssertEqual(extractedSyncClip2.value(forContext: .occlusion), .notOccluded)
        XCTAssertEqual(extractedSyncClip2.value(forContext: .effectiveOcclusion), .notOccluded)
        
        let sc2Markers = syncClip2.storyElements.filter(whereFCPElement: .marker).zeroIndexed
        XCTAssertEqual(sc2Markers.count, 1)
        
        let sc2Marker = try XCTUnwrap(sc2Markers[safe: 0])
        XCTAssertEqual(sc2Marker.name, "Marker 1")
        let extractedSC2Marker = await sc2Marker.element.fcpExtract()
        XCTAssertEqual(
            extractedSC2Marker.value(forContext: .absoluteStartAsTimecode()),
            Self.tc("00:59:58:09", .fps25)
        )
        XCTAssertEqual(extractedSC2Marker.value(forContext: .occlusion), .notOccluded) // within syncclip2
        XCTAssertEqual(extractedSC2Marker.value(forContext: .effectiveOcclusion), .notOccluded) // main timeline
    }
    
    /// Test main timeline markers extraction with limited occlusion conditions.
    func testExtractMarkers_MainTimeline_LimitedOcclusions() async throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try XCTUnwrap(fcpxml.allEvents().first)
        
        // extract markers
        let extractedMarkers = await event
            .extract(preset: .markers, scope: .mainTimeline)
            .zeroIndexed
        XCTAssertEqual(extractedMarkers.count, 2)
        
        XCTAssertEqual(extractedMarkers.map(\.name), ["Marker 1", "Marker 2"])
    }
    
    /// Test main timeline markers extraction with all occlusion conditions.
    func testExtractMarkers_MainTimeline_AllOcclusions() async throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try XCTUnwrap(fcpxml.allEvents().first)
        
        // extract markers
        var scope: FinalCutPro.FCPXML.ExtractionScope = .mainTimeline
        scope.occlusions = .allCases
        let extractedMarkers = await event
            .extract(preset: .markers, scope: scope)
            .zeroIndexed
        XCTAssertEqual(extractedMarkers.count, 2)
        
        XCTAssertEqual(extractedMarkers.map(\.name), ["Marker 1", "Marker 2"])
    }
    
    /// Test deep markers extraction with all occlusion conditions.
    func testExtractMarkers_Deep_AllOcclusions() async throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try XCTUnwrap(fcpxml.allEvents().first)
        
        // extract markers
        var scope: FinalCutPro.FCPXML.ExtractionScope = .deep()
        scope.occlusions = .allCases
        let extractedMarkers = await event.extract(preset: .markers, scope: scope)
        XCTAssertEqual(extractedMarkers.count, 2)
        
        XCTAssertEqual(extractedMarkers.map(\.name), ["Marker 1", "Marker 2"])
    }
}

#endif
