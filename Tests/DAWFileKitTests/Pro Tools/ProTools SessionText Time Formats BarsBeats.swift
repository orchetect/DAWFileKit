//
//  ProTools SessionText Time Formats BarsBeats.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import XCTest
@testable import DAWFileKit
import OTCore
import TimecodeKit

class ProTools_SessionText_TimeFormats: XCTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    func testSessionText_BarsBeats() throws {
        try runSessionText(
            filename: "SessionText_TimeFormats_BarsBeats_PT2022.9",
            
            track1ClipStartTime: .barsAndBeats(bar: 13, beat: 3, ticks: nil),
            track1ClipEndTime:   .barsAndBeats(bar: 20, beat: 1, ticks: nil),
            track1ClipDuration:  .barsAndBeats(bar: 6, beat: 2, ticks: 720),
            
            track2ClipStartTime: .barsAndBeats(bar: 5, beat: 1, ticks: nil),
            track2ClipEndTime:   .barsAndBeats(bar: 11, beat: 4, ticks: nil),
            track2ClipDuration:  .barsAndBeats(bar: 6, beat: 2, ticks: 720),
            
            marker1Location:     .barsAndBeats(bar: 29, beat: 1, ticks: nil),
            marker1TimeRef:      .samples(2_695_168),
            
            marker2Location:     .barsAndBeats(bar: 58, beat: 4, ticks: nil),
            marker2TimeRef:      .barsAndBeats(bar: 58, beat: 4, ticks: nil)
        )
    }
    
    func testSessionText_BarsBeats_ShowSubframes() throws {
        try runSessionText(
            filename: "SessionText_TimeFormats_BarsBeats_ShowSubframes_PT2022.9",
            
            track1ClipStartTime: .barsAndBeats(bar: 13, beat: 3, ticks: 48),
            track1ClipEndTime:   .barsAndBeats(bar: 20, beat: 1, ticks: 768),
            track1ClipDuration:  .barsAndBeats(bar: 6, beat: 2, ticks: 720),
            
            track2ClipStartTime: .barsAndBeats(bar: 5, beat: 1, ticks: 696),
            track2ClipEndTime:   .barsAndBeats(bar: 11, beat: 4, ticks: 456),
            track2ClipDuration:  .barsAndBeats(bar: 6, beat: 2, ticks: 720),
            
            marker1Location:     .barsAndBeats(bar: 29, beat: 1, ticks: 287),
            marker1TimeRef:      .samples(2_695_168),
            
            marker2Location:     .barsAndBeats(bar: 58, beat: 4, ticks: 735),
            marker2TimeRef:      .barsAndBeats(bar: 58, beat: 4, ticks: 735)
        )
    }
    
    func testSessionText_FeetFrames() throws {
        try runSessionText(
            filename: "SessionText_TimeFormats_FeetFrames_PT2022.9",
            
            track1ClipStartTime: .feetAndFrames(feet: 37, frames: 8, subFrames: nil),
            track1ClipEndTime:   .feetAndFrames(feet: 57, frames: 9, subFrames: nil),
            track1ClipDuration:  .feetAndFrames(feet: 20, frames: 1, subFrames: nil),
            
            track2ClipStartTime: .feetAndFrames(feet: 12, frames: 8, subFrames: nil),
            track2ClipEndTime:   .feetAndFrames(feet: 32, frames: 9, subFrames: nil),
            track2ClipDuration:  .feetAndFrames(feet: 20, frames: 1, subFrames: nil),
            
            marker1Location:     .feetAndFrames(feet: 84, frames: 3, subFrames: nil),
            marker1TimeRef:      .samples(2_695_168),
            
            marker2Location:     .feetAndFrames(feet: 173, frames: 13, subFrames: nil),
            marker2TimeRef:      .barsAndBeats(bar: 58, beat: 4, ticks: nil)
        )
    }
    
    func testSessionText_FeetFrames_ShowSubframes() throws {
        try runSessionText(
            filename: "SessionText_TimeFormats_FeetFrames_ShowSubframes_PT2022.9",
            
            track1ClipStartTime: .feetAndFrames(feet: 37, frames: 8, subFrames: 60),
            track1ClipEndTime:   .feetAndFrames(feet: 57, frames: 9, subFrames: 60),
            track1ClipDuration:  .feetAndFrames(feet: 20, frames: 1, subFrames: 00),
            
            track2ClipStartTime: .feetAndFrames(feet: 12, frames: 8, subFrames: 70),
            track2ClipEndTime:   .feetAndFrames(feet: 32, frames: 9, subFrames: 70),
            track2ClipDuration:  .feetAndFrames(feet: 20, frames: 1, subFrames: 00),
            
            marker1Location:     .feetAndFrames(feet: 84, frames: 3, subFrames: 58),
            marker1TimeRef:      .samples(2_695_168),
            
            marker2Location:     .feetAndFrames(feet: 173, frames: 13, subFrames: 18),
            marker2TimeRef:      .barsAndBeats(bar: 58, beat: 4, ticks: 735)
        )
    }
    
    func testSessionText_MinSecs() throws {
        try runSessionText(
            filename: "SessionText_TimeFormats_MinSecs_PT2022.9",
            
            track1ClipStartTime: .minSecs(min: 0, sec: 25, ms: nil),
            track1ClipEndTime:   .minSecs(min: 0, sec: 38, ms: nil),
            track1ClipDuration:  .minSecs(min: 0, sec: 13, ms: nil),
            
            track2ClipStartTime: .minSecs(min: 0, sec: 08, ms: nil),
            track2ClipEndTime:   .minSecs(min: 0, sec: 21, ms: nil),
            track2ClipDuration:  .minSecs(min: 0, sec: 13, ms: nil),
            
            marker1Location:     .minSecs(min: 0, sec: 56, ms: nil),
            marker1TimeRef:      .samples(2_695_168),
            
            marker2Location:     .minSecs(min: 1, sec: 55, ms: nil),
            marker2TimeRef:      .barsAndBeats(bar: 58, beat: 4, ticks: nil)
        )
    }
    
    func testSessionText_MinSecs_ShowSubframes() throws {
        try runSessionText(
            filename: "SessionText_TimeFormats_MinSecs_ShowSubframes_PT2022.9",
            
            track1ClipStartTime: .minSecs(min: 0, sec: 25, ms: 025),
            track1ClipEndTime:   .minSecs(min: 0, sec: 38, ms: 400),
            track1ClipDuration:  .minSecs(min: 0, sec: 13, ms: 375),
            
            track2ClipStartTime: .minSecs(min: 0, sec: 08, ms: 362),
            track2ClipEndTime:   .minSecs(min: 0, sec: 21, ms: 737),
            track2ClipDuration:  .minSecs(min: 0, sec: 13, ms: 375),
            
            marker1Location:     .minSecs(min: 0, sec: 56, ms: 149),
            marker1TimeRef:      .samples(2_695_168),
            
            marker2Location:     .minSecs(min: 1, sec: 55, ms: 882),
            marker2TimeRef:      .barsAndBeats(bar: 58, beat: 4, ticks: 735)
        )
    }
    
    func testSessionText_Samples() throws {
        try runSessionText(
            filename: "SessionText_TimeFormats_Samples_PT2022.9",
            
            track1ClipStartTime: .samples(1_201_200),
            track1ClipEndTime:   .samples(1_843_200),
            track1ClipDuration:  .samples(642_000),
            
            track2ClipStartTime: .samples(401_408),
            track2ClipEndTime:   .samples(1_043_408),
            track2ClipDuration:  .samples(642_000),
            
            marker1Location:     .samples(2_695_168),
            marker1TimeRef:      .samples(2_695_168),
            
            marker2Location:     .samples(5_562_368),
            marker2TimeRef:      .barsAndBeats(bar: 58, beat: 4, ticks: nil)
        )
    }
    
    func testSessionText_Samples_ShowSubframes() throws {
        try runSessionText(
            filename: "SessionText_TimeFormats_Samples_ShowSubframes_PT2022.9",
            
            track1ClipStartTime: .samples(1_201_200),
            track1ClipEndTime:   .samples(1_843_200),
            track1ClipDuration:  .samples(642_000),
            
            track2ClipStartTime: .samples(401_408),
            track2ClipEndTime:   .samples(1_043_408),
            track2ClipDuration:  .samples(642_000),
            
            marker1Location:     .samples(2_695_168),
            marker1TimeRef:      .samples(2_695_168),
            
            marker2Location:     .samples(5_562_368),
            marker2TimeRef:      .barsAndBeats(bar: 58, beat: 4, ticks: 735)
        )
    }
    
    func testSessionText_Timecode() throws {
        func TC(_ tcc: TCC) -> Timecode {
            try! ProTools.formTimecode(tcc, at: ._23_976)
        }
        try runSessionText(
            filename: "SessionText_TimeFormats_Timecode_PT2022.9",
            
            track1ClipStartTime: .timecode(TC(TCC(h: 23, m: 57, s: 25, f: 00))),
            track1ClipEndTime:   .timecode(TC(TCC(h: 23, m: 57, s: 38, f: 08))),
            track1ClipDuration:  .timecode(TC(TCC(h: 00, m: 00, s: 13, f: 08))),
            
            track2ClipStartTime: .timecode(TC(TCC(h: 23, m: 57, s: 08, f: 08))),
            track2ClipEndTime:   .timecode(TC(TCC(h: 23, m: 57, s: 21, f: 17))),
            track2ClipDuration:  .timecode(TC(TCC(h: 00, m: 00, s: 13, f: 08))),
            
            marker1Location:     .timecode(TC(TCC(h: 23, m: 57, s: 56, f: 02))),
            marker1TimeRef:      .samples(2_695_168),
            
            marker2Location:     .timecode(TC(TCC(h: 23, m: 58, s: 55, f: 18))),
            marker2TimeRef:      .barsAndBeats(bar: 58, beat: 4, ticks: nil)
        )
    }
    
    func testSessionText_Timecode_ShowSubframes() throws {
        func TC(_ tcc: TCC) -> Timecode {
            try! ProTools.formTimecode(tcc, at: ._23_976)
        }
        try runSessionText(
            filename: "SessionText_TimeFormats_Timecode_ShowSubframes_PT2022.9",
            
            track1ClipStartTime: .timecode(TC(TCC(h: 23, m: 57, s: 25, f: 00, sf: 00))),
            track1ClipEndTime:   .timecode(TC(TCC(h: 23, m: 57, s: 38, f: 08, sf: 68))),
            track1ClipDuration:  .timecode(TC(TCC(h: 00, m: 00, s: 13, f: 08, sf: 68))),
            
            track2ClipStartTime: .timecode(TC(TCC(h: 23, m: 57, s: 08, f: 08, sf: 50))),
            track2ClipEndTime:   .timecode(TC(TCC(h: 23, m: 57, s: 21, f: 17, sf: 18))),
            track2ClipDuration:  .timecode(TC(TCC(h: 00, m: 00, s: 13, f: 08, sf: 68))),
            
            marker1Location:     .timecode(TC(TCC(h: 23, m: 57, s: 56, f: 02, sf: 24))),
            marker1TimeRef:      .samples(2_695_168),
            
            marker2Location:     .timecode(TC(TCC(h: 23, m: 58, s: 55, f: 18, sf: 41))),
            marker2TimeRef:      .barsAndBeats(bar: 58, beat: 4, ticks: 735)
        )
    }
    
    // MARK: - Common Test Body
    
    func runSessionText(
        filename: String,
        track1ClipStartTime: ProTools.SessionInfo.TimeValue,
        track1ClipEndTime: ProTools.SessionInfo.TimeValue,
        track1ClipDuration: ProTools.SessionInfo.TimeValue?,
        track2ClipStartTime: ProTools.SessionInfo.TimeValue,
        track2ClipEndTime: ProTools.SessionInfo.TimeValue,
        track2ClipDuration: ProTools.SessionInfo.TimeValue?,
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
        let sessionInfo = try ProTools.SessionInfo(fileContent: rawData, messages: &parseMessages)
        
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
        XCTAssertEqual(track1.clips, [
            .init(
                channel: 1,
                event: 1,
                name: "Audio Clip 1 Name",
                startTime: track1ClipStartTime,
                endTime: track1ClipEndTime,
                duration: track1ClipDuration,
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
                startTime: track2ClipStartTime,
                endTime: track2ClipEndTime,
                duration: track2ClipDuration,
                state: .unmuted
            )
        ])
        
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
