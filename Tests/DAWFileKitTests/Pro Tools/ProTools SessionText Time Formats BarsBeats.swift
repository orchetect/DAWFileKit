//
//  ProTools SessionText Time Formats BarsBeats.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import XCTest
@testable import DAWFileKit
import OTCore
import TimecodeKit

class ProTools_SessionText_TimeFormats_BarsBeats: XCTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    func testSessionText_BarsBeats() throws {
        // load file
        
        let filename = "SessionText_TimeFormats_BarsBeats_PT2022.9"
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
        
        XCTAssertEqual(sessionInfo.main.name,              "Test")
        XCTAssertEqual(sessionInfo.main.sampleRate,        48000.0)
        XCTAssertEqual(sessionInfo.main.bitDepth,          "24-bit")
        XCTAssertEqual(
            sessionInfo.main.startTimecode,
            try ProTools.formTimecode(TCC(h: 23, m: 57, s: 00, f: 00), at: ._23_976)
        )
        XCTAssertEqual(sessionInfo.main.frameRate,         ._23_976)
        XCTAssertEqual(sessionInfo.main.audioTrackCount,   2)
        XCTAssertEqual(sessionInfo.main.audioClipCount,    0)
        XCTAssertEqual(sessionInfo.main.audioFileCount,    0)
        
        // files - online
        
        XCTAssertEqual(sessionInfo.onlineFiles, [])
        
        // files - offline
        
        XCTAssertEqual(sessionInfo.offlineFiles, [])
        
        // clips - online
        
        XCTAssertNil(sessionInfo.onlineClips)  // empty
        
        // clips - offline
        
        XCTAssertNil(sessionInfo.offlineClips) // empty
        
        // plug-ins
        
        XCTAssertNil(sessionInfo.plugins)      // empty
        
        // tracks
        
        let tracks = try XCTUnwrap(sessionInfo.tracks)
        XCTAssertEqual(tracks.count, 2)
        
        let track1 = try XCTUnwrap(tracks[safe: 0])
        XCTAssertEqual(track1.name, "Audio A")
        XCTAssertEqual(track1.comments, "")
        XCTAssertEqual(track1.userDelay, 0)
        XCTAssertEqual(track1.state, [])
        XCTAssertEqual(track1.plugins, [])
        XCTAssertEqual(track1.clips, [
            .init(
                channel: 1,
                event: 1,
                name: "Audio Clip 1 Name",
                startTime: .barsAndBeats(bar: 13, beat: 3, ticks: nil),
                endTime: .barsAndBeats(bar: 20, beat: 1, ticks: nil),
                duration: .barsAndBeats(bar: 6, beat: 2, ticks: 720),
                state: .unmuted
            )
        ])
        
        let track2 = try XCTUnwrap(tracks[safe: 1])
        XCTAssertEqual(track2.name, "Audio B")
        XCTAssertEqual(track2.comments, "")
        XCTAssertEqual(track2.userDelay, 0)
        XCTAssertEqual(track2.state, [])
        XCTAssertEqual(track2.plugins, [])
        XCTAssertEqual(track2.clips, [
            .init(
                channel: 1,
                event: 1,
                name: "Audio Clip 2 Name",
                startTime: .barsAndBeats(bar: 5, beat: 1, ticks: nil),
                endTime: .barsAndBeats(bar: 11, beat: 4, ticks: nil),
                duration: .barsAndBeats(bar: 6, beat: 2, ticks: 720),
                state: .unmuted
            )
        ])
        
        // markers
        
        let markers = try XCTUnwrap(sessionInfo.markers)
        XCTAssertEqual(markers.count, 2)
        
        // orphan data
        
        XCTAssertNil(sessionInfo.orphanData)   // empty
    }
}
