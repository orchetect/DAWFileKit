//
//  ProTools SessionText EmptySession.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import XCTest
@testable import DAWFileTools
import SwiftExtensions
import TimecodeKitCore

class ProTools_SessionText_EmptySession: XCTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    func testSessionText_EmptySession() throws {
        // load file
        
        let filename = "SessionText_EmptySession_23-976fps_DefaultExportOptions_PT2020.3"
        guard let rawData = loadFileContents(
            forResource: filename,
            withExtension: "txt",
            subFolder: .ptSessionTextExports
        )
        else { XCTFail("Could not form URL, possibly could not find file."); return }
        
        // parse
        
        var parseMessages: [ProTools.SessionInfo.ParseMessage] = []
        let sessionInfo = try ProTools.SessionInfo(
            fileContent: rawData,
            // no time values present in the file but supply a time format anyway to suppress the
            // format auto-detect error
            timeValueFormat: .timecode,
            messages: &parseMessages
        )
        
        // parse messages
        
        XCTAssertEqual(parseMessages.errors.count, 0)
        if !parseMessages.errors.isEmpty {
            dump(parseMessages.errors)
        }
        
        // main header
        
        XCTAssertEqual(sessionInfo.main.name,              "SessionText_EmptySession")
        XCTAssertEqual(sessionInfo.main.sampleRate,        48000.0)
        XCTAssertEqual(sessionInfo.main.bitDepth,          "24-bit")
        XCTAssertEqual(
            sessionInfo.main.startTimecode,
            try ProTools.formTimecode(.init(h: 0, m: 59, s: 55, f: 00), at: .fps23_976)
        )
        XCTAssertEqual(sessionInfo.main.frameRate,         .fps23_976)
        XCTAssertEqual(sessionInfo.main.audioTrackCount,   0)
        XCTAssertEqual(sessionInfo.main.audioClipCount,    0)
        XCTAssertEqual(sessionInfo.main.audioFileCount,    0)
        
        // files - online
        
        XCTAssertEqual(sessionInfo.onlineFiles, [])
        
        // files - offline
        
        XCTAssertEqual(sessionInfo.offlineFiles, [])
        
        // clips - online
        
        XCTAssertNil(sessionInfo.onlineClips) // missing section
        
        // clips - offline
        
        XCTAssertNil(sessionInfo.offlineClips) // missing section
        
        // plug-ins
        
        XCTAssertEqual(sessionInfo.plugins, [])
        
        // tracks
        
        XCTAssertEqual(sessionInfo.tracks, [])
        
        // markers
        
        XCTAssertEqual(sessionInfo.markers, [])
        
        // orphan data
        
        XCTAssertNil(sessionInfo.orphanData) // none
    }
}
