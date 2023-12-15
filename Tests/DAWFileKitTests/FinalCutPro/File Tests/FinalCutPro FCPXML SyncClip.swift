//
//  FinalCutPro FCPXML SyncClip.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
/* @testable */ import DAWFileKit
import OTCore
import TimecodeKit

final class FinalCutPro_FCPXML_SyncClip: FCPXMLTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try XCTUnwrap(loadFileContents(
            forResource: "SyncClip",
            withExtension: "fcpxml",
            subFolder: .fcpxmlExports
        ))
    } }
    
    /// Ensure that elements that can appear in various locations in the XML hierarchy are all found.
    func testParse() throws {
        // load file
        let rawData = try fileContents
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let events = fcpxml.allEvents()
        XCTAssertEqual(events.count, 1)
        
        let event = try XCTUnwrap(events[safe: 0])
        XCTAssertEqual(event.name, "TestEvent")
        
        // project
        let projects = event.projects.zeroIndexed
        XCTAssertEqual(projects.count, 1)
        
        let project = try XCTUnwrap(projects[safe: 0])
        
        // sequence
        let sequence = try XCTUnwrap(project.sequence)
        
        // spine
        let spine = try XCTUnwrap(sequence.spine)
        
        let storyElements = spine.storyElements.zeroIndexed
        XCTAssertEqual(storyElements.count, 1)
        
        // story elements
        let syncClip = try XCTUnwrap(storyElements[safe: 0]?.fcpAsSyncClip)
        XCTAssertEqual(syncClip.format, "r2")
        XCTAssertEqual(syncClip.offsetAsTimecode(), Self.tc("01:00:00:00", .fps25))
        XCTAssertEqual(syncClip.offsetAsTimecode()?.frameRate, .fps25)
        XCTAssertEqual(syncClip.name, "TestVideo - Synchronized Clip")
        XCTAssertEqual(syncClip.startAsTimecode(), nil)
        XCTAssertEqual(syncClip.durationAsTimecode(), Self.tc("00:00:29:13", .fps25))
        XCTAssertEqual(syncClip.durationAsTimecode()?.frameRate, .fps25)
        
        // let syncClipStoryElements = syncClip.storyElements.zeroIndexed
        //
        // let assetClip = try XCTUnwrap(syncClipStoryElements[safe: 0]?.fcpAsAssetClip)
    }
    
    /// Test main timeline markers extraction.
    func testExtractMarkers_MainTimeline() async throws {
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
        XCTAssertEqual(extractedMarkers.count, 1)
        
        let marker = try XCTUnwrap(extractedMarkers[safe: 0])
        XCTAssertEqual(marker.name, "Marker on Sync Clip")
        XCTAssertEqual(marker.timecode(), Self.tc("01:00:10:00", .fps25))
        XCTAssertEqual(marker.value(forContext: .occlusion), .notOccluded)
        XCTAssertEqual(marker.value(forContext: .effectiveOcclusion), .notOccluded)
        XCTAssertEqual(marker.value(forContext: .inheritedRoles), [
            .inherited(.video(raw: "Sample Role")!), // markers can never have 'assigned' roles
            .inherited(.audio(raw: "effects.effects-1")!) // markers can never have 'assigned' roles
        ])
    }
    
    /// Test deep markers extraction.
    func testExtractMarkers_Deep() async throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try XCTUnwrap(fcpxml.allEvents().first)
        
        // extract markers
        let extractedMarkers = await event
            .extract(preset: .markers, scope: .deep())
            .zeroIndexed
        XCTAssertEqual(extractedMarkers.count, 3)
        
        // In FCP, a Sync Clip does not bear roles itself.
        // Instead, it inherits the video and audio role of the asset clip(s) within it.
        
        let marker0 = try XCTUnwrap(extractedMarkers[safe: 0])
        XCTAssertEqual(marker0.name, "Marker on Audio")
        XCTAssertEqual(marker0.model.startAsTimecode(), Self.tc("00:00:03:00", .fps25))
        XCTAssertEqual(marker0.timecode(), Self.tc("01:00:03:00", .fps25))
        XCTAssertEqual(marker0.value(forContext: .occlusion), .notOccluded)
        XCTAssertEqual(marker0.value(forContext: .effectiveOcclusion), .notOccluded)
        XCTAssertEqual(marker0.value(forContext: .inheritedRoles), [
            .inherited(.video(raw: "Sample Role")!), // markers can never have 'assigned' roles
            .inherited(.audio(raw: "effects.effects-1")!) // markers can never have 'assigned' roles
        ])
        
        let marker1 = try XCTUnwrap(extractedMarkers[safe: 1])
        XCTAssertEqual(marker1.name, "Marker on TestVideo")
        XCTAssertEqual(marker1.model.startAsTimecode(), Self.tc("00:00:27:10", .fps25))
        XCTAssertEqual(marker1.timecode(), Self.tc("01:00:27:10", .fps25))
        XCTAssertEqual(marker1.value(forContext: .occlusion), .notOccluded)
        XCTAssertEqual(marker1.value(forContext: .effectiveOcclusion), .notOccluded)
        XCTAssertEqual(marker1.value(forContext: .inheritedRoles), [
            .inherited(.video(raw: "Sample Role")!), // markers can never have 'assigned' roles
            .inherited(.audio(raw: "music.music-1")!) // markers can never have 'assigned' roles
        ])
        
        // sync clip does not have video/audio roles nor does its parents.
        // instead, we derive the video role from the sync clip's contents.
        // the audio role may be present in a `sync-source` child of the sync clip.
        let marker2 = try XCTUnwrap(extractedMarkers[safe: 2])
        XCTAssertEqual(marker2.name, "Marker on Sync Clip")
        XCTAssertEqual(marker2.model.startAsTimecode(), Self.tc("00:00:10:00", .fps25))
        XCTAssertEqual(marker2.timecode(), Self.tc("01:00:10:00", .fps25))
        XCTAssertEqual(marker2.value(forContext: .occlusion), .notOccluded)
        XCTAssertEqual(marker2.value(forContext: .effectiveOcclusion), .notOccluded)
        XCTAssertEqual(marker2.value(forContext: .inheritedRoles), [
            .inherited(.video(raw: "Sample Role")!), // markers can never have 'assigned' roles
            .inherited(.audio(raw: "effects.effects-1")!) // markers can never have 'assigned' roles
        ])
    }
}

#endif
