//
//  DAWMarker Comparable Tests.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import XCTest
@testable import DAWFileKit
import TimecodeKit

class DAWMarkerComparable_Tests: XCTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    // MARK: -
    
    #warning("> add unit tests")
    
    /// For comparison with the context of a timeline that is != 00:00:00:00
    func testCompareTo() throws {
        let frameRate: TimecodeFrameRate = ._24
        
        func dawMarker(_ string: String) -> DAWMarker {
            DAWMarker(
                storage: .init(
                    value: .timecodeString(string),
                    frameRate: frameRate,
                    base: ._80SubFrames
                ),
                name: "Name",
                comment: nil
            )
        }
        
        func tc(_ string: String) throws -> Timecode {
            try string.toTimecode(at: frameRate)
        }
        
        // orderedSame (==)
        
        XCTAssertEqual(
            try dawMarker("00:00:00:00")
                .compare(to: dawMarker("00:00:00:00"), timelineStart: tc("00:00:00:00")),
            .orderedSame
        )
        
        XCTAssertEqual(
            try dawMarker("00:00:00:00")
                .compare(to: dawMarker("00:00:00:00"), timelineStart: tc("01:00:00:00")),
            .orderedSame
        )
        
        XCTAssertEqual(
            try dawMarker("00:00:00:00.01")
                .compare(to: dawMarker("00:00:00:00.01"), timelineStart: tc("00:00:00:00")),
            .orderedSame
        )
        
        XCTAssertEqual(
            try dawMarker("01:00:00:00")
                .compare(to: dawMarker("01:00:00:00"), timelineStart: tc("00:00:00:00")),
            .orderedSame
        )
        
        XCTAssertEqual(
            try dawMarker("01:00:00:00")
                .compare(to: dawMarker("01:00:00:00"), timelineStart: tc("01:00:00:00")),
            .orderedSame
        )
        
        XCTAssertEqual(
            try dawMarker("01:00:00:00")
                .compare(to: dawMarker("01:00:00:00"), timelineStart: tc("02:00:00:00")),
            .orderedSame
        )
        
        // orderedAscending (<)
        
        XCTAssertEqual(
            try dawMarker("00:00:00:00")
                .compare(to: dawMarker("00:00:00:00.01"), timelineStart: tc("00:00:00:00")),
            .orderedAscending
        )
        
        XCTAssertEqual(
            try dawMarker("00:00:00:00")
                .compare(to: dawMarker("00:00:00:01"), timelineStart: tc("00:00:00:00")),
            .orderedAscending
        )
        
        XCTAssertEqual(
            try dawMarker("00:00:00:00")
                .compare(to: dawMarker("00:00:00:01"), timelineStart: tc("01:00:00:00")),
            .orderedAscending
        )
        
        XCTAssertEqual(
            try dawMarker("23:00:00:00")
                .compare(to: dawMarker("00:00:00:00"), timelineStart: tc("23:00:00:00")),
            .orderedAscending
        )
        
        XCTAssertEqual(
            try dawMarker("23:30:00:00")
                .compare(to: dawMarker("00:00:00:00"), timelineStart: tc("23:00:00:00")),
            .orderedAscending
        )
        
        XCTAssertEqual(
            try dawMarker("23:30:00:00")
                .compare(to: dawMarker("01:00:00:00"), timelineStart: tc("23:00:00:00")),
            .orderedAscending
        )
        
        // orderedDescending (>)
        
        XCTAssertEqual(
            try tc("00:00:00:00.01")
                .compare(to: tc("00:00:00:00"), timelineStart: tc("00:00:00:00")),
            .orderedDescending
        )
        
        XCTAssertEqual(
            try dawMarker("00:00:00:01")
                .compare(to: dawMarker("00:00:00:00"), timelineStart: tc("00:00:00:00")),
            .orderedDescending
        )
        
        XCTAssertEqual(
            try dawMarker("23:30:00:00")
                .compare(to: dawMarker("00:00:00:00"), timelineStart: tc("00:00:00:00")),
            .orderedDescending
        )
        
        XCTAssertEqual(
            try dawMarker("00:00:00:00")
                .compare(to: dawMarker("23:30:00:00"), timelineStart: tc("23:00:00:00")),
            .orderedDescending
        )
    }
}
