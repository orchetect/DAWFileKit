//
//  ProTools SessionText SimpleTest.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import XCTest
@testable import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore

class ProTools_SessionText_SimpleTest: XCTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    func testSessionText_SimpleTest() throws {
        // load file
        
        let filename = "SessionText_SimpleTest_23-976fps_DefaultExportOptions_PT2020.3"
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
        
        // main header
        
        XCTAssertEqual(sessionInfo.main.name,            "SessionText_SimpleTest")
        XCTAssertEqual(sessionInfo.main.sampleRate,      48000.0)
        XCTAssertEqual(sessionInfo.main.bitDepth,        "24-bit")
        XCTAssertEqual(
            sessionInfo.main.startTimecode,
            try ProTools.formTimecode(.init(h: 0, m: 59, s: 55, f: 00), at: .fps23_976)
        )
        XCTAssertEqual(sessionInfo.main.frameRate,       .fps23_976)
        XCTAssertEqual(sessionInfo.main.audioTrackCount, 1)
        XCTAssertEqual(sessionInfo.main.audioClipCount,  1)
        XCTAssertEqual(sessionInfo.main.audioFileCount,  1)
        
        // files - online
        
        XCTAssertEqual(sessionInfo.onlineFiles?.count, 1)
        
        let file1 = sessionInfo.onlineFiles?.first
        
        XCTAssertEqual(file1?.filename, "Audio 1_01.wav")
        XCTAssertEqual(
            file1?.path,
            "Macintosh HD:Users:stef:Desktop:SessionText_SimpleTest:Audio Files:"
        )
        
        // files - offline
        
        XCTAssertEqual(sessionInfo.offlineFiles, [])
        
        // clips - online
        
        let onlineClips = try XCTUnwrap(sessionInfo.onlineClips)
        XCTAssertEqual(onlineClips.count, 1)
        
        let clip1 = try XCTUnwrap(onlineClips.first)
        XCTAssertEqual(clip1.name,       "Audio 1_01")
        XCTAssertEqual(clip1.sourceFile, "Audio 1_01.wav")
        XCTAssertEqual(clip1.channel,    nil)
        
        // clips - offline
        
        XCTAssertNil(sessionInfo.offlineClips)     // missing section
        
        // plug-ins
        
        XCTAssertEqual(sessionInfo.plugins, [])
        
        // tracks
        
        let tracks = try XCTUnwrap(sessionInfo.tracks)
        XCTAssertEqual(tracks.count, 1)
        
        let track1 = try XCTUnwrap(tracks.first)
        XCTAssertEqual(track1.name,               "Audio 1")
        XCTAssertEqual(track1.comments,           "")
        XCTAssertEqual(track1.userDelay,          0)
        XCTAssertEqual(track1.state,              [])
        XCTAssertEqual(track1.plugins,            [])
        
        XCTAssertEqual(track1.clips.count,        1)
        
        let track1clip1 = try XCTUnwrap(track1.clips.first)
        XCTAssertEqual(track1clip1.channel,       1)
        XCTAssertEqual(track1clip1.event,         1)
        XCTAssertEqual(track1clip1.name,          "Audio 1_01")
        XCTAssertEqual(
            track1clip1.startTime,
            .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 00, f: 00), at: .fps23_976))
        )
        XCTAssertEqual(
            track1clip1.endTime,
            .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 05, f: 00), at: .fps23_976))
        )
        XCTAssertEqual(
            track1clip1.duration,
            .timecode(try ProTools.formTimecode(.init(h: 00, m: 00, s: 05, f: 00), at: .fps23_976))
        )
        XCTAssertEqual(track1clip1.state,         .unmuted)
        
        // markers
        
        XCTAssertEqual(sessionInfo.markers, [])
        
        // orphan data
        
        XCTAssertNil(sessionInfo.orphanData)       // none
    }
}
