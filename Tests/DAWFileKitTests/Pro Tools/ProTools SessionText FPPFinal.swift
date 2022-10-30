//
//  ProTools SessionText FPPFinal.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import XCTest
@testable import DAWFileKit
import OTCore
import TimecodeKit

class ProTools_SessionText_FPPFinal: XCTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    func testSessionText_FPPFinal() throws {
        // load file
        
        let filename = "SessionText_FPPFinal_23-976fps_DefaultExportOptions_PT2020.3"
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
        
        XCTAssertEqual(
            sessionInfo.main.name,
            "FPP Edit 15 A1.4 A2.2 A3.2 A4.2 A5.2 A6.2 A7.2 A8.2 A9.2 Intl.1"
        )
        XCTAssertEqual(sessionInfo.main.sampleRate,      48000.0)
        XCTAssertEqual(sessionInfo.main.bitDepth,        "24-bit")
        XCTAssertEqual(
            sessionInfo.main.startTimecode,
            try ProTools.formTimecode(TCC(h: 0, m: 59, s: 55, f: 00), at: ._23_976)
        )
        XCTAssertEqual(sessionInfo.main.frameRate,       ._23_976)
        XCTAssertEqual(sessionInfo.main.audioTrackCount, 51)
        XCTAssertEqual(sessionInfo.main.audioClipCount,  765)
        XCTAssertEqual(sessionInfo.main.audioFileCount,  142)
        
        // files - online
        
        XCTAssertEqual(sessionInfo.onlineFiles?.count, 142)
        
        // files - offline
        
        XCTAssertEqual(sessionInfo.offlineFiles, [])
        
        // clips - online
        
        XCTAssertEqual(sessionInfo.onlineClips?.count, 753)
        
        // clips - offline
        
        XCTAssertNil(sessionInfo.offlineClips) // missing section
        
        // plug-ins
        
        XCTAssertEqual(sessionInfo.plugins?.count, 7)
        
        // tracks
        
        let tracks = try XCTUnwrap(sessionInfo.tracks)
        let firstTrack = try XCTUnwrap(tracks.first)
        XCTAssertEqual(firstTrack.name,       "DLG")
        XCTAssertEqual(firstTrack.state,      [.muted])
        XCTAssertEqual(firstTrack.clips.count, 65)
        let lastTrack = try XCTUnwrap(tracks.last)
        XCTAssertEqual(lastTrack.name,        "Master Bounce (Stereo)")
        XCTAssertEqual(lastTrack.state,       [.hidden, .inactive, .soloSafe])
        XCTAssertEqual(lastTrack.clips.count, 0)
        
        // markers
        
        XCTAssertEqual(sessionInfo.markers?.count, 294)
        
        // orphan data
        
        XCTAssertNil(sessionInfo.orphanData) // none
    }
}
