//
//  DAWMarker Conversions Tests.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import XCTest
@testable import DAWFileTools
import SwiftTimecodeCore

class DAWMarkerConversions_Tests: XCTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    // MARK: -
    
    /// Same frame rate
    func testResolvedTimecodeA() throws {
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
        
        let resolved = try XCTUnwrap(marker.resolvedTimecode(
            at: .fps23_976,
            base: sfBase,
            limit: .max24Hours,
            startTimecode: Timecode(.zero, at: .fps23_976, base: sfBase)
        ))
        
        XCTAssertEqual(resolved.frameRate, .fps23_976)
        XCTAssertEqual(resolved.upperLimit, .max24Hours)
        XCTAssertEqual(
            resolved.components,
            .init(d: 0, h: 0, m: 0, s: 5, f: 17, sf: 0)
        )
    }
    
    /// Same frame rate
    func testResolvedTimecodeB() throws {
        let sfBase: Timecode.SubFramesBase = .max80SubFrames
        
        let marker = DAWMarker(
            storage: .init(
                value: .timecodeString(absolute: "00:00:09:09"),
                frameRate: .fps23_976,
                base: sfBase
            ),
            name: "Marker 1",
            comment: nil
        )
        
        let resolved = try XCTUnwrap(marker.resolvedTimecode(
            at: .fps23_976,
            base: sfBase,
            limit: .max24Hours,
            startTimecode: Timecode(.zero, at: .fps23_976, base: sfBase)
        ))
        
        XCTAssertEqual(resolved.frameRate, .fps23_976)
        XCTAssertEqual(resolved.upperLimit, .max24Hours)
        XCTAssertEqual(
            resolved.components,
            .init(d: 0, h: 0, m: 0, s: 9, f: 9, sf: 0)
        )
    }
    
    /// Different frame rate
    func testResolvedTimecodeC() throws {
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
        
        let resolved = try XCTUnwrap(marker.resolvedTimecode(
            at: .fps30,
            base: sfBase,
            limit: .max24Hours,
            startTimecode: Timecode(.zero, at: .fps30, base: sfBase)
        ))
        
        XCTAssertEqual(resolved.frameRate, .fps30)
        XCTAssertEqual(resolved.upperLimit, .max24Hours)
        XCTAssertEqual(
            resolved.components,
            .init(d: 0, h: 0, m: 0, s: 5, f: 21, sf: 33)
        )
    }
    
    // MARK: - Rational Fraction
    
    func testOriginalTimecode_Fraction() throws {
        let sfBase: Timecode.SubFramesBase = .max80SubFrames
        
        let marker = DAWMarker(
            storage: .init(
                value: .rational(relativeToStart: Fraction(3600, 1)),
                frameRate: .fps24,
                base: sfBase
            ),
            name: "Marker 1",
            comment: nil
        )
        
        let original = try XCTUnwrap(marker.originalTimecode(base: sfBase, limit: .max100Days))
        XCTAssertEqual(original.frameRate, .fps24)
        XCTAssertEqual(original.upperLimit, .max100Days)
        XCTAssertEqual(
            original.components,
            .init(d: 0, h: 1, m: 0, s: 0, f: 0, sf: 0)
        )
    }
    
    func testResolvedTimecode_Fraction() throws {
        let sfBase: Timecode.SubFramesBase = .max80SubFrames
        
        let marker = DAWMarker(
            storage: .init(
                value: .rational(relativeToStart: Fraction(3600, 1)),
                frameRate: .fps24,
                base: sfBase
            ),
            name: "Marker 1",
            comment: nil
        )
        
        let resolved = try XCTUnwrap(
            marker.resolvedTimecode(
                at: .fps29_97, 
                base: sfBase,
                limit: .max24Hours,
                startTimecode: Timecode(.zero, at: .fps29_97, base: sfBase)
            )
        )
        XCTAssertEqual(resolved.frameRate, .fps29_97)
        XCTAssertEqual(resolved.upperLimit, .max24Hours)
        XCTAssertEqual(
            resolved.components,
            .init(d: 0, h: 0, m: 59, s: 56, f: 12, sf: 08) // confirmed in Pro Tools
        )
    }
}
