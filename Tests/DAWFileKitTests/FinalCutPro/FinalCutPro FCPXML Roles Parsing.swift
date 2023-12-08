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
        let Parse = FinalCutPro.FCPXML._parseRawStandardRole(rawValue:)
        
        // Should parse
        XCTAssertEqual(try Parse("Main").role, "Main")
        XCTAssertEqual(try Parse("Main").subRole, nil)
        
        XCTAssertEqual(try Parse("Main.Main-1").role, "Main")
        XCTAssertEqual(try Parse("Main.Main-1").subRole, "Main-1")
        
        XCTAssertEqual(try Parse("Main.Sub").role, "Main")
        XCTAssertEqual(try Parse("Main.Sub").subRole, "Sub")
        
        XCTAssertEqual(
            try Parse("Hellõ țhiș is ǎ maīn) role 😀.This is a 👋 sub role").role,
            "Hellõ țhiș is ǎ maīn) role 😀"
        )
        XCTAssertEqual(
            try Parse("Hellõ țhiș is ǎ maīn) role 😀.This is a 👋 sub role").subRole,
            "This is a 👋 sub role"
        )
        
        // Shouldn't parse
        XCTAssertThrowsError(try Parse("."))
        XCTAssertThrowsError(try Parse(".."))
        XCTAssertThrowsError(try Parse(".-"))
        XCTAssertThrowsError(try Parse(".-1"))
        XCTAssertThrowsError(try Parse("Main."))
        XCTAssertThrowsError(try Parse(".Sub"))
        XCTAssertThrowsError(try Parse(".Sub-1"))
        XCTAssertThrowsError(try Parse("Main.Main."))
        XCTAssertThrowsError(try Parse("Main.Main.Main-1"))
        XCTAssertThrowsError(try Parse("iTT?captionFormat=ITT.en"))
        XCTAssertThrowsError(try Parse("?="))
    }
    
    /// Closed caption role
    func testParseRawCaptionRole() {
        let Parse = FinalCutPro.FCPXML._parseRawCaptionRole(rawValue:)
        
        // Should parse
        XCTAssertEqual(try Parse("iTT?captionFormat=ITT.en").role, "iTT")
        XCTAssertEqual(try Parse("iTT?captionFormat=ITT.en").captionFormat, "ITT.en")
        
        XCTAssertEqual(try Parse("Markers?captionFormat=ITT.en").role, "Markers")
        XCTAssertEqual(try Parse("Markers?captionFormat=ITT.en").captionFormat, "ITT.en")
        
        XCTAssertEqual(
            try Parse("Hellõ țhiș is ǎ capīion role 😀?captionFormat=ITT.en").role,
            "Hellõ țhiș is ǎ capīion role 😀"
        )
        XCTAssertEqual(
            try Parse("Hellõ țhiș is ǎ capīion role 😀?captionFormat=ITT.en").captionFormat,
            "ITT.en"
        )
        
        // Shouldn't parse
        XCTAssertThrowsError(try Parse("captionFormat=ITT.en"))
        XCTAssertThrowsError(try Parse("iTT?captionFormat"))
        XCTAssertThrowsError(try Parse("?="))
        XCTAssertThrowsError(try Parse("Main"))
        XCTAssertThrowsError(try Parse("Main.Main-1"))
        XCTAssertThrowsError(try Parse("Main.Sub"))
        XCTAssertThrowsError(try Parse("Hellõ țhiș is ǎ maīn) role 😀.This is a 👋 sub role"))
        XCTAssertThrowsError(try Parse("."))
        XCTAssertThrowsError(try Parse(".."))
        XCTAssertThrowsError(try Parse(".-"))
        XCTAssertThrowsError(try Parse(".-1"))
        XCTAssertThrowsError(try Parse("Main."))
        XCTAssertThrowsError(try Parse(".Sub"))
        XCTAssertThrowsError(try Parse(".Sub-1"))
        XCTAssertThrowsError(try Parse("Main.Main."))
        XCTAssertThrowsError(try Parse("Main.Main.Main"))
    }
    
    func testCollapseStandardSubRole() {
        let Collapse = FinalCutPro.FCPXML._collapseStandardSubRole(role:subRole:)
        
        XCTAssertEqual(Collapse("Main", nil).role, "Main")
        XCTAssertEqual(Collapse("Main", nil).subRole, nil)
        
        // empty sub-role
        XCTAssertEqual(Collapse("Main", "").role, "Main")
        XCTAssertEqual(Collapse("Main", "").subRole, nil)
        
        // whitespace-only sub-role
        XCTAssertEqual(Collapse("Main", " ").role, "Main")
        XCTAssertEqual(Collapse("Main", " ").subRole, nil)
        
        XCTAssertEqual(Collapse("Main", "Main-1").role, "Main")
        XCTAssertEqual(Collapse("Main", "Main-1").subRole, nil)
        
        XCTAssertEqual(Collapse("Main", "Main-20").role, "Main")
        XCTAssertEqual(Collapse("Main", "Main-20").subRole, nil)
        
        XCTAssertEqual(Collapse("Main", "SubRole").role, "Main")
        XCTAssertEqual(Collapse("Main", "SubRole").subRole, "SubRole")
        
        XCTAssertEqual(Collapse("Main", "SubRole-20").role, "Main")
        XCTAssertEqual(Collapse("Main", "SubRole-20").subRole, "SubRole-20")
    }
    
    func testIsSMainRoleBuiltIn_Video() {
        typealias VR = FinalCutPro.FCPXML.VideoRole
        
        XCTAssertFalse(VR(rawValue: "custom")!.isMainRoleBuiltIn)
        XCTAssertFalse(VR(rawValue: "custom.custom")!.isMainRoleBuiltIn)
        XCTAssertFalse(VR(rawValue: "custom.custom-1")!.isMainRoleBuiltIn)
        XCTAssertFalse(VR(rawValue: "custom.video-1")!.isMainRoleBuiltIn)
        
        XCTAssertTrue(VR(rawValue: "video")!.isMainRoleBuiltIn)
        XCTAssertTrue(VR(rawValue: "video.video-1")!.isMainRoleBuiltIn)
        XCTAssertTrue(VR(rawValue: "video.custom")!.isMainRoleBuiltIn)
        
        XCTAssertTrue(VR(rawValue: "Video")!.isMainRoleBuiltIn)
        XCTAssertTrue(VR(rawValue: "Video.Video-1")!.isMainRoleBuiltIn)
        XCTAssertTrue(VR(rawValue: "Video.custom")!.isMainRoleBuiltIn)
        
        XCTAssertTrue(VR(rawValue: "titles")!.isMainRoleBuiltIn)
        XCTAssertTrue(VR(rawValue: "titles.titles-1")!.isMainRoleBuiltIn)
        XCTAssertTrue(VR(rawValue: "titles.custom")!.isMainRoleBuiltIn)
        
        XCTAssertTrue(VR(rawValue: "Titles")!.isMainRoleBuiltIn)
        XCTAssertTrue(VR(rawValue: "Titles.Titles-1")!.isMainRoleBuiltIn)
        XCTAssertTrue(VR(rawValue: "Titles.custom")!.isMainRoleBuiltIn)
    }
    
    func testIsSMainRoleBuiltIn_Audio() {
        typealias AR = FinalCutPro.FCPXML.AudioRole
        
        XCTAssertFalse(AR(rawValue: "custom")!.isMainRoleBuiltIn)
        XCTAssertFalse(AR(rawValue: "custom.custom")!.isMainRoleBuiltIn)
        XCTAssertFalse(AR(rawValue: "custom.custom-1")!.isMainRoleBuiltIn)
        XCTAssertFalse(AR(rawValue: "custom.dialogue-1")!.isMainRoleBuiltIn)
        
        XCTAssertTrue(AR(rawValue: "dialogue")!.isMainRoleBuiltIn)
        XCTAssertTrue(AR(rawValue: "dialogue.dialogue-1")!.isMainRoleBuiltIn)
        XCTAssertTrue(AR(rawValue: "dialogue.custom")!.isMainRoleBuiltIn)
        
        XCTAssertTrue(AR(rawValue: "Dialogue")!.isMainRoleBuiltIn)
        XCTAssertTrue(AR(rawValue: "Dialogue.Dialogue-1")!.isMainRoleBuiltIn)
        XCTAssertTrue(AR(rawValue: "Dialogue.custom")!.isMainRoleBuiltIn)
        
        XCTAssertTrue(AR(rawValue: "effects")!.isMainRoleBuiltIn)
        XCTAssertTrue(AR(rawValue: "effects.effects-1")!.isMainRoleBuiltIn)
        XCTAssertTrue(AR(rawValue: "effects.custom")!.isMainRoleBuiltIn)
        
        XCTAssertTrue(AR(rawValue: "Effects")!.isMainRoleBuiltIn)
        XCTAssertTrue(AR(rawValue: "Effects.Effects-1")!.isMainRoleBuiltIn)
        XCTAssertTrue(AR(rawValue: "Effects.custom")!.isMainRoleBuiltIn)
        
        XCTAssertTrue(AR(rawValue: "music")!.isMainRoleBuiltIn)
        XCTAssertTrue(AR(rawValue: "music.music-1")!.isMainRoleBuiltIn)
        XCTAssertTrue(AR(rawValue: "music.custom")!.isMainRoleBuiltIn)
        
        XCTAssertTrue(AR(rawValue: "Music")!.isMainRoleBuiltIn)
        XCTAssertTrue(AR(rawValue: "Music.Music-1")!.isMainRoleBuiltIn)
        XCTAssertTrue(AR(rawValue: "Music.custom")!.isMainRoleBuiltIn)
    }
    
    func testIsSMainRoleBuiltIn_Caption() {
        typealias CR = FinalCutPro.FCPXML.CaptionRole
        
        XCTAssertFalse(CR(rawValue: "custom?captionFormat=ITT.en")!.isMainRoleBuiltIn)
        XCTAssertFalse(CR(rawValue: "video?captionFormat=ITT.en")!.isMainRoleBuiltIn)
        XCTAssertFalse(CR(rawValue: "titles?captionFormat=ITT.en")!.isMainRoleBuiltIn)
        XCTAssertFalse(CR(rawValue: "dialogue?captionFormat=ITT.en")!.isMainRoleBuiltIn)
        XCTAssertFalse(CR(rawValue: "effects?captionFormat=ITT.en")!.isMainRoleBuiltIn)
        XCTAssertFalse(CR(rawValue: "music?captionFormat=ITT.en")!.isMainRoleBuiltIn)
        
        XCTAssertTrue(CR(rawValue: "iTT?captionFormat=ITT.en")!.isMainRoleBuiltIn)
        XCTAssertTrue(CR(rawValue: "SRT?captionFormat=ITT.en")!.isMainRoleBuiltIn)
        XCTAssertTrue(CR(rawValue: "CEA-608?captionFormat=ITT.en")!.isMainRoleBuiltIn)
    }
    
    func testLowercased() {
        typealias AR = FinalCutPro.FCPXML.AudioRole
        
        XCTAssertEqual(AR(rawValue: "dialogue")!.lowercased(derivedOnly: false).rawValue, "dialogue")
        XCTAssertEqual(AR(rawValue: "Dialogue")!.lowercased(derivedOnly: false).rawValue, "dialogue")
        XCTAssertEqual(AR(rawValue: "DIALOGUE")!.lowercased(derivedOnly: false).rawValue, "dialogue")
        
        XCTAssertEqual(AR(rawValue: "dialogue.dialogue-1")!.lowercased(derivedOnly: false).rawValue, "dialogue.dialogue-1")
        XCTAssertEqual(AR(rawValue: "Dialogue.Dialogue-1")!.lowercased(derivedOnly: false).rawValue, "dialogue.dialogue-1")
        XCTAssertEqual(AR(rawValue: "DIALOGUE.DIALOGUE-1")!.lowercased(derivedOnly: false).rawValue, "dialogue.dialogue-1")
        
        XCTAssertEqual(AR(rawValue: "dialogue.mixl")!.lowercased(derivedOnly: false).rawValue, "dialogue.mixl")
        XCTAssertEqual(AR(rawValue: "dialogue.MixL")!.lowercased(derivedOnly: false).rawValue, "dialogue.mixl")
        XCTAssertEqual(AR(rawValue: "Dialogue.MixL")!.lowercased(derivedOnly: false).rawValue, "dialogue.mixl")
        XCTAssertEqual(AR(rawValue: "DIALOGUE.MIXL")!.lowercased(derivedOnly: false).rawValue, "dialogue.mixl")
    }
    
    func testLowercased_DerivedOnly() {
        typealias AR = FinalCutPro.FCPXML.AudioRole
        
        XCTAssertEqual(AR(rawValue: "dialogue")!.lowercased(derivedOnly: true).rawValue, "dialogue")
        XCTAssertEqual(AR(rawValue: "Dialogue")!.lowercased(derivedOnly: true).rawValue, "dialogue")
        XCTAssertEqual(AR(rawValue: "DIALOGUE")!.lowercased(derivedOnly: true).rawValue, "dialogue")
        
        XCTAssertEqual(AR(rawValue: "dialogue.dialogue-1")!.lowercased(derivedOnly: true).rawValue, "dialogue.dialogue-1")
        XCTAssertEqual(AR(rawValue: "Dialogue.Dialogue-1")!.lowercased(derivedOnly: true).rawValue, "dialogue.dialogue-1")
        XCTAssertEqual(AR(rawValue: "DIALOGUE.DIALOGUE-1")!.lowercased(derivedOnly: true).rawValue, "dialogue.dialogue-1")
        
        XCTAssertEqual(AR(rawValue: "dialogue.mixl")!.lowercased(derivedOnly: true).rawValue, "dialogue.mixl")
        XCTAssertEqual(AR(rawValue: "dialogue.MixL")!.lowercased(derivedOnly: true).rawValue, "dialogue.MixL")
        XCTAssertEqual(AR(rawValue: "Dialogue.MixL")!.lowercased(derivedOnly: true).rawValue, "dialogue.MixL")
        XCTAssertEqual(AR(rawValue: "DIALOGUE.MIXL")!.lowercased(derivedOnly: true).rawValue, "dialogue.MIXL")
    }
    
    func testTitleCased() {
        typealias AR = FinalCutPro.FCPXML.AudioRole
        
        XCTAssertEqual(AR(rawValue: "dialogue")!.titleCased(derivedOnly: false).rawValue, "Dialogue")
        XCTAssertEqual(AR(rawValue: "Dialogue")!.titleCased(derivedOnly: false).rawValue, "Dialogue")
        XCTAssertEqual(AR(rawValue: "DIALOGUE")!.titleCased(derivedOnly: false).rawValue, "Dialogue")
        
        XCTAssertEqual(AR(rawValue: "dialogue.dialogue-1")!.titleCased(derivedOnly: false).rawValue, "Dialogue.Dialogue-1")
        XCTAssertEqual(AR(rawValue: "Dialogue.Dialogue-1")!.titleCased(derivedOnly: false).rawValue, "Dialogue.Dialogue-1")
        XCTAssertEqual(AR(rawValue: "DIALOGUE.DIALOGUE-1")!.titleCased(derivedOnly: false).rawValue, "Dialogue.Dialogue-1")
        
        XCTAssertEqual(AR(rawValue: "dialogue.mixl")!.titleCased(derivedOnly: false).rawValue, "Dialogue.Mixl")
        XCTAssertEqual(AR(rawValue: "dialogue.MixL")!.titleCased(derivedOnly: false).rawValue, "Dialogue.Mixl") // TODO: not ideal
        XCTAssertEqual(AR(rawValue: "Dialogue.MixL")!.titleCased(derivedOnly: false).rawValue, "Dialogue.Mixl") // TODO: not ideal
        XCTAssertEqual(AR(rawValue: "DIALOGUE.MIXL")!.titleCased(derivedOnly: false).rawValue, "Dialogue.Mixl") // TODO: not ideal
    }
    
    func testTitleCased_DerivedOnly() {
        typealias AR = FinalCutPro.FCPXML.AudioRole
        
        XCTAssertEqual(AR(rawValue: "dialogue")!.titleCased(derivedOnly: true).rawValue, "Dialogue")
        XCTAssertEqual(AR(rawValue: "Dialogue")!.titleCased(derivedOnly: true).rawValue, "Dialogue")
        XCTAssertEqual(AR(rawValue: "DIALOGUE")!.titleCased(derivedOnly: true).rawValue, "Dialogue")
        
        XCTAssertEqual(AR(rawValue: "dialogue.dialogue-1")!.titleCased(derivedOnly: true).rawValue, "Dialogue.Dialogue-1")
        XCTAssertEqual(AR(rawValue: "Dialogue.Dialogue-1")!.titleCased(derivedOnly: true).rawValue, "Dialogue.Dialogue-1")
        XCTAssertEqual(AR(rawValue: "DIALOGUE.DIALOGUE-1")!.titleCased(derivedOnly: true).rawValue, "Dialogue.Dialogue-1")
        
        XCTAssertEqual(AR(rawValue: "dialogue.mixl")!.titleCased(derivedOnly: true).rawValue, "Dialogue.mixl")
        XCTAssertEqual(AR(rawValue: "dialogue.MixL")!.titleCased(derivedOnly: true).rawValue, "Dialogue.MixL")
        XCTAssertEqual(AR(rawValue: "Dialogue.MixL")!.titleCased(derivedOnly: true).rawValue, "Dialogue.MixL")
        XCTAssertEqual(AR(rawValue: "DIALOGUE.MIXL")!.titleCased(derivedOnly: true).rawValue, "Dialogue.MIXL")
    }
    
    func testIsSubRoleDerivedFromMainRole() {
        let IsDerived = FinalCutPro.FCPXML._isSubRole(_:derivedFromMainRole:)
        
        XCTAssertFalse(IsDerived(nil, "Dialogue"))
        XCTAssertFalse(IsDerived("", "Dialogue"))
        XCTAssertFalse(IsDerived(" ", "Dialogue"))
        XCTAssertFalse(IsDerived("Dial", "Dialogue"))
        XCTAssertFalse(IsDerived("Video", "Dialogue"))
        
        XCTAssertTrue(IsDerived("Dialogue", "Dialogue"))
        XCTAssertTrue(IsDerived("Dialogue-1", "Dialogue"))
    }
}

#endif
