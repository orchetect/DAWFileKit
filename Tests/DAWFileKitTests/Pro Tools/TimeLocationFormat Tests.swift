//
//  TimeLocationFormat Tests.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import XCTest
@testable import DAWFileKit
import OTCore
import TimecodeKit

class ProTools_TimeLocationFormatTests: XCTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    typealias Fmt = ProTools.SessionInfo.TimeLocationFormat
    
    func testHeuristic_BaselineChecks() {
        // empty
        XCTAssertNil(Fmt(heuristic: ""))
        XCTAssertNil(Fmt(heuristic: " "))
        
        // garbage data
        XCTAssertNil(Fmt(heuristic: "ABC"))
    }
    
    func testHeuristic_Timecode() {
        // -- subframes not enabled --
        // non-drop
        XCTAssertEqual(Fmt(heuristic: "00:00:00:00"), .timecode)
        XCTAssertEqual(Fmt(heuristic: "01:23:45:10"), .timecode)
        // drop-frame
        XCTAssertEqual(Fmt(heuristic: "00:00:00;00"), .timecode)
        XCTAssertEqual(Fmt(heuristic: "01:23:45;10"), .timecode)
        
        // -- subframes enabled --
        // non-drop
        XCTAssertEqual(Fmt(heuristic: "00:00:00:00.00"), .timecode)
        XCTAssertEqual(Fmt(heuristic: "01:23:45:10.23"), .timecode)
        // drop-frame
        XCTAssertEqual(Fmt(heuristic: "00:00:00;00.00"), .timecode)
        XCTAssertEqual(Fmt(heuristic: "01:23:45;10.23"), .timecode)
        
        // malformed
        XCTAssertNil(Fmt(heuristic: ":::"))
        XCTAssertNil(Fmt(heuristic: ":::."))
        XCTAssertNil(Fmt(heuristic: "0:00:00:00"))
        XCTAssertNil(Fmt(heuristic: "0:00:00:00.00"))
        XCTAssertNil(Fmt(heuristic: "000:00:00:00"))
        XCTAssertNil(Fmt(heuristic: "000:00:00:00.00"))
        XCTAssertNil(Fmt(heuristic: "0:00:00:00:00"))
        XCTAssertNil(Fmt(heuristic: "0:00:00:00:00.00"))
        XCTAssertNil(Fmt(heuristic: "00:00:00:00."))
        XCTAssertNil(Fmt(heuristic: "00:00:00:00.0"))
        XCTAssertNil(Fmt(heuristic: "00:00:00:00.000"))
        XCTAssertNil(Fmt(heuristic: "AB:00:00:00"))
        XCTAssertNil(Fmt(heuristic: "AB:00:00:00.00"))
        XCTAssertNil(Fmt(heuristic: "0.00.00.00"))
        XCTAssertNil(Fmt(heuristic: "00.00.00.00"))
        XCTAssertNil(Fmt(heuristic: "00.00.00.00.00"))
    }
    
    func testHeuristic_MinSecs() {
        // -- subframes not enabled -- (no milliseconds)
        XCTAssertEqual(Fmt(heuristic: "0:00"), .minSecs)
        XCTAssertEqual(Fmt(heuristic: "1:23"), .minSecs)
        XCTAssertEqual(Fmt(heuristic: "123:23"), .minSecs)
        
        // -- subframes enabled -- (includes milliseconds)
        XCTAssertEqual(Fmt(heuristic: "0:00.000"), .minSecs)
        XCTAssertEqual(Fmt(heuristic: "1:23.456"), .minSecs)
        XCTAssertEqual(Fmt(heuristic: "123:23.456"), .minSecs)
        
        // malformed
        XCTAssertNil(Fmt(heuristic: ":"))
        XCTAssertNil(Fmt(heuristic: ":."))
        XCTAssertNil(Fmt(heuristic: "0:0"))
        XCTAssertNil(Fmt(heuristic: "00:0"))
        XCTAssertNil(Fmt(heuristic: "0:000"))
        XCTAssertNil(Fmt(heuristic: "1:123"))
        XCTAssertNil(Fmt(heuristic: "A:00"))
        XCTAssertNil(Fmt(heuristic: "A0:00"))
        XCTAssertNil(Fmt(heuristic: "0:00A"))
        XCTAssertNil(Fmt(heuristic: "0.00"))
        XCTAssertNil(Fmt(heuristic: "0:00.0"))
        XCTAssertNil(Fmt(heuristic: "0:00.00"))
        XCTAssertNil(Fmt(heuristic: "0:00.0000"))
        XCTAssertNil(Fmt(heuristic: "0.00.0"))
        XCTAssertNil(Fmt(heuristic: "0.00.00"))
        XCTAssertNil(Fmt(heuristic: "0.00.0000"))
    }
    
    func testHeuristic_Samples() {
        XCTAssertEqual(Fmt(heuristic: "0"), .samples)
        XCTAssertEqual(Fmt(heuristic: "1"), .samples)
        XCTAssertEqual(Fmt(heuristic: "123"), .samples)
        XCTAssertEqual(Fmt(heuristic: "123456789"), .samples)
        
        // malformed
        XCTAssertNil(Fmt(heuristic: "0.0"))
        XCTAssertNil(Fmt(heuristic: "1.2"))
        XCTAssertNil(Fmt(heuristic: "-1"))
        XCTAssertNil(Fmt(heuristic: "-1.2"))
        XCTAssertNil(Fmt(heuristic: "A0"))
        XCTAssertNil(Fmt(heuristic: "0A"))
    }
    
    func testHeuristic_BarsAndBeats() {
        // -- subframes not enabled -- (no ticks)
        XCTAssertEqual(Fmt(heuristic: "0|0"), .barsAndBeats)
        XCTAssertEqual(Fmt(heuristic: "1|3"), .barsAndBeats)
        XCTAssertEqual(Fmt(heuristic: "105|12"), .barsAndBeats)
        
        // -- subframes enabled -- (includes ticks)
        XCTAssertEqual(Fmt(heuristic: "0|0| 000"), .barsAndBeats)
        XCTAssertEqual(Fmt(heuristic: "1|3| 123"), .barsAndBeats)
        XCTAssertEqual(Fmt(heuristic: "105|12| 123"), .barsAndBeats)
        
        // malformed
        XCTAssertNil(Fmt(heuristic: "|0"))
        XCTAssertNil(Fmt(heuristic: "0|"))
        XCTAssertNil(Fmt(heuristic: "||"))
        XCTAssertNil(Fmt(heuristic: "|| "))
        XCTAssertNil(Fmt(heuristic: "|0|0"))
        XCTAssertNil(Fmt(heuristic: "|0|"))
        XCTAssertNil(Fmt(heuristic: "A0|0"))
        XCTAssertNil(Fmt(heuristic: "0|0A"))
        XCTAssertNil(Fmt(heuristic: "0|0 "))
        XCTAssertNil(Fmt(heuristic: "0|0|0"))
        XCTAssertNil(Fmt(heuristic: "0|0|00"))
        XCTAssertNil(Fmt(heuristic: "0|0|000"))
        XCTAssertNil(Fmt(heuristic: "0|0|00000"))
        XCTAssertNil(Fmt(heuristic: "0|0| 0000"))
    }
    
    func testHeuristic_FeetAndFrames() {
        // -- subframes not enabled --
        XCTAssertEqual(Fmt(heuristic: "0+00"), .feetAndFrames)
        XCTAssertEqual(Fmt(heuristic: "1+00"), .feetAndFrames)
        XCTAssertEqual(Fmt(heuristic: "10+09"), .feetAndFrames)
        
        // -- subframes enabled --
        XCTAssertEqual(Fmt(heuristic: "0+00.00"), .feetAndFrames)
        XCTAssertEqual(Fmt(heuristic: "1+00.23"), .feetAndFrames)
        XCTAssertEqual(Fmt(heuristic: "10+09.23"), .feetAndFrames)
        
        // malformed
        XCTAssertNil(Fmt(heuristic: "+"))
        XCTAssertNil(Fmt(heuristic: "+."))
        XCTAssertNil(Fmt(heuristic: "0+0"))
        XCTAssertNil(Fmt(heuristic: "00+0"))
        XCTAssertNil(Fmt(heuristic: "0+000"))
        XCTAssertNil(Fmt(heuristic: "0+"))
        XCTAssertNil(Fmt(heuristic: "+00"))
        XCTAssertNil(Fmt(heuristic: "A0+00"))
        XCTAssertNil(Fmt(heuristic: "0+00A"))
        XCTAssertNil(Fmt(heuristic: "0+00."))
        XCTAssertNil(Fmt(heuristic: "0+00.0"))
        XCTAssertNil(Fmt(heuristic: "0+00.000"))
    }
}
