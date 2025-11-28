//
//  FinalCutPro FCPXML Root Version Tests.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
/* @testable */ import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore

final class FinalCutPro_FCPXML_RootVersionTests: FCPXMLTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    typealias Version = FinalCutPro.FCPXML.Version
    
    func testVersion() {
        let v = Version(major: 1, minor: 12)
        
        XCTAssertEqual(v.major, 1)
        XCTAssertEqual(v.minor, 12)
    }
    
    func testVersion_Equatable() {
        XCTAssertEqual(
            Version(major: 1, minor: 12),
            Version(major: 1, minor: 12)
        )
        
        XCTAssertNotEqual(
            Version(major: 1, minor: 12),
            Version(major: 1, minor: 13)
        )
        
        XCTAssertNotEqual(
            Version(major: 1, minor: 12),
            Version(major: 2, minor: 12)
        )
    }
    
    func testVersion_Comparable() {
        XCTAssertFalse(
            Version(major: 1, minor: 12) < Version(major: 1, minor: 12)
        )
        
        XCTAssertFalse(
            Version(major: 1, minor: 12) > Version(major: 1, minor: 12)
        )
        
        XCTAssertTrue(
            Version(major: 1, minor: 11) < Version(major: 1, minor: 12)
        )
        
        XCTAssertTrue(
            Version(major: 1, minor: 12) > Version(major: 1, minor: 11)
        )
        
        XCTAssertTrue(
            Version(major: 1, minor: 10) < Version(major: 2, minor: 3)
        )
        
        XCTAssertTrue(
            Version(major: 2, minor: 3) > Version(major: 1, minor: 10)
        )
    }
    
    func testVersion_RawValue_Invalid() throws {
        XCTAssertNil(Version(rawValue: ""))
        XCTAssertNil(Version(rawValue: "1."))
        XCTAssertNil(Version(rawValue: "1"))
        XCTAssertNil(Version(rawValue: "1.A"))
        XCTAssertNil(Version(rawValue: "A"))
        XCTAssertNil(Version(rawValue: "A.1"))
        XCTAssertNil(Version(rawValue: "A.A"))
        XCTAssertNil(Version(rawValue: "A.A.A"))
        XCTAssertNil(Version(rawValue: "1.12."))
        XCTAssertNil(Version(rawValue: "1.12.A"))
    }
    
    func testVersion_Init_RawValue() throws {
        let v = try XCTUnwrap(Version(rawValue: "1.12"))
        
        XCTAssertEqual(v.major, 1)
        XCTAssertEqual(v.minor, 12)
    }
    
    func testVersion_RawValue() throws {
        let v = try XCTUnwrap(Version(rawValue: "1.12"))
        
        XCTAssertEqual(v.rawValue, "1.12")
    }
}

#endif
