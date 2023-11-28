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
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // events
        let events = fcpxml.allEvents()
        XCTAssertEqual(events.count, 1)
        
        let event = try XCTUnwrap(events[safe: 0])
        XCTAssertEqual(event.name, "TestEvent")
                
        // projects
        let projects = event.projects
        XCTAssertEqual(projects.count, 1)
        
        let project = try XCTUnwrap(projects.first)
        
        // sequence
        let sequence = project.sequence
        
        // spine
        let spine = sequence.spine
        XCTAssertEqual(spine.contents.count, 1)
        
        // story elements
        guard case let .anyClip(.syncClip(assetClip)) = spine.contents[0]
        else { XCTFail("Clip was not expected type.") ; return }
        
        XCTAssertEqual(assetClip.format, "r2")
        XCTAssertEqual(assetClip.offset, Self.tc("01:00:00:00", .fps25))
        XCTAssertEqual(assetClip.offset?.frameRate, .fps25)
        XCTAssertEqual(assetClip.name, "TestVideo - Synchronized Clip")
        XCTAssertEqual(assetClip.start, nil)
        XCTAssertEqual(assetClip.duration, Self.tc("00:00:29:13", .fps25))
        XCTAssertEqual(assetClip.duration?.frameRate, .fps25)
    }
    
    /// Test main timeline markers extraction.
    func testExtractMarkers_MainTimeline() throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try XCTUnwrap(fcpxml.allEvents().first)
        
        // extract markers
        let extractedMarkers = event.extractElements(preset: .markers, settings: .mainTimeline)
        XCTAssertEqual(extractedMarkers.count, 1)
        
        let marker = try XCTUnwrap(extractedMarkers[safe: 0])
        XCTAssertEqual(marker.name, "Marker on Sync Clip")
        XCTAssertEqual(marker.start, Self.tc("00:00:10:00", .fps25))
        XCTAssertEqual(marker.context[.absoluteStart], Self.tc("01:00:10:00", .fps25))
        XCTAssertEqual(marker.context[.inheritedRoles], [
            .inherited(.audio(raw: "music.music-1")!), // markers can never have 'assigned' roles
            .inherited(.video(raw: "Sample Role")!) // markers can never have 'assigned' roles
        ])
    }
    
    /// Test deep markers extraction.
    func testExtractMarkers_Deep() throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try XCTUnwrap(fcpxml.allEvents().first)
        
        // extract markers
        let extractedMarkers = event.extractElements(preset: .markers, settings: .deep())
        XCTAssertEqual(extractedMarkers.count, 3)
        
        // In FCP, a Sync Clip does not bear roles itself.
        // Instead, it inherits the video and audio role of the asset clip(s) within it.
        
        let marker0 = try XCTUnwrap(extractedMarkers[safe: 0])
        XCTAssertEqual(marker0.name, "Marker on Audio")
        XCTAssertEqual(marker0.start, Self.tc("00:00:03:00", .fps25))
        XCTAssertEqual(marker0.context[.absoluteStart], Self.tc("01:00:03:00", .fps25))
        XCTAssertEqual(marker0.context[.inheritedRoles], [
            .inherited(.audio(raw: "effects.effects-1")!), // markers can never have 'assigned' roles
            .inherited(.video(raw: "Sample Role")!) // markers can never have 'assigned' roles
        ])
        
        let marker1 = try XCTUnwrap(extractedMarkers[safe: 1])
        XCTAssertEqual(marker1.name, "Marker on TestVideo")
        XCTAssertEqual(marker1.start, Self.tc("00:00:27:10", .fps25))
        XCTAssertEqual(marker1.context[.absoluteStart], Self.tc("01:00:27:10", .fps25))
        XCTAssertEqual(marker1.context[.inheritedRoles], [
            .inherited(.audio(raw: "music.music-1")!), // markers can never have 'assigned' roles
            .inherited(.video(raw: "Sample Role")!) // markers can never have 'assigned' roles
        ])
        
        // sync clip does not have video/audio roles nor does its parents.
        // instead, we derive the video role from the sync clip's contents.
        // the audio role may be present in a `sync-source` child of the sync clip.
        let marker2 = try XCTUnwrap(extractedMarkers[safe: 2])
        XCTAssertEqual(marker2.name, "Marker on Sync Clip")
        XCTAssertEqual(marker2.start, Self.tc("00:00:10:00", .fps25))
        XCTAssertEqual(marker2.context[.absoluteStart], Self.tc("01:00:10:00", .fps25))
        XCTAssertEqual(marker2.context[.inheritedRoles], [
            .inherited(.audio(raw: "music.music-1")!), // markers can never have 'assigned' roles
            .inherited(.video(raw: "Sample Role")!) // markers can never have 'assigned' roles
        ])
    }
}

#endif
