//
//  FinalCutPro FCPXML SyncClipRoles2.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
/* @testable */ import DAWFileKit
import OTCore
import TimecodeKit

final class FinalCutPro_FCPXML_SyncClipRoles2: FCPXMLTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try XCTUnwrap(loadFileContents(
            forResource: "SyncClipRoles2",
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
        
        XCTAssertEqual(clip1.name, "5A-1-1")
        
        let markers = clip1.contents.annotations().markers()
        XCTAssertEqual(markers.count, 1)
        
        let marker = try XCTUnwrap(markers.first)
        XCTAssertEqual(marker.name, "Marker 1")
        XCTAssertEqual(marker.context[.inheritedRoles], [
            .defaulted(.video(raw: "Video")!) // from first video asset in sync clip
            // no audio role
        ])
    }
}

#endif
