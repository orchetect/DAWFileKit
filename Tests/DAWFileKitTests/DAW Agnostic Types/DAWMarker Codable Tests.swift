//
//  DAWMarker Codable Tests.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import XCTest
@testable import DAWFileKit
import TimecodeKit

class DAWMarkerCodable_Tests: XCTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    // MARK: -
    
    func testTimeStorage_RealTime() throws {
        let sfBase: Timecode.SubFramesBase = .max80SubFrames
        
        let marker = DAWMarker(
            storage: .init(
                value: .realTime(relativeToStart: 3600.0),
                frameRate: .fps23_976,
                base: sfBase
            ),
            name: "Marker 1",
            comment: nil
        )
        
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(marker)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(DAWMarker.self, from: encoded)
        
        // check properties
        XCTAssertEqual(marker, decoded)
        XCTAssertEqual(marker.name, decoded.name)
        XCTAssertEqual(marker.comment, decoded.comment)
        XCTAssertEqual(marker.timeStorage, decoded.timeStorage)
        
        // check specific time storage value
        guard case let .realTime(relativeToStart: timeValue) = decoded.timeStorage?.value else {
            XCTFail()
            return
        }
        XCTAssertEqual(timeValue, 3600.0)
    }
    
    func testTimeStorage_TimecodeString() throws {
        let sfBase: Timecode.SubFramesBase = .max80SubFrames
        
        let marker = DAWMarker(
            storage: .init(
                value: .timecodeString(absolute: "00:00:05:17"),
                frameRate: .fps23_976,
                base: sfBase
            ),
            name: "Marker 1",
            comment: nil
        )
        
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(marker)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(DAWMarker.self, from: encoded)
        
        // check properties
        XCTAssertEqual(marker, decoded)
        XCTAssertEqual(marker.name, decoded.name)
        XCTAssertEqual(marker.comment, decoded.comment)
        XCTAssertEqual(marker.timeStorage, decoded.timeStorage)
        
        // check specific time storage value
        guard case let .timecodeString(absolute: timecodeString) = decoded.timeStorage?.value else {
            XCTFail()
            return
        }
        XCTAssertEqual(timecodeString, "00:00:05:17")
    }
    
    func testTimeStorage_Rational() throws {
        let sfBase: Timecode.SubFramesBase = .max80SubFrames
        
        let marker = DAWMarker(
            storage: .init(
                value: .rational(relativeToStart: Fraction(3600, 1)),
                frameRate: .fps23_976,
                base: sfBase
            ),
            name: "Marker 1",
            comment: nil
        )
        
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(marker)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(DAWMarker.self, from: encoded)
        
        // check properties
        XCTAssertEqual(marker, decoded)
        XCTAssertEqual(marker.name, decoded.name)
        XCTAssertEqual(marker.comment, decoded.comment)
        XCTAssertEqual(marker.timeStorage, decoded.timeStorage)
        
        // check specific time storage value
        guard case let .rational(relativeToStart: fraction) = decoded.timeStorage?.value else {
            XCTFail()
            return
        }
        XCTAssertEqual(fraction, Fraction(3600, 1))
    }
}
