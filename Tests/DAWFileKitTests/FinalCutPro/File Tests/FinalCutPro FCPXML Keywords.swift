//
//  FinalCutPro FCPXML Keywords.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
@testable import DAWFileKit
import SwiftExtensions
import TimecodeKit

final class FinalCutPro_FCPXML_Keywords: FCPXMLTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try XCTUnwrap(loadFileContents(
            forResource: "Keywords",
            withExtension: "fcpxml",
            subFolder: .fcpxmlExports
        ))
    } }
    
    // MARK: - Tests
    
    func testParse() throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // version
        XCTAssertEqual(fcpxml.version, .ver1_11)
    }
    
    /// Test keywords that apply to each marker.
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
        
        let expectedMarkerCount = 6
        XCTAssertEqual(markers.count, expectedMarkerCount)
        
        print("Markers sorted by absolute timecode:")
        print(Self.debugString(for: markers))
        
        // markers
        
        let marker1 = try XCTUnwrap(markers[safe: 0])
        let marker2 = try XCTUnwrap(markers[safe: 1])
        let marker3 = try XCTUnwrap(markers[safe: 2])
        let marker4 = try XCTUnwrap(markers[safe: 3])
        let marker5 = try XCTUnwrap(markers[safe: 4])
        let marker6 = try XCTUnwrap(markers[safe: 5])
        
        // Check keywords while constraining to keyword ranges
        XCTAssertEqual(marker1.keywords(constrainToKeywordRanges: true), ["flower", "nature"])
        XCTAssertEqual(marker2.keywords(constrainToKeywordRanges: true), ["birds"])
        XCTAssertEqual(marker3.keywords(constrainToKeywordRanges: true), ["flower", "nature"])
        XCTAssertEqual(marker4.keywords(constrainToKeywordRanges: true), ["lava", "nature"])
        XCTAssertEqual(marker5.keywords(constrainToKeywordRanges: true), ["penguin"])
        XCTAssertEqual(marker6.keywords(constrainToKeywordRanges: true), ["noStartOrDuration", "penguin"])
    }
}

#endif
