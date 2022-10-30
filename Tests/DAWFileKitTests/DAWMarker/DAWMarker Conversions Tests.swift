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
        let sfBase: Timecode.SubFramesBase = ._80SubFrames
        
        let marker = DAWMarker(
            storage: .init(
                value: .timecodeString("00:00:05:17"),
                frameRate: ._23_976,
                base: sfBase
            ),
            name: "Marker 1",
            comment: nil
        )
        
        let resolved = marker.resolvedTimecode(
            at: ._23_976,
            limit: ._24hours,
            base: sfBase
        )!
        
        XCTAssertEqual(resolved.frameRate, ._23_976)
        XCTAssertEqual(resolved.upperLimit, ._24hours)
        XCTAssertEqual(
            resolved.components,
            TCC(d: 0, h: 0, m: 0, s: 5, f: 17, sf: 0)
        )
    }
    
    /// Same frame rate
    func testResolvedTimecodeB() {
        let sfBase: Timecode.SubFramesBase = ._80SubFrames
        
        let marker = DAWMarker(
            storage: .init(
                value: .timecodeString("00:00:09:09"),
                frameRate: ._23_976,
                base: sfBase
            ),
            name: "Marker 1",
            comment: nil
        )
        
        let resolved = marker.resolvedTimecode(
            at: ._23_976,
            limit: ._24hours,
            base: sfBase
        )!
        
        XCTAssertEqual(resolved.frameRate, ._23_976)
        XCTAssertEqual(resolved.upperLimit, ._24hours)
        XCTAssertEqual(
            resolved.components,
            TCC(d: 0, h: 0, m: 0, s: 9, f: 9, sf: 0)
        )
    }
    
    /// Different frame rate
    func testResolvedTimecodeC() {
        let sfBase: Timecode.SubFramesBase = ._80SubFrames
        
        let marker = DAWMarker(
            storage: .init(
                value: .timecodeString("00:00:05:17"),
                frameRate: ._23_976,
                base: sfBase
            ),
            name: "Marker 1",
            comment: nil
        )
        
        let resolved = marker.resolvedTimecode(
            at: ._30,
            limit: ._24hours,
            base: sfBase
        )!
        
        XCTAssertEqual(resolved.frameRate, ._30)
        XCTAssertEqual(resolved.upperLimit, ._24hours)
        XCTAssertEqual(
            resolved.components,
            TCC(d: 0, h: 0, m: 0, s: 5, f: 21, sf: 33)
        )
    }
}
