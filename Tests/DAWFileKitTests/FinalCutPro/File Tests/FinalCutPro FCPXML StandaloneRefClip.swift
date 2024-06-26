//
//  FinalCutPro FCPXML StandaloneRefClip.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
@testable import DAWFileKit
import OTCore
import TimecodeKit

final class FinalCutPro_FCPXML_StandaloneRefClip: FCPXMLTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try XCTUnwrap(loadFileContents(
            forResource: "StandaloneRefClip",
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
        XCTAssertEqual(timelineStartTC.components, .init(h: 00, m: 00, s: 00, f: 00))
        XCTAssertEqual(timelineStartTC.frameRate, .fps29_97)
        let timelineDurTC = try XCTUnwrap(anyTimeline.timelineDurationAsTimecode())
        XCTAssertEqual(timelineDurTC.components, .init(h: 00, m: 00, s: 09, f: 00))
        XCTAssertEqual(timelineDurTC.frameRate, .fps29_97)
        
        // unwrap RefClip
        
        guard case .refClip(let refClip) = anyTimeline else { XCTFail() ; return }
        
        // FCPXMLElementMetaTimeline
        let refClipStartTC = try XCTUnwrap(refClip.timelineStartAsTimecode())
        XCTAssertEqual(refClipStartTC.components, .init(h: 00, m: 00, s: 00, f: 00))
        XCTAssertEqual(refClipStartTC.frameRate, .fps29_97)
        let refClipDurTC = try XCTUnwrap(refClip.timelineDurationAsTimecode())
        XCTAssertEqual(refClipDurTC.components, .init(h: 00, m: 00, s: 09, f: 00))
        XCTAssertEqual(refClipDurTC.frameRate, .fps29_97)
        
        // local XML attributes
        // `ref-clip` itself doesn't have a start time, but its resource does
        XCTAssertNil(refClip.startAsTimecode())
        // `ref-clip` itself doesn't have a duration time, but its resource does
        XCTAssertNil(refClip.durationAsTimecode())
        
        // test markers
        
        let markers = await refClip.extract(preset: .markers, scope: .mainTimeline)
        XCTAssertEqual(markers.count, 1)
    }
}

#endif
