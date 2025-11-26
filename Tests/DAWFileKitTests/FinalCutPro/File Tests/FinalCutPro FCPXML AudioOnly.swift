//
//  FinalCutPro FCPXML AudioOnly.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
@testable import DAWFileKit
import SwiftExtensions
import TimecodeKitCore

final class FinalCutPro_FCPXML_AudioOnly: FCPXMLTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try XCTUnwrap(loadFileContents(
            forResource: "AudioOnly",
            withExtension: "fcpxml",
            subFolder: .fcpxmlExports
        ))
    } }
    
    /// Project @ 24fps.
    let projectFrameRate: TimecodeFrameRate = .fps24
    
    func testParse() throws {
        // load
        let rawData = try fileContents
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // version
        XCTAssertEqual(fcpxml.version, .ver1_11)
        
        // skip testing file contents
    }
    
    func testExtractMarkers() async throws {
        // load file
        let rawData = try fileContents
        
        // load
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // project
        let project = try XCTUnwrap(fcpxml.allProjects().first)
        
        let extractedMarkers = await project
            .extract(preset: .markers, scope: .mainTimeline)
            .sortedByAbsoluteStartTimecode()
            // .zeroIndexed // not necessary after sorting - sort returns new array
        
        let markers = extractedMarkers
        
        let expectedMarkerCount = 10
        XCTAssertEqual(markers.count, expectedMarkerCount)
        
        // print("Markers sorted by absolute timecode:")
        // print(Self.debugString(for: markers))
    }
    
    func testExtractRoles() async throws {
        // load file
        let rawData = try fileContents
        
        // load
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // project
        let project = try XCTUnwrap(fcpxml.allProjects().first)
        
        let roles = await project.extract(
            preset: .roles(roleTypes: .allCases),
            scope: .deep(auditions: .active, mcClipAngles: .active)
        )
        
        dump(roles)
        
        XCTAssertEqual(roles.count, 2)
        XCTAssertTrue(roles.contains(.audio(raw: "music.music-1")!))
        XCTAssertTrue(roles.contains(.audio(raw: "effects")!))
    }
}

#endif
