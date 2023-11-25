//
//  FinalCutPro FCPXML Roles Parsing.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
@testable import DAWFileKit
import OTCore

final class FinalCutPro_FCPXML_RolesParsing: FCPXMLTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    /// Standard role (audio or video)
    func testParseRawStandardRole() throws {
        // Should parse
        XCTAssertEqual(try parseRawStandardRole(rawValue: "Main").role, "Main")
        XCTAssertEqual(try parseRawStandardRole(rawValue: "Main").subRole, nil)
        
        XCTAssertEqual(try parseRawStandardRole(rawValue: "Main.Main-1").role, "Main")
        XCTAssertEqual(try parseRawStandardRole(rawValue: "Main.Main-1").subRole, "Main-1")
        
        XCTAssertEqual(try parseRawStandardRole(rawValue: "Main.Sub").role, "Main")
        XCTAssertEqual(try parseRawStandardRole(rawValue: "Main.Sub").subRole, "Sub")
        
        XCTAssertEqual(
            try parseRawStandardRole(rawValue: "Hellõ țhiș is ǎ maīn) role 😀.This is a 👋 sub role").role,
            "Hellõ țhiș is ǎ maīn) role 😀"
        )
        XCTAssertEqual(
            try parseRawStandardRole(rawValue: "Hellõ țhiș is ǎ maīn) role 😀.This is a 👋 sub role").subRole,
            "This is a 👋 sub role"
        )
        
        // Shouldn't parse
        XCTAssertThrowsError(try parseRawStandardRole(rawValue: "."))
        XCTAssertThrowsError(try parseRawStandardRole(rawValue: ".."))
        XCTAssertThrowsError(try parseRawStandardRole(rawValue: ".-"))
        XCTAssertThrowsError(try parseRawStandardRole(rawValue: ".-1"))
        XCTAssertThrowsError(try parseRawStandardRole(rawValue: "Main."))
        XCTAssertThrowsError(try parseRawStandardRole(rawValue: ".Sub"))
        XCTAssertThrowsError(try parseRawStandardRole(rawValue: ".Sub-1"))
        XCTAssertThrowsError(try parseRawStandardRole(rawValue: "Main.Main."))
        XCTAssertThrowsError(try parseRawStandardRole(rawValue: "Main.Main.Main-1"))
        XCTAssertThrowsError(try parseRawStandardRole(rawValue: "iTT?captionFormat=ITT.en"))
        XCTAssertThrowsError(try parseRawStandardRole(rawValue: "?="))
    }
    
    /// Closed caption role
    func testParseRawCaptionRole() {
        // Should parse
        XCTAssertEqual(try parseRawCaptionRole(rawValue: "iTT?captionFormat=ITT.en").role, "iTT")
        XCTAssertEqual(try parseRawCaptionRole(rawValue: "iTT?captionFormat=ITT.en").captionFormat, "ITT.en")
        
        XCTAssertEqual(try parseRawCaptionRole(rawValue: "Markers?captionFormat=ITT.en").role, "Markers")
        XCTAssertEqual(try parseRawCaptionRole(rawValue: "Markers?captionFormat=ITT.en").captionFormat, "ITT.en")
        
        XCTAssertEqual(
            try parseRawCaptionRole(rawValue: "Hellõ țhiș is ǎ capīion role 😀?captionFormat=ITT.en").role,
            "Hellõ țhiș is ǎ capīion role 😀"
        )
        XCTAssertEqual(
            try parseRawCaptionRole(rawValue: "Hellõ țhiș is ǎ capīion role 😀?captionFormat=ITT.en").captionFormat,
            "ITT.en"
        )
        
        // Shouldn't parse
        XCTAssertThrowsError(try parseRawCaptionRole(rawValue: "captionFormat=ITT.en"))
        XCTAssertThrowsError(try parseRawCaptionRole(rawValue: "iTT?captionFormat"))
        XCTAssertThrowsError(try parseRawCaptionRole(rawValue: "?="))
        XCTAssertThrowsError(try parseRawCaptionRole(rawValue: "Main"))
        XCTAssertThrowsError(try parseRawCaptionRole(rawValue: "Main.Main-1"))
        XCTAssertThrowsError(try parseRawCaptionRole(rawValue: "Main.Sub"))
        XCTAssertThrowsError(try parseRawCaptionRole(rawValue: "Hellõ țhiș is ǎ maīn) role 😀.This is a 👋 sub role"))
        XCTAssertThrowsError(try parseRawCaptionRole(rawValue: "."))
        XCTAssertThrowsError(try parseRawCaptionRole(rawValue: ".."))
        XCTAssertThrowsError(try parseRawCaptionRole(rawValue: ".-"))
        XCTAssertThrowsError(try parseRawCaptionRole(rawValue: ".-1"))
        XCTAssertThrowsError(try parseRawCaptionRole(rawValue: "Main."))
        XCTAssertThrowsError(try parseRawCaptionRole(rawValue: ".Sub"))
        XCTAssertThrowsError(try parseRawCaptionRole(rawValue: ".Sub-1"))
        XCTAssertThrowsError(try parseRawCaptionRole(rawValue: "Main.Main."))
        XCTAssertThrowsError(try parseRawCaptionRole(rawValue: "Main.Main.Main"))
    }
}

#endif
