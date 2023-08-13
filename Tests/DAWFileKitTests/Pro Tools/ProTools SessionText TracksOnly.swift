//
//  ProTools SessionText TracksOnly.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import XCTest
@testable import DAWFileKit
import OTCore
import TimecodeKit

class ProTools_SessionText_TracksOnly: XCTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    func testSessionText_TracksOnly() throws {
        // load file
        
        let filename = "SessionText_TracksOnly_PT2023.6"
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
        
        XCTAssertEqual(sessionInfo.main.name,              "SessionText_TracksOnly")
        XCTAssertEqual(sessionInfo.main.sampleRate,        48000.0)
        XCTAssertEqual(sessionInfo.main.bitDepth,          "24-bit")
        XCTAssertEqual(
            sessionInfo.main.startTimecode,
            try ProTools.formTimecode(TCC(h: 0, m: 59, s: 50, f: 00), at: ._24)
        )
        XCTAssertEqual(sessionInfo.main.frameRate,         ._24)
        XCTAssertEqual(sessionInfo.main.audioTrackCount,   163)
        XCTAssertEqual(sessionInfo.main.audioClipCount,    1541)
        XCTAssertEqual(sessionInfo.main.audioFileCount,    247)
        
        // files - online
        
        XCTAssertNil(sessionInfo.onlineFiles) // missing section
        
        // files - offline
        
        XCTAssertNil(sessionInfo.offlineFiles) // missing section
        
        // clips - online
        
        XCTAssertNil(sessionInfo.onlineClips) // missing section
        
        // clips - offline
        
        XCTAssertNil(sessionInfo.offlineClips) // missing section
        
        // plug-ins
        
        XCTAssertNil(sessionInfo.plugins) // missing section
        
        // tracks
        
        let tracks = try XCTUnwrap(sessionInfo.tracks)
        XCTAssertEqual(tracks.count, 7)
        
        let track1 = try XCTUnwrap(tracks[safe: 0])
        XCTAssertEqual(track1.name,               "Audio 1")
        XCTAssertEqual(track1.comments,           "")
        XCTAssertEqual(track1.userDelay,          0)
        XCTAssertEqual(track1.state,              [])
        XCTAssertEqual(track1.plugins,            [])
        
        XCTAssertEqual(track1.clips.count,        2)
        
        // -- track 1 clip 1
        let track1clip1 = try XCTUnwrap(track1.clips[safe: 0])
        XCTAssertEqual(track1clip1.channel,       1)
        XCTAssertEqual(track1clip1.event,         1)
        XCTAssertEqual(track1clip1.name,          "Warm Day in the City")
        XCTAssertEqual(
            track1clip1.startTime,
            .timecode(try ProTools.formTimecode(TCC(h: 01, m: 00, s: 15, f: 06), at: ._24))
        )
        XCTAssertEqual(
            track1clip1.endTime,
            .timecode(try ProTools.formTimecode(TCC(h: 01, m: 01, s: 05, f: 13), at: ._24))
        )
        XCTAssertEqual(
            track1clip1.duration,
            .timecode(try ProTools.formTimecode(TCC(h: 00, m: 00, s: 50, f: 07), at: ._24))
        )
        XCTAssertEqual(track1clip1.state,         .unmuted)
        
        // -- track 1 clip 2
        let track1clip2 = try XCTUnwrap(track1.clips[safe: 1])
        XCTAssertEqual(track1clip2.channel,       1)
        XCTAssertEqual(track1clip2.event,         2)
        XCTAssertEqual(track1clip2.name,          "Happy Go Lucky")
        XCTAssertEqual(
            track1clip2.startTime,
            .timecode(try ProTools.formTimecode(TCC(h: 01, m: 01, s: 05, f: 13), at: ._24))
        )
        XCTAssertEqual(
            track1clip2.endTime,
            .timecode(try ProTools.formTimecode(TCC(h: 01, m: 01, s: 57, f: 23), at: ._24))
        )
        XCTAssertEqual(
            track1clip2.duration,
            .timecode(try ProTools.formTimecode(TCC(h: 00, m: 00, s: 52, f: 09), at: ._24))
        )
        XCTAssertEqual(track1clip2.state,         .unmuted)
        
        let track2 = try XCTUnwrap(tracks[safe: 1])
        XCTAssertEqual(track2.name,               "Audio 2")
        XCTAssertEqual(track2.clips.count,        0)
        
        let track3 = try XCTUnwrap(tracks[safe: 2])
        XCTAssertEqual(track3.name,               "Audio 3")
        XCTAssertEqual(track3.clips.count,        0)
        
        let track4 = try XCTUnwrap(tracks[safe: 3])
        XCTAssertEqual(track4.name,               "Audio 4")
        XCTAssertEqual(track4.clips.count,        0)
        
        let track5 = try XCTUnwrap(tracks[safe: 4])
        XCTAssertEqual(track5.name,               "Audio 5")
        XCTAssertEqual(track5.clips.count,        0)
        
        let track6 = try XCTUnwrap(tracks[safe: 5])
        XCTAssertEqual(track6.name,               "Audio 6")
        XCTAssertEqual(track6.clips.count,        0)
        
        let track7 = try XCTUnwrap(tracks[safe: 6])
        XCTAssertEqual(track7.name,               "Audio 7")
        XCTAssertEqual(track7.clips.count,        0)
        
        // markers
        
        XCTAssertNil(sessionInfo.markers) // missing section
        
        // orphan data
        
        XCTAssertNil(sessionInfo.orphanData) // none
    }
}
