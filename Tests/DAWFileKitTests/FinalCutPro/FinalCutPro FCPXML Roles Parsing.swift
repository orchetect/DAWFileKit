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
    
    func testCollapseStandardSubRole() {
        XCTAssertEqual(collapseStandardSubRole(role: "Main", subRole: nil).role, "Main")
        XCTAssertEqual(collapseStandardSubRole(role: "Main", subRole: nil).subRole, nil)
        
        // empty sub-role
        XCTAssertEqual(collapseStandardSubRole(role: "Main", subRole: "").role, "Main")
        XCTAssertEqual(collapseStandardSubRole(role: "Main", subRole: "").subRole, nil)
        
        // whitespace-only sub-role
        XCTAssertEqual(collapseStandardSubRole(role: "Main", subRole: " ").role, "Main")
        XCTAssertEqual(collapseStandardSubRole(role: "Main", subRole: " ").subRole, nil)
        
        XCTAssertEqual(collapseStandardSubRole(role: "Main", subRole: "Main-1").role, "Main")
        XCTAssertEqual(collapseStandardSubRole(role: "Main", subRole: "Main-1").subRole, nil)
        
        XCTAssertEqual(collapseStandardSubRole(role: "Main", subRole: "Main-20").role, "Main")
        XCTAssertEqual(collapseStandardSubRole(role: "Main", subRole: "Main-20").subRole, nil)
        
        XCTAssertEqual(collapseStandardSubRole(role: "Main", subRole: "SubRole").role, "Main")
        XCTAssertEqual(collapseStandardSubRole(role: "Main", subRole: "SubRole").subRole, "SubRole")
        
        XCTAssertEqual(collapseStandardSubRole(role: "Main", subRole: "SubRole-20").role, "Main")
        XCTAssertEqual(collapseStandardSubRole(role: "Main", subRole: "SubRole-20").subRole, "SubRole-20")
    }
    
    func testLowercased() {
        typealias AR = FinalCutPro.FCPXML.AudioRole
        
        XCTAssertEqual(AR(rawValue: "dialogue")!.lowercased().rawValue, "dialogue")
        XCTAssertEqual(AR(rawValue: "Dialogue")!.lowercased().rawValue, "dialogue")
        XCTAssertEqual(AR(rawValue: "DIALOGUE")!.lowercased().rawValue, "dialogue")
        
        XCTAssertEqual(AR(rawValue: "dialogue.dialogue-1")!.lowercased().rawValue, "dialogue.dialogue-1")
        XCTAssertEqual(AR(rawValue: "Dialogue.Dialogue-1")!.lowercased().rawValue, "dialogue.dialogue-1")
        XCTAssertEqual(AR(rawValue: "DIALOGUE.DIALOGUE-1")!.lowercased().rawValue, "dialogue.dialogue-1")
    }
    
    func testTitleCased() {
        typealias AR = FinalCutPro.FCPXML.AudioRole
        
        XCTAssertEqual(AR(rawValue: "dialogue")!.titleCased().rawValue, "Dialogue")
        XCTAssertEqual(AR(rawValue: "Dialogue")!.titleCased().rawValue, "Dialogue")
        XCTAssertEqual(AR(rawValue: "DIALOGUE")!.titleCased().rawValue, "Dialogue")
        
        XCTAssertEqual(AR(rawValue: "dialogue.dialogue-1")!.titleCased().rawValue, "Dialogue.Dialogue-1")
        XCTAssertEqual(AR(rawValue: "Dialogue.Dialogue-1")!.titleCased().rawValue, "Dialogue.Dialogue-1")
        XCTAssertEqual(AR(rawValue: "DIALOGUE.DIALOGUE-1")!.titleCased().rawValue, "Dialogue.Dialogue-1")
    }
}

#endif
