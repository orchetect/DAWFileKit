//
//  ProTools SessionText EmptySession.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//

import XCTest
@testable import DAWFileKit
import OTCore
import TimecodeKit

class DAWFileKit_ProTools_SessionText_EmptySession: XCTestCase {
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
        let sessionInfo = try ProTools.SessionInfo(data: rawData, messages: &parseMessages)
        
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
            ProTools.kTimecode(TCC(h: 0, m: 59, s: 55, f: 00), at: ._23_976)
        )
        XCTAssertEqual(sessionInfo.main.frameRate,         ._23_976)
        XCTAssertEqual(sessionInfo.main.audioTrackCount,   0)
        XCTAssertEqual(sessionInfo.main.audioClipCount,    0)
        XCTAssertEqual(sessionInfo.main.audioFileCount,    0)
        
        // files - online
        
        XCTAssertNil(sessionInfo.onlineFiles)  // empty
        
        // files - offline
        
        XCTAssertNil(sessionInfo.offlineFiles) // empty
        
        // clips - online
        
        XCTAssertNil(sessionInfo.onlineClips)  // empty
        
        // clips - offline
        
        XCTAssertNil(sessionInfo.offlineClips) // empty
        
        // plug-ins
        
        XCTAssertNil(sessionInfo.plugins)      // empty
        
        // tracks
        
        XCTAssertNil(sessionInfo.tracks)       // empty
        
        // markers
        
        XCTAssertNil(sessionInfo.markers)      // empty
        
        // orphan data
        
        XCTAssertNil(sessionInfo.orphanData)   // empty
    }
}
