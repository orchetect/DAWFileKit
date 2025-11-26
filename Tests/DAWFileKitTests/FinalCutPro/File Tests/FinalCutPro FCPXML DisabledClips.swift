//
//  FinalCutPro FCPXML DisabledClips.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
@testable import DAWFileKit
import SwiftExtensions
import TimecodeKitCore

final class FinalCutPro_FCPXML_DisabledClips: FCPXMLTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try XCTUnwrap(loadFileContents(
            forResource: "DisabledClips",
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
        
        // skip testing file contents, we only care about roles assigned to markers for these tests
    }
    
    func testExtractMarkers_IncludeDisabledClips() async throws {
        // load file
        let rawData = try fileContents
        
        // load
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // project
        let project = try XCTUnwrap(fcpxml.allProjects().first)
        
        var scope: FinalCutPro.FCPXML.ExtractionScope = .mainTimeline
        scope.includeDisabled = true
        
        let extractedMarkers = await project
            .extract(preset: .markers, scope: scope)
            .sortedByAbsoluteStartTimecode()
            // .zeroIndexed // not necessary after sorting - sort returns new array
        
        let markers = extractedMarkers
        
        let expectedMarkerCount = 4
        XCTAssertEqual(markers.count, expectedMarkerCount)
        
        print("Markers sorted by absolute timecode:")
        print(Self.debugString(for: markers))
        
        // Titles clips should never have an audio role
        
        let marker1 = try XCTUnwrap(markers[safe: 0])
        XCTAssertEqual(marker1.name, "Marker 1")
        
        let marker2 = try XCTUnwrap(markers[safe: 1])
        XCTAssertEqual(marker2.name, "Marker 2")
        
        let marker3 = try XCTUnwrap(markers[safe: 2])
        XCTAssertEqual(marker3.name, "Marker 3")
        
        let marker4 = try XCTUnwrap(markers[safe: 3])
        XCTAssertEqual(marker4.name, "Marker 4")
    }
    
    func testExtractMarkers_ExcludeDisabledClips() async throws {
        // load file
        let rawData = try fileContents
        
        // load
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // project
        let project = try XCTUnwrap(fcpxml.allProjects().first)
        
        var scope: FinalCutPro.FCPXML.ExtractionScope = .mainTimeline
        scope.includeDisabled = false
        
        let extractedMarkers = await project
            .extract(preset: .markers, scope: scope)
            .sortedByAbsoluteStartTimecode()
        // .zeroIndexed // not necessary after sorting - sort returns new array
        
        let markers = extractedMarkers
        
        let expectedMarkerCount = 2
        XCTAssertEqual(markers.count, expectedMarkerCount)
        
        print("Markers sorted by absolute timecode:")
        print(Self.debugString(for: markers))
        
        // Titles clips should never have an audio role
        
        let marker1 = try XCTUnwrap(markers[safe: 0])
        XCTAssertEqual(marker1.name, "Marker 1")
        
        let marker3 = try XCTUnwrap(markers[safe: 1])
        XCTAssertEqual(marker3.name, "Marker 3")
    }
}

#endif
