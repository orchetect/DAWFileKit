//
//  FinalCutPro FCPXML ClipMetadata.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
@testable import DAWFileKit
import SwiftExtensions
import TimecodeKitCore

final class FinalCutPro_FCPXML_ClipMetadata: FCPXMLTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try XCTUnwrap(loadFileContents(
            forResource: "ClipMetadata",
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
    
    /// Test metadata that applies to marker(s).
    func testExtractMarkersMetadata() async throws {
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
        
        let expectedMarkerCount = 1
        XCTAssertEqual(markers.count, expectedMarkerCount)
        
        print("Markers sorted by absolute timecode:")
        print(Self.debugString(for: markers))
        
        // markers
        
        let marker1 = try XCTUnwrap(markers[safe: 0])
        
        let metadata = marker1.value(forContext: .metadata)
        
        XCTAssertEqual(metadata.count, 11)
        
        func md(key: FinalCutPro.FCPXML.Metadata.Key) -> FinalCutPro.FCPXML.Metadata.Metadatum? {
            let matches = metadata.filter { $0.key == key }
            XCTAssertLessThan(matches.count, 2)
            return matches.first
        }
        
        // metadata from media
        XCTAssertEqual(md(key: .cameraName)?.value, "TestVideo Camera Name")
        XCTAssertEqual(md(key: .rawToLogConversion)?.value, "0")
        XCTAssertEqual(md(key: .colorProfile)?.value, "SD (6-1-6)")
        XCTAssertEqual(md(key: .cameraISO)?.value, "0")
        XCTAssertEqual(md(key: .cameraColorTemperature)?.value, "0")
        XCTAssertEqual(md(key: .codecs)?.valueArray, ["'avc1'", "MPEG-4 AAC"])
        XCTAssertEqual(md(key: .ingestDate)?.value, "2023-01-01 19:46:28 -0800")
        // metadata from clip
        XCTAssertEqual(md(key: .reel)?.value, "TestVideo Reel")
        XCTAssertEqual(md(key: .scene)?.value, "TestVideo Scene")
        XCTAssertEqual(md(key: .take)?.value, "TestVideo Take")
        XCTAssertEqual(md(key: .cameraAngle)?.value, "TestVideo Camera Angle")
    }
}

#endif
