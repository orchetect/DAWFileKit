//
//  TimeValueFormat Tests.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import XCTest
@testable import DAWFileTools
import SwiftExtensions
import TimecodeKitCore

class ProTools_TimeValueFormatTests: XCTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    typealias Fmt = ProTools.SessionInfo.TimeValueFormat
    
    func testHeuristic_BaselineChecks() throws {
        // empty
        XCTAssertThrowsError(try Fmt(heuristic: ""))
        XCTAssertThrowsError(try Fmt(heuristic: " "))
        
        // garbage data
        XCTAssertThrowsError(try Fmt(heuristic: "ABC"))
    }
    
    func testHeuristic_Timecode() throws {
        // -- subframes not enabled --
        // non-drop
        XCTAssertEqual(try Fmt(heuristic: "00:00:00:00"), .timecode)
        XCTAssertEqual(try Fmt(heuristic: "01:23:45:10"), .timecode)
        // drop-frame
        XCTAssertEqual(try Fmt(heuristic: "00:00:00;00"), .timecode)
        XCTAssertEqual(try Fmt(heuristic: "01:23:45;10"), .timecode)
        
        // -- subframes enabled --
        // non-drop
        XCTAssertEqual(try Fmt(heuristic: "00:00:00:00.00"), .timecode)
        XCTAssertEqual(try Fmt(heuristic: "01:23:45:10.23"), .timecode)
        // drop-frame
        XCTAssertEqual(try Fmt(heuristic: "00:00:00;00.00"), .timecode)
        XCTAssertEqual(try Fmt(heuristic: "01:23:45;10.23"), .timecode)
        
        // malformed
        XCTAssertThrowsError(try Fmt(heuristic: ":::"))
        XCTAssertThrowsError(try Fmt(heuristic: ":::."))
        XCTAssertThrowsError(try Fmt(heuristic: "0:00:00:00"))
        XCTAssertThrowsError(try Fmt(heuristic: "0:00:00:00.00"))
        XCTAssertThrowsError(try Fmt(heuristic: "000:00:00:00"))
        XCTAssertThrowsError(try Fmt(heuristic: "000:00:00:00.00"))
        XCTAssertThrowsError(try Fmt(heuristic: "0:00:00:00:00"))
        XCTAssertThrowsError(try Fmt(heuristic: "0:00:00:00:00.00"))
        XCTAssertThrowsError(try Fmt(heuristic: "00:00:00:00."))
        XCTAssertThrowsError(try Fmt(heuristic: "00:00:00:00.0"))
        XCTAssertThrowsError(try Fmt(heuristic: "00:00:00:00.000"))
        XCTAssertThrowsError(try Fmt(heuristic: "AB:00:00:00"))
        XCTAssertThrowsError(try Fmt(heuristic: "AB:00:00:00.00"))
        XCTAssertThrowsError(try Fmt(heuristic: "0.00.00.00"))
        XCTAssertThrowsError(try Fmt(heuristic: "00.00.00.00"))
        XCTAssertThrowsError(try Fmt(heuristic: "00.00.00.00.00"))
    }
    
    func testHeuristic_MinSecs() throws {
        // -- subframes not enabled -- (no milliseconds)
        XCTAssertEqual(try Fmt(heuristic: "0:00"), .minSecs)
        XCTAssertEqual(try Fmt(heuristic: "1:23"), .minSecs)
        XCTAssertEqual(try Fmt(heuristic: "123:23"), .minSecs)
        
        // -- subframes enabled -- (includes milliseconds)
        XCTAssertEqual(try Fmt(heuristic: "0:00.000"), .minSecs)
        XCTAssertEqual(try Fmt(heuristic: "1:23.456"), .minSecs)
        XCTAssertEqual(try Fmt(heuristic: "123:23.456"), .minSecs)
        
        // malformed
        XCTAssertThrowsError(try Fmt(heuristic: ":"))
        XCTAssertThrowsError(try Fmt(heuristic: ":."))
        XCTAssertThrowsError(try Fmt(heuristic: "0:0"))
        XCTAssertThrowsError(try Fmt(heuristic: "00:0"))
        XCTAssertThrowsError(try Fmt(heuristic: "0:000"))
        XCTAssertThrowsError(try Fmt(heuristic: "1:123"))
        XCTAssertThrowsError(try Fmt(heuristic: "A:00"))
        XCTAssertThrowsError(try Fmt(heuristic: "A0:00"))
        XCTAssertThrowsError(try Fmt(heuristic: "0:00A"))
        XCTAssertThrowsError(try Fmt(heuristic: "0.00"))
        XCTAssertThrowsError(try Fmt(heuristic: "0:00.0"))
        XCTAssertThrowsError(try Fmt(heuristic: "0:00.00"))
        XCTAssertThrowsError(try Fmt(heuristic: "0:00.0000"))
        XCTAssertThrowsError(try Fmt(heuristic: "0.00.0"))
        XCTAssertThrowsError(try Fmt(heuristic: "0.00.00"))
        XCTAssertThrowsError(try Fmt(heuristic: "0.00.0000"))
    }
    
    func testHeuristic_Samples() throws {
        XCTAssertEqual(try Fmt(heuristic: "0"), .samples)
        XCTAssertEqual(try Fmt(heuristic: "1"), .samples)
        XCTAssertEqual(try Fmt(heuristic: "123"), .samples)
        XCTAssertEqual(try Fmt(heuristic: "123456789"), .samples)
        
        // malformed
        XCTAssertThrowsError(try Fmt(heuristic: "0.0"))
        XCTAssertThrowsError(try Fmt(heuristic: "1.2"))
        XCTAssertThrowsError(try Fmt(heuristic: "-1"))
        XCTAssertThrowsError(try Fmt(heuristic: "-1.2"))
        XCTAssertThrowsError(try Fmt(heuristic: "A0"))
        XCTAssertThrowsError(try Fmt(heuristic: "0A"))
    }
    
    func testHeuristic_BarsAndBeats() throws {
        // -- subframes not enabled -- (no ticks)
        XCTAssertEqual(try Fmt(heuristic: "0|0"), .barsAndBeats)
        XCTAssertEqual(try Fmt(heuristic: "1|3"), .barsAndBeats)
        XCTAssertEqual(try Fmt(heuristic: "105|12"), .barsAndBeats)
        
        // -- subframes enabled -- (includes ticks)
        XCTAssertEqual(try Fmt(heuristic: "0|0| 000"), .barsAndBeats)
        XCTAssertEqual(try Fmt(heuristic: "1|3| 123"), .barsAndBeats)
        XCTAssertEqual(try Fmt(heuristic: "105|12| 123"), .barsAndBeats)
        
        // malformed
        XCTAssertThrowsError(try Fmt(heuristic: "|0"))
        XCTAssertThrowsError(try Fmt(heuristic: "0|"))
        XCTAssertThrowsError(try Fmt(heuristic: "||"))
        XCTAssertThrowsError(try Fmt(heuristic: "|| "))
        XCTAssertThrowsError(try Fmt(heuristic: "|0|0"))
        XCTAssertThrowsError(try Fmt(heuristic: "|0|"))
        XCTAssertThrowsError(try Fmt(heuristic: "A0|0"))
        XCTAssertThrowsError(try Fmt(heuristic: "0|0A"))
        XCTAssertThrowsError(try Fmt(heuristic: "0|0 "))
        XCTAssertThrowsError(try Fmt(heuristic: "0|0|0"))
        XCTAssertThrowsError(try Fmt(heuristic: "0|0|00"))
        XCTAssertThrowsError(try Fmt(heuristic: "0|0|000"))
        XCTAssertThrowsError(try Fmt(heuristic: "0|0|00000"))
        XCTAssertThrowsError(try Fmt(heuristic: "0|0| 0000"))
    }
    
    func testHeuristic_FeetAndFrames() throws {
        // -- subframes not enabled --
        XCTAssertEqual(try Fmt(heuristic: "0+00"), .feetAndFrames)
        XCTAssertEqual(try Fmt(heuristic: "1+00"), .feetAndFrames)
        XCTAssertEqual(try Fmt(heuristic: "10+09"), .feetAndFrames)
        
        // -- subframes enabled --
        XCTAssertEqual(try Fmt(heuristic: "0+00.00"), .feetAndFrames)
        XCTAssertEqual(try Fmt(heuristic: "1+00.23"), .feetAndFrames)
        XCTAssertEqual(try Fmt(heuristic: "10+09.23"), .feetAndFrames)
        
        // malformed
        XCTAssertThrowsError(try Fmt(heuristic: "+"))
        XCTAssertThrowsError(try Fmt(heuristic: "+."))
        XCTAssertThrowsError(try Fmt(heuristic: "0+0"))
        XCTAssertThrowsError(try Fmt(heuristic: "00+0"))
        XCTAssertThrowsError(try Fmt(heuristic: "0+000"))
        XCTAssertThrowsError(try Fmt(heuristic: "0+"))
        XCTAssertThrowsError(try Fmt(heuristic: "+00"))
        XCTAssertThrowsError(try Fmt(heuristic: "A0+00"))
        XCTAssertThrowsError(try Fmt(heuristic: "0+00A"))
        XCTAssertThrowsError(try Fmt(heuristic: "0+00."))
        XCTAssertThrowsError(try Fmt(heuristic: "0+00.0"))
        XCTAssertThrowsError(try Fmt(heuristic: "0+00.000"))
    }
}
