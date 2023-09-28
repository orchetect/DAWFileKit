//
//  DAWMarker Conversions Tests.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import XCTest
@testable import DAWFileKit
import TimecodeKit

class DAWMarkerConversions_Tests: XCTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    // MARK: -
    
    /// Same frame rate
    func testResolvedTimecodeA() {
        let sfBase: Timecode.SubFramesBase = .max80SubFrames
        
        let marker = DAWMarker(
            storage: .init(
                value: .timecodeString("00:00:05:17"),
                frameRate: .fps23_976,
                base: sfBase
            ),
            name: "Marker 1",
            comment: nil
        )
        
        let resolved = marker.resolvedTimecode(
            at: .fps23_976,
            base: sfBase,
            limit: .max24Hours
        )!
        
        XCTAssertEqual(resolved.frameRate, .fps23_976)
        XCTAssertEqual(resolved.upperLimit, .max24Hours)
        XCTAssertEqual(
            resolved.components,
            .init(d: 0, h: 0, m: 0, s: 5, f: 17, sf: 0)
        )
    }
    
    /// Same frame rate
    func testResolvedTimecodeB() {
        let sfBase: Timecode.SubFramesBase = .max80SubFrames
        
        let marker = DAWMarker(
            storage: .init(
                value: .timecodeString("00:00:09:09"),
                frameRate: .fps23_976,
                base: sfBase
            ),
            name: "Marker 1",
            comment: nil
        )
        
        let resolved = marker.resolvedTimecode(
            at: .fps23_976,
            base: sfBase,
            limit: .max24Hours
        )!
        
        XCTAssertEqual(resolved.frameRate, .fps23_976)
        XCTAssertEqual(resolved.upperLimit, .max24Hours)
        XCTAssertEqual(
            resolved.components,
            .init(d: 0, h: 0, m: 0, s: 9, f: 9, sf: 0)
        )
    }
    
    /// Different frame rate
    func testResolvedTimecodeC() {
        let sfBase: Timecode.SubFramesBase = .max80SubFrames
        
        let marker = DAWMarker(
            storage: .init(
                value: .timecodeString("00:00:05:17"),
                frameRate: .fps23_976,
                base: sfBase
            ),
            name: "Marker 1",
            comment: nil
        )
        
        let resolved = marker.resolvedTimecode(
            at: .fps30,
            base: sfBase,
            limit: .max24Hours
        )!
        
        XCTAssertEqual(resolved.frameRate, .fps30)
        XCTAssertEqual(resolved.upperLimit, .max24Hours)
        XCTAssertEqual(
            resolved.components,
            .init(d: 0, h: 0, m: 0, s: 5, f: 21, sf: 33)
        )
    }
}
