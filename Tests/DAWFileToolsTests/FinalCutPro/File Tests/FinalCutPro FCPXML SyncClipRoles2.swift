//
//  FinalCutPro FCPXML SyncClipRoles2.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
/* @testable */ import DAWFileTools
import SwiftExtensions
import TimecodeKitCore

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
    func testParse() async throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // events
        let events = fcpxml.allEvents()
        XCTAssertEqual(events.count, 1)
        
        let event = try XCTUnwrap(events[safe: 0])
        
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
        let clip1 = try XCTUnwrap(storyElements[safe: 0]?.fcpAsSyncClip)
        // confirm we have the right clip
        XCTAssertEqual(clip1.name, "5A-1-1")
        
        let markers = clip1.storyElements
            .filter(whereFCPElement: .marker)
            .zeroIndexed
        XCTAssertEqual(markers.count, 1)
        
        let marker = try XCTUnwrap(markers.first)
        // confirm we have the right marker
        XCTAssertEqual(marker.name, "Marker 1")
        let extractedMarker = await marker.element.fcpExtract()
        XCTAssertEqual(
            extractedMarker.value(forContext: .absoluteStartAsTimecode()),
            Self.tc("01:01:18:03", .fps25)
        )
        XCTAssertEqual(extractedMarker.value(forContext: .inheritedRoles), [
            .defaulted(.video(raw: "Video")!) // from first video asset in sync clip
            // no audio role
        ])
    }
}

#endif
