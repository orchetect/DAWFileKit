//
//  FinalCutPro FCPXML SyncClipRoles.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
/* @testable */ import DAWFileKit
import OTCore
import TimecodeKit

final class FinalCutPro_FCPXML_SyncClipRoles: FCPXMLTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try XCTUnwrap(loadFileContents(
            forResource: "SyncClipRoles",
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
        guard case let .anyClip(.syncClip(clip1)) = spine.contents[0]
        else { XCTFail("Clip was not expected type.") ; return }
        
        XCTAssertEqual(clip1.format, nil)
        XCTAssertEqual(clip1.offset, Self.tc("01:01:04:23", .fps25))
        XCTAssertEqual(clip1.offset?.frameRate, .fps25)
        XCTAssertEqual(clip1.name, "Sync Clip 1")
        XCTAssertEqual(clip1.start, Self.tc("10:43:05:16", .fps25))
        XCTAssertEqual(clip1.duration, Self.tc("00:00:01:24", .fps25))
        XCTAssertEqual(clip1.duration?.frameRate, .fps25)
        
        let markers = clip1.contents.annotations().markers()
        XCTAssertEqual(markers.count, 1)
        
        let marker = try XCTUnwrap(markers.first)
        XCTAssertEqual(marker.name, "Marker 1")
        XCTAssertEqual(marker.start, Self.tc("10:43:05:16", .fps25))
        XCTAssertEqual(marker.context[.absoluteStart], Self.tc("01:01:04:23", .fps25))
        XCTAssertEqual(marker.context[.inheritedRoles], [
            .inherited(.video(raw: "VFX.VFX-Background")!), // from first video asset in sync clip
            .inherited(.audio(raw: "dialogue.MixL")!) // from asset clip sync-source
        ])
    }
}

#endif
