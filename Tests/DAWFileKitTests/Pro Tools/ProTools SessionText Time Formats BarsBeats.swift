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
        try runBarsBeats(
            filename: "SessionText_TimeFormats_BarsBeats_PT2022.9",
            track1Clips: [
                .init(
                    channel: 1,
                    event: 1,
                    name: "Audio Clip 1 Name",
                    startTime: .barsAndBeats(bar: 13, beat: 3, ticks: nil),
                    endTime: .barsAndBeats(bar: 20, beat: 1, ticks: nil),
                    duration: .barsAndBeats(bar: 6, beat: 2, ticks: 720),
                    state: .unmuted
                )
            ], track2Clips: [
                .init(
                    channel: 1,
                    event: 1,
                    name: "Audio Clip 2 Name",
                    startTime: .barsAndBeats(bar: 5, beat: 1, ticks: nil),
                    endTime: .barsAndBeats(bar: 11, beat: 4, ticks: nil),
                    duration: .barsAndBeats(bar: 6, beat: 2, ticks: 720),
                    state: .unmuted
                )
            ],
            marker1Location: .barsAndBeats(bar: 29, beat: 1, ticks: nil),
            marker1TimeRef: .samples(2695168),
            marker2Location: .barsAndBeats(bar: 58, beat: 4, ticks: nil),
            marker2TimeRef: .barsAndBeats(bar: 58, beat: 4, ticks: nil)
        )
    }
    
    func testSessionText_BarsBeats_ShowSubframes() throws {
        try runBarsBeats(
            filename: "SessionText_TimeFormats_BarsBeats_ShowSubframes_PT2022.9",
            track1Clips: [
                .init(
                    channel: 1,
                    event: 1,
                    name: "Audio Clip 1 Name",
                    startTime: .barsAndBeats(bar: 13, beat: 3, ticks: 48),
                    endTime: .barsAndBeats(bar: 20, beat: 1, ticks: 768),
                    duration: .barsAndBeats(bar: 6, beat: 2, ticks: 720),
                    state: .unmuted
                )
            ], track2Clips: [
                .init(
                    channel: 1,
                    event: 1,
                    name: "Audio Clip 2 Name",
                    startTime: .barsAndBeats(bar: 5, beat: 1, ticks: 696),
                    endTime: .barsAndBeats(bar: 11, beat: 4, ticks: 456),
                    duration: .barsAndBeats(bar: 6, beat: 2, ticks: 720),
                    state: .unmuted
                )
            ],
            marker1Location: .barsAndBeats(bar: 29, beat: 1, ticks: 287),
            marker1TimeRef: .samples(2695168),
            marker2Location: .barsAndBeats(bar: 58, beat: 4, ticks: 735),
            marker2TimeRef: .barsAndBeats(bar: 58, beat: 4, ticks: 735)
        )
    }
    
    func runBarsBeats(
        filename: String,
        track1Clips: [ProTools.SessionInfo.Track.Clip],
        track2Clips: [ProTools.SessionInfo.Track.Clip],
        marker1Location: ProTools.SessionInfo.TimeValue,
        marker1TimeRef: ProTools.SessionInfo.TimeValue,
        marker2Location: ProTools.SessionInfo.TimeValue,
        marker2TimeRef: ProTools.SessionInfo.TimeValue
    ) throws {
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
        
        XCTAssertEqual(sessionInfo.plugins, [])
        
        // tracks
        
        let tracks = try XCTUnwrap(sessionInfo.tracks)
        XCTAssertEqual(tracks.count, 2)
        
        let track1 = try XCTUnwrap(tracks[safe: 0])
        XCTAssertEqual(track1.name, "Audio A")
        XCTAssertEqual(track1.comments, "")
        XCTAssertEqual(track1.userDelay, 0)
        XCTAssertEqual(track1.state, [])
        XCTAssertEqual(track1.plugins, [])
        XCTAssertEqual(track1.clips, track1Clips)
        
        let track2 = try XCTUnwrap(tracks[safe: 1])
        XCTAssertEqual(track2.name, "Audio B")
        XCTAssertEqual(track2.comments, "")
        XCTAssertEqual(track2.userDelay, 0)
        XCTAssertEqual(track2.state, [])
        XCTAssertEqual(track2.plugins, [])
        XCTAssertEqual(track2.clips, track2Clips)
        
        // markers
        
        let markers = try XCTUnwrap(sessionInfo.markers)
        XCTAssertEqual(markers.count, 2)
        
        let marker1 = try XCTUnwrap(markers[safe: 0])
        XCTAssertEqual(marker1.number, 1)
        XCTAssertEqual(marker1.location, marker1Location)
        XCTAssertEqual(marker1.timeReference, marker1TimeRef)
        XCTAssertEqual(marker1.name, "Marker Absolute")
        XCTAssertEqual(marker1.comment, "Comment")
        
        let marker2 = try XCTUnwrap(markers[safe: 1])
        XCTAssertEqual(marker2.number, 2)
        XCTAssertEqual(marker2.location, marker2Location)
        XCTAssertEqual(marker2.timeReference, marker2TimeRef)
        XCTAssertEqual(marker2.name, "Marker Bars-Beats")
        XCTAssertEqual(marker2.comment, "Comment")
        
        // orphan data
        
        XCTAssertNil(sessionInfo.orphanData)   // empty
    }
}
