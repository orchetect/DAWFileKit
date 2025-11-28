//
//  ProTools SessionText ExtendedChars.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import XCTest
@testable import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore

class ProTools_SessionText_ExtendedChars: XCTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    func testSessionText_ExtendedChars_TextEditFormat() throws {
        // load file
        
        let filename = "SessionText_ExtendedChars_TextEditFormat_PT2023.3"
        guard let rawData = loadFileContents(
            forResource: filename,
            withExtension: "txt",
            subFolder: .ptSessionTextExports
        )
        else { XCTFail("Could not form URL, possibly could not find file."); return }
        
        // parse
        
        var parseMessages: [ProTools.SessionInfo.ParseMessage] = []
        let sessionInfo = try ProTools.SessionInfo(fileContent: rawData, messages: &parseMessages)
        
        // parse messages
        
        XCTAssertEqual(parseMessages.errors.count, 0)
        if !parseMessages.errors.isEmpty {
            dump(parseMessages.errors)
        }
        
        // (we don't care about header for this test, no need to check it)
        
        // markers
        
        let markers = try XCTUnwrap(sessionInfo.markers)
        XCTAssertEqual(markers.count, 4)
        
        let marker1 = try XCTUnwrap(markers[safe: 0])
        XCTAssertEqual(marker1.name, "Test Ellipsis…")
        XCTAssertEqual(marker1.comment, nil)
        
        let marker2 = try XCTUnwrap(markers[safe: 1])
        XCTAssertEqual(marker2.name, "Test Em Dash —")
        XCTAssertEqual(marker2.comment, nil)
        
        let marker3 = try XCTUnwrap(markers[safe: 2])
        XCTAssertEqual(marker3.name, "Test En Dash –")
        XCTAssertEqual(marker3.comment, nil)
        
        let marker4 = try XCTUnwrap(markers[safe: 3])
        XCTAssertEqual(marker4.name, "Right Side Quote’s Not An Apostrophe")
        XCTAssertEqual(marker4.comment, nil)
    }
    
    func testSessionText_ExtendedChars_UTF8Format() throws {
        // load file
        
        let filename = "SessionText_ExtendedChars_UTF8Format_PT2023.3"
        guard let rawData = loadFileContents(
            forResource: filename,
            withExtension: "txt",
            subFolder: .ptSessionTextExports
        )
        else { XCTFail("Could not form URL, possibly could not find file."); return }
        
        // parse
        
        var parseMessages: [ProTools.SessionInfo.ParseMessage] = []
        let sessionInfo = try ProTools.SessionInfo(fileContent: rawData, messages: &parseMessages)
        
        // parse messages
        
        XCTAssertEqual(parseMessages.errors.count, 0)
        if !parseMessages.errors.isEmpty {
            dump(parseMessages.errors)
        }
        
        // (we don't care about header for this test, no need to check it)
        
        // markers
        
        let markers = try XCTUnwrap(sessionInfo.markers)
        XCTAssertEqual(markers.count, 4)
        
        let marker1 = try XCTUnwrap(markers[safe: 0])
        XCTAssertEqual(marker1.name, "Test Ellipsis…")
        XCTAssertEqual(marker1.comment, nil)
        
        let marker2 = try XCTUnwrap(markers[safe: 1])
        XCTAssertEqual(marker2.name, "Test Em Dash —")
        XCTAssertEqual(marker2.comment, nil)
        
        let marker3 = try XCTUnwrap(markers[safe: 2])
        XCTAssertEqual(marker3.name, "Test En Dash –")
        XCTAssertEqual(marker3.comment, nil)
        
        let marker4 = try XCTUnwrap(markers[safe: 3])
        XCTAssertEqual(marker4.name, "Right Side Quote’s Not An Apostrophe")
        XCTAssertEqual(marker4.comment, nil)
    }
}
