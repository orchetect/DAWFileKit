//
//  TimeLocation Tests.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import XCTest
@testable import DAWFileKit
import OTCore
import TimecodeKit

class ProTools_TimeLocationTests: XCTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    typealias PTSI = ProTools.SessionInfo
    
    func testFormTimeLocation_Timecode() throws {
        // empty
        XCTAssertThrowsError(try PTSI.formTimeLocation(timecodeString: "", at: ._30))
        XCTAssertThrowsError(try PTSI.formTimeLocation(timecodeString: " ", at: ._30))
        
        // -- subframes not enabled --
        // non-drop
        XCTAssertEqual(
            try PTSI.formTimeLocation(timecodeString: "00:00:00:00", at: ._30),
            .timecode(try! "00:00:00:00".toTimecode(at: ._30))
        )
        XCTAssertEqual(
            try PTSI.formTimeLocation(timecodeString: "01:23:45:10", at: ._30),
            .timecode(try! "01:23:45:10".toTimecode(at: ._30))
        )
        // drop-frame
        XCTAssertEqual(
            try PTSI.formTimeLocation(timecodeString: "00:00:00;00", at: ._29_97_drop),
            .timecode(try! "00:00:00;00".toTimecode(at: ._29_97_drop))
        )
        XCTAssertEqual(
            try PTSI.formTimeLocation(timecodeString: "01:23:45;10", at: ._29_97_drop),
            .timecode(try! "01:23:45;10".toTimecode(at: ._29_97_drop))
        )
        
        // -- subframes enabled --
        // non-drop
        XCTAssertEqual(
            try PTSI.formTimeLocation(timecodeString: "00:00:00:00.00", at: ._30),
            .timecode(try! "00:00:00:00.00".toTimecode(at: ._30))
        )
        XCTAssertEqual(
            try PTSI.formTimeLocation(timecodeString: "01:23:45:10.23", at: ._30),
            .timecode(try! "01:23:45:10.23".toTimecode(at: ._30))
        )
        // drop-frame
        XCTAssertEqual(
            try PTSI.formTimeLocation(timecodeString: "00:00:00;00.00", at: ._29_97_drop),
            .timecode(try! "00:00:00;00.00".toTimecode(at: ._29_97_drop))
        )
        XCTAssertEqual(
            try PTSI.formTimeLocation(timecodeString: "01:23:45;10.23", at: ._29_97_drop),
            .timecode(try! "01:23:45;10.23".toTimecode(at: ._29_97_drop))
        )
        
        // malformed
        // * - the non-throwing lines below are valid in TimecodeKit but are not valid
        //     in a Pro Tools session info text file, however this is not an error condition
        XCTAssertThrowsError(try PTSI.formTimeLocation(timecodeString: ":::", at: ._30))
        XCTAssertThrowsError(try PTSI.formTimeLocation(timecodeString: ":::.", at: ._30))
        XCTAssertNoThrow(try PTSI.formTimeLocation(timecodeString: "0:00:00:00", at: ._30)) // *
        XCTAssertNoThrow(try PTSI.formTimeLocation(timecodeString: "0:00:00:00.00", at: ._30)) // *
        XCTAssertNoThrow(try PTSI.formTimeLocation(timecodeString: "000:00:00:00", at: ._30)) // *
        XCTAssertNoThrow(try PTSI.formTimeLocation(timecodeString: "000:00:00:00.00", at: ._30)) // *
        XCTAssertNoThrow(try PTSI.formTimeLocation(timecodeString: "0:00:00:00:00", at: ._30)) // *
        XCTAssertNoThrow(try PTSI.formTimeLocation(timecodeString: "0:00:00:00:00.00", at: ._30)) // *
        XCTAssertNoThrow(try PTSI.formTimeLocation(timecodeString: "00:00:00:00.", at: ._30)) // *
        XCTAssertNoThrow(try PTSI.formTimeLocation(timecodeString: "00:00:00:00.0", at: ._30)) // *
        XCTAssertNoThrow(try PTSI.formTimeLocation(timecodeString: "00:00:00:00.000", at: ._30)) // *
        XCTAssertThrowsError(try PTSI.formTimeLocation(timecodeString: "AB:00:00:00", at: ._30))
        XCTAssertThrowsError(try PTSI.formTimeLocation(timecodeString: "AB:00:00:00.00", at: ._30))
        XCTAssertThrowsError(try PTSI.formTimeLocation(timecodeString: "0.00.00.00", at: ._30))
        XCTAssertThrowsError(try PTSI.formTimeLocation(timecodeString: "00.00.00.00", at: ._30))
        XCTAssertThrowsError(try PTSI.formTimeLocation(timecodeString: "00.00.00.00.00", at: ._30))
    }
    
    func testFormTimeLocation_MinSecs() throws {
        // empty
        XCTAssertThrowsError(try PTSI.formTimeLocation(minSecsString: ""))
        XCTAssertThrowsError(try PTSI.formTimeLocation(minSecsString: " "))
        
        // -- subframes not enabled -- (no milliseconds)
        XCTAssertEqual(try PTSI.formTimeLocation(minSecsString: "0:00"),
                       .minSecs(min: 0, sec: 0, ms: nil)
        )
        XCTAssertEqual(try PTSI.formTimeLocation(minSecsString: "1:23"),
                       .minSecs(min: 1, sec: 23, ms: nil)
        )
        XCTAssertEqual(try PTSI.formTimeLocation(minSecsString: "123:23"),
                       .minSecs(min: 123, sec: 23, ms: nil)
        )
        
        // -- subframes enabled -- (includes milliseconds)
        XCTAssertEqual(try PTSI.formTimeLocation(minSecsString: "0:00.000"),
                       .minSecs(min: 0, sec: 0, ms: 0)
        )
        XCTAssertEqual(try PTSI.formTimeLocation(minSecsString: "1:23.456"),
                       .minSecs(min: 1, sec: 23, ms: 456)
        )
        XCTAssertEqual(try PTSI.formTimeLocation(minSecsString: "123:23.456"),
                       .minSecs(min: 123, sec: 23, ms: 456)
        )
        
        // malformed
        XCTAssertThrowsError(try PTSI.formTimeLocation(minSecsString: ":"))
        XCTAssertThrowsError(try PTSI.formTimeLocation(minSecsString: ":."))
        XCTAssertThrowsError(try PTSI.formTimeLocation(minSecsString: "0:0"))
        XCTAssertThrowsError(try PTSI.formTimeLocation(minSecsString: "00:0"))
        XCTAssertThrowsError(try PTSI.formTimeLocation(minSecsString: "0:000"))
        XCTAssertThrowsError(try PTSI.formTimeLocation(minSecsString: "1:123"))
        XCTAssertThrowsError(try PTSI.formTimeLocation(minSecsString: "A:00"))
        XCTAssertThrowsError(try PTSI.formTimeLocation(minSecsString: "A0:00"))
        XCTAssertThrowsError(try PTSI.formTimeLocation(minSecsString: "0:00A"))
        XCTAssertThrowsError(try PTSI.formTimeLocation(minSecsString: "0.00"))
        XCTAssertThrowsError(try PTSI.formTimeLocation(minSecsString: "0:00.0"))
        XCTAssertThrowsError(try PTSI.formTimeLocation(minSecsString: "0:00.00"))
        XCTAssertThrowsError(try PTSI.formTimeLocation(minSecsString: "0:00.0000"))
        XCTAssertThrowsError(try PTSI.formTimeLocation(minSecsString: "0.00.0"))
        XCTAssertThrowsError(try PTSI.formTimeLocation(minSecsString: "0.00.00"))
        XCTAssertThrowsError(try PTSI.formTimeLocation(minSecsString: "0.00.0000"))
    }
    
    func testFormTimeLocation_Samples() throws {
        // empty
        XCTAssertThrowsError(try PTSI.formTimeLocation(samplesString: ""))
        XCTAssertThrowsError(try PTSI.formTimeLocation(samplesString: " "))
        
        XCTAssertEqual(try PTSI.formTimeLocation(samplesString: "0"),
                       .samples(0)
        )
        XCTAssertEqual(try PTSI.formTimeLocation(samplesString: "1"),
                       .samples(1)
        )
        XCTAssertEqual(try PTSI.formTimeLocation(samplesString: "123"),
                       .samples(123)
        )
        XCTAssertEqual(try PTSI.formTimeLocation(samplesString: "123456789"),
                       .samples(123456789)
        )
        
        // malformed
        // * - the non-throwing lines below are possible because
        XCTAssertThrowsError(try PTSI.formTimeLocation(samplesString: "0.0"))
        XCTAssertThrowsError(try PTSI.formTimeLocation(samplesString: "1.2"))
        XCTAssertThrowsError(try PTSI.formTimeLocation(samplesString: "-1"))
        XCTAssertThrowsError(try PTSI.formTimeLocation(samplesString: "-1.2"))
        XCTAssertThrowsError(try PTSI.formTimeLocation(samplesString: "A0"))
        XCTAssertThrowsError(try PTSI.formTimeLocation(samplesString: "0A"))
    }
    
    func testFormTimeLocation_BarsAndBeats() throws {
        // empty
        XCTAssertThrowsError(try PTSI.formTimeLocation(barsAndBeatsString: ""))
        XCTAssertThrowsError(try PTSI.formTimeLocation(barsAndBeatsString: " "))
        
        // -- subframes not enabled -- (no ticks)
        XCTAssertEqual(try PTSI.formTimeLocation(barsAndBeatsString: "0|0"),
                       .barsAndBeats(bar: 0, beat: 0, ticks: nil)
        )
        XCTAssertEqual(try PTSI.formTimeLocation(barsAndBeatsString: "1|3"),
                       .barsAndBeats(bar: 1, beat: 3, ticks: nil)
        )
        XCTAssertEqual(try PTSI.formTimeLocation(barsAndBeatsString: "105|12"),
                       .barsAndBeats(bar: 105, beat: 12, ticks: nil)
        )
        
        // -- subframes enabled -- (includes ticks)
        XCTAssertEqual(try PTSI.formTimeLocation(barsAndBeatsString: "0|0| 000"),
                       .barsAndBeats(bar: 0, beat: 0, ticks: 0)
        )
        XCTAssertEqual(try PTSI.formTimeLocation(barsAndBeatsString: "1|3| 123"),
                       .barsAndBeats(bar: 1, beat: 3, ticks: 123)
        )
        XCTAssertEqual(try PTSI.formTimeLocation(barsAndBeatsString: "105|12| 123"),
                       .barsAndBeats(bar: 105, beat: 12, ticks: 123)
        )
        
        // malformed
        XCTAssertThrowsError(try PTSI.formTimeLocation(barsAndBeatsString: "|0"))
        XCTAssertThrowsError(try PTSI.formTimeLocation(barsAndBeatsString: "0|"))
        XCTAssertThrowsError(try PTSI.formTimeLocation(barsAndBeatsString: "||"))
        XCTAssertThrowsError(try PTSI.formTimeLocation(barsAndBeatsString: "|| "))
        XCTAssertThrowsError(try PTSI.formTimeLocation(barsAndBeatsString: "|0|0"))
        XCTAssertThrowsError(try PTSI.formTimeLocation(barsAndBeatsString: "|0|"))
        XCTAssertThrowsError(try PTSI.formTimeLocation(barsAndBeatsString: "A0|0"))
        XCTAssertThrowsError(try PTSI.formTimeLocation(barsAndBeatsString: "0|0A"))
        XCTAssertThrowsError(try PTSI.formTimeLocation(barsAndBeatsString: "0|0 "))
        XCTAssertThrowsError(try PTSI.formTimeLocation(barsAndBeatsString: "0|0|0"))
        XCTAssertThrowsError(try PTSI.formTimeLocation(barsAndBeatsString: "0|0|00"))
        XCTAssertThrowsError(try PTSI.formTimeLocation(barsAndBeatsString: "0|0|000"))
        XCTAssertThrowsError(try PTSI.formTimeLocation(barsAndBeatsString: "0|0|00000"))
        XCTAssertThrowsError(try PTSI.formTimeLocation(barsAndBeatsString: "0|0| 0000"))
    }
    
    func testFormTimeLocation_FeetAndFrames() throws {
        // empty
        XCTAssertThrowsError(try PTSI.formTimeLocation(feetAndFramesString: ""))
        XCTAssertThrowsError(try PTSI.formTimeLocation(feetAndFramesString: " "))
        
        // -- subframes not enabled --
        XCTAssertEqual(try PTSI.formTimeLocation(feetAndFramesString: "0+00"),
                       .feetAndFrames(feet: 0, frames: 0, subFrames: nil)
        )
        XCTAssertEqual(try PTSI.formTimeLocation(feetAndFramesString: "1+00"),
                       .feetAndFrames(feet: 1, frames: 0, subFrames: nil)
        )
        XCTAssertEqual(try PTSI.formTimeLocation(feetAndFramesString: "10+09"),
                       .feetAndFrames(feet: 10, frames: 9, subFrames: nil)
        )
        
        // -- subframes enabled --
        XCTAssertEqual(try PTSI.formTimeLocation(feetAndFramesString: "0+00.00"),
                       .feetAndFrames(feet: 0, frames: 0, subFrames: 0)
        )
        XCTAssertEqual(try PTSI.formTimeLocation(feetAndFramesString: "1+00.23"),
                       .feetAndFrames(feet: 1, frames: 0, subFrames: 23)
        )
        XCTAssertEqual(try PTSI.formTimeLocation(feetAndFramesString: "10+09.23"),
                       .feetAndFrames(feet: 10, frames: 9, subFrames: 23)
        )
        
        // malformed
        XCTAssertThrowsError(try PTSI.formTimeLocation(feetAndFramesString: "+"))
        XCTAssertThrowsError(try PTSI.formTimeLocation(feetAndFramesString: "+."))
        XCTAssertThrowsError(try PTSI.formTimeLocation(feetAndFramesString: "0+0"))
        XCTAssertThrowsError(try PTSI.formTimeLocation(feetAndFramesString: "00+0"))
        XCTAssertThrowsError(try PTSI.formTimeLocation(feetAndFramesString: "0+000"))
        XCTAssertThrowsError(try PTSI.formTimeLocation(feetAndFramesString: "0+"))
        XCTAssertThrowsError(try PTSI.formTimeLocation(feetAndFramesString: "+00"))
        XCTAssertThrowsError(try PTSI.formTimeLocation(feetAndFramesString: "A0+00"))
        XCTAssertThrowsError(try PTSI.formTimeLocation(feetAndFramesString: "0+00A"))
        XCTAssertThrowsError(try PTSI.formTimeLocation(feetAndFramesString: "0+00."))
        XCTAssertThrowsError(try PTSI.formTimeLocation(feetAndFramesString: "0+00.0"))
        XCTAssertThrowsError(try PTSI.formTimeLocation(feetAndFramesString: "0+00.000"))
    }
}
