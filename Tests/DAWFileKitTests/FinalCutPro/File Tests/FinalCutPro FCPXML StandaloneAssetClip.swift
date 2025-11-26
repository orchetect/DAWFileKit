//
//  FinalCutPro FCPXML StandaloneAssetClip.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
@testable import DAWFileKit
import SwiftExtensions
import TimecodeKit

final class FinalCutPro_FCPXML_StandaloneAssetClip: FCPXMLTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try XCTUnwrap(loadFileContents(
            forResource: "StandaloneAssetClip",
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
    
    /// Test that FCPXML that doesn't contain a project is still able to extract standalone clips.
    func testExtract() async throws {
        // load file
        let rawData = try fileContents
        
        // load
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // timelines
        let timelines = fcpxml.allTimelines()
        XCTAssertEqual(timelines.count, 1)
        
        let anyTimeline = try XCTUnwrap(timelines.first)
        
        // AnyTimeline
        
        let timelineStartTC = try XCTUnwrap(anyTimeline.timelineStartAsTimecode())
        XCTAssertEqual(timelineStartTC.components, .init(h: 00, m: 59, s: 50, f: 00))
        XCTAssertEqual(timelineStartTC.frameRate, .fps29_97)
        let timelineDurTC = try XCTUnwrap(anyTimeline.timelineDurationAsTimecode())
        XCTAssertEqual(timelineDurTC.components, .init(h: 00, m: 00, s: 10, f: 00))
        XCTAssertEqual(timelineDurTC.frameRate, .fps29_97)
        
        // unwrap AssetClip
        
        guard case .assetClip(let assetClip) = anyTimeline else { XCTFail() ; return }
        
        // FCPXMLElementMetaTimeline
        let assetClipStartTC = try XCTUnwrap(anyTimeline.timelineStartAsTimecode())
        XCTAssertEqual(assetClipStartTC.components, .init(h: 00, m: 59, s: 50, f: 00))
        XCTAssertEqual(assetClipStartTC.frameRate, .fps29_97)
        let assetClipDurTC = try XCTUnwrap(anyTimeline.timelineDurationAsTimecode())
        XCTAssertEqual(assetClipDurTC.components, .init(h: 00, m: 00, s: 10, f: 00))
        XCTAssertEqual(assetClipDurTC.frameRate, .fps29_97)
        
        // local XML attributes
        let clipStartTC = try XCTUnwrap(assetClip.startAsTimecode())
        XCTAssertEqual(clipStartTC.components, .init(h: 00, m: 59, s: 50, f: 00))
        XCTAssertEqual(clipStartTC.frameRate, .fps29_97)
        let clipDurTC = try XCTUnwrap(assetClip.durationAsTimecode())
        XCTAssertEqual(clipDurTC.components, .init(h: 00, m: 00, s: 10, f: 00))
        XCTAssertEqual(clipDurTC.frameRate, .fps29_97)
    }
}

#endif
