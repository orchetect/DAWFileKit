//
//  ProTools SessionText OneOfEverything.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import XCTest
@testable import DAWFileKit
import SwiftExtensions
import TimecodeKitCore

class ProTools_SessionText_OneOfEverything: XCTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    func testSessionText_OneOfEverything() throws {
        // load file
        
        let filename = "SessionText_OneOfEverything_23-976fps_DefaultExportOptions_PT2020.3"
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
        
        XCTAssertEqual(sessionInfo.main.name,            "SessionText_OneOfEverything")
        XCTAssertEqual(sessionInfo.main.sampleRate,      48000.0)
        XCTAssertEqual(sessionInfo.main.bitDepth,        "24-bit")
        XCTAssertEqual(
            sessionInfo.main.startTimecode,
            try ProTools.formTimecode(.init(h: 0, m: 59, s: 55, f: 00), at: .fps23_976)
        )
        XCTAssertEqual(sessionInfo.main.frameRate,       .fps23_976)
        XCTAssertEqual(sessionInfo.main.audioTrackCount, 5)
        XCTAssertEqual(sessionInfo.main.audioClipCount,  11)
        XCTAssertEqual(sessionInfo.main.audioFileCount,  7)
        
        // files - online
        
        let onlineAudioFilesPath =
            "Macintosh HD:Users:stef:Dropbox:coding:XCode Projects:Shared:DAWFileKit:_Materials:SessionText_OneOfEverything:Audio Files:"
        
        let onlineFiles = try XCTUnwrap(sessionInfo.onlineFiles)
        XCTAssertEqual(onlineFiles.count, 6)
        
        let file1 = onlineFiles[0]
        
        XCTAssertEqual(file1.filename, "Unused Clip.wav")
        XCTAssertEqual(file1.path,     onlineAudioFilesPath)
        
        let file2 = onlineFiles[1]
        
        XCTAssertEqual(file2.filename, "Audio 1 Clip1.wav")
        XCTAssertEqual(file2.path,     onlineAudioFilesPath)
        
        let file3 = onlineFiles[2]
        
        XCTAssertEqual(file3.filename, "Audio 2 Clip1.wav")
        XCTAssertEqual(file3.path,     onlineAudioFilesPath)
        
        let file4 = onlineFiles[3]
        
        XCTAssertEqual(file4.filename, "Audio 3 Clip1.wav")
        XCTAssertEqual(file4.path,     onlineAudioFilesPath)
        
        let file5 = onlineFiles[4]
        
        XCTAssertEqual(file5.filename, "Audio 3 Clip2.wav")
        XCTAssertEqual(file5.path,     onlineAudioFilesPath)
        
        let file6 = onlineFiles[5]
        
        XCTAssertEqual(file6.filename, "Audio 4 Clip1.wav")
        XCTAssertEqual(file6.path,     onlineAudioFilesPath)
        
        // files - offline
        
        let offlineFiles = try XCTUnwrap(sessionInfo.offlineFiles)
        XCTAssertEqual(offlineFiles.count, 1)
        
        let file7 = offlineFiles[0]
        
        XCTAssertEqual(file7.filename, "Audio 5 Offline Clip1.wav")
        XCTAssertEqual(
            file7.path,
            "Macintosh HD:Users:stef:Desktop:SessionText_PT2020.3:Audio Files:"
        )
        
        // clips - online
        
        let onlineClips = try XCTUnwrap(sessionInfo.onlineClips)
        
        XCTAssertEqual(onlineClips.count, 9)
        
        XCTAssertEqual(onlineClips[0].name,       "Audio 1 Clip1")
        XCTAssertEqual(onlineClips[0].sourceFile, "Audio 1 Clip1.wav")
        XCTAssertEqual(onlineClips[0].channel,    nil)
        
        XCTAssertEqual(onlineClips[1].name,       "Audio 2 Clip1")
        XCTAssertEqual(onlineClips[1].sourceFile, "Audio 2 Clip1.wav")
        XCTAssertEqual(onlineClips[1].channel,    nil)
        
        XCTAssertEqual(onlineClips[2].name,       "Audio 3 Clip1.L")
        XCTAssertEqual(onlineClips[2].sourceFile, "Audio 3 Clip1.wav")
        XCTAssertEqual(onlineClips[2].channel,    "[1]")
        
        XCTAssertEqual(onlineClips[3].name,       "Audio 3 Clip1.R")
        XCTAssertEqual(onlineClips[3].sourceFile, "Audio 3 Clip1.wav")
        XCTAssertEqual(onlineClips[3].channel,    "[2]")
        
        XCTAssertEqual(onlineClips[4].name,       "Audio 3 Clip2.L")
        XCTAssertEqual(onlineClips[4].sourceFile, "Audio 3 Clip2.wav")
        XCTAssertEqual(onlineClips[4].channel,    "[1]")
        
        XCTAssertEqual(onlineClips[5].name,       "Audio 3 Clip2.R")
        XCTAssertEqual(onlineClips[5].sourceFile, "Audio 3 Clip2.wav")
        XCTAssertEqual(onlineClips[5].channel,    "[2]")
        
        XCTAssertEqual(onlineClips[6].name,       "Audio 4 Clip1.L")
        XCTAssertEqual(onlineClips[6].sourceFile, "Audio 4 Clip1.wav")
        XCTAssertEqual(onlineClips[6].channel,    "[1]")
        
        XCTAssertEqual(onlineClips[7].name,       "Audio 4 Clip1.R")
        XCTAssertEqual(onlineClips[7].sourceFile, "Audio 4 Clip1.wav")
        XCTAssertEqual(onlineClips[7].channel,    "[2]")
        
        XCTAssertEqual(onlineClips[8].name,       "Unused Clip")
        XCTAssertEqual(onlineClips[8].sourceFile, "Unused Clip.wav")
        XCTAssertEqual(onlineClips[8].channel,    nil)
        
        // clips - offline
        
        let offlineClips = try XCTUnwrap(sessionInfo.offlineClips)
        
        XCTAssertEqual(offlineClips.count, 2)
        
        XCTAssertEqual(offlineClips[0].name,       "Audio 5 Offline Clip1.L")
        XCTAssertEqual(offlineClips[0].sourceFile, "Audio 5 Offline Clip1.wav")
        XCTAssertEqual(offlineClips[0].channel,    "[1]")
        
        XCTAssertEqual(offlineClips[1].name,       "Audio 5 Offline Clip1.R")
        XCTAssertEqual(offlineClips[1].sourceFile, "Audio 5 Offline Clip1.wav")
        XCTAssertEqual(offlineClips[1].channel,    "[2]")
        
        // plug-ins
        
        let plugins = try XCTUnwrap(sessionInfo.plugins)
        
        XCTAssertEqual(plugins.count, 3)
        
        XCTAssertEqual(plugins[0].manufacturer,      "Avid")
        XCTAssertEqual(plugins[0].name,              "EQ3 1-Band")
        XCTAssertEqual(plugins[0].version,           "20.3.0d163")
        XCTAssertEqual(plugins[0].format,            "AAX Native")
        XCTAssertEqual(plugins[0].stems,             "Mono / Mono")
        XCTAssertEqual(plugins[0].numberOfInstances, "2 active")
        
        XCTAssertEqual(plugins[1].manufacturer,      "Avid")
        XCTAssertEqual(plugins[1].name,              "EQ3 7-Band")
        XCTAssertEqual(plugins[1].version,           "20.3.0d163")
        XCTAssertEqual(plugins[1].format,            "AAX Native")
        XCTAssertEqual(plugins[1].stems,             "Mono / Mono")
        XCTAssertEqual(plugins[1].numberOfInstances, "1 active")
        
        XCTAssertEqual(plugins[2].manufacturer,      "Avid")
        XCTAssertEqual(plugins[2].name,              "Trim")
        XCTAssertEqual(plugins[2].version,           "20.3.0d163")
        XCTAssertEqual(plugins[2].format,            "AAX Native")
        XCTAssertEqual(plugins[2].stems,             "Mono / Mono")
        XCTAssertEqual(plugins[2].numberOfInstances, "1 active")
        
        // tracks
        
        let tracks = try XCTUnwrap(sessionInfo.tracks)
        
        XCTAssertEqual(tracks.count, 5)
        
        let track1 = tracks[0]
        
        XCTAssertEqual(track1.name,                "Audio 1")
        XCTAssertEqual(track1.comments,            "Comments here.")
        XCTAssertEqual(track1.userDelay,           0)
        XCTAssertEqual(track1.state,               [])
        XCTAssertEqual(track1.plugins,             ["EQ3 1-Band (mono)"])
        
        XCTAssertEqual(track1.clips.count,         1)
        
        let track1clip1 = track1.clips[0]
        XCTAssertEqual(track1clip1.channel,        1)
        XCTAssertEqual(track1clip1.event,          1)
        XCTAssertEqual(track1clip1.name,           "Audio 1 Clip1")
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
        XCTAssertEqual(track1clip1.state,          .unmuted)
        
        let track2 = tracks[1]
        
        XCTAssertEqual(track2.name,                "Audio 2")
        XCTAssertEqual(track2.comments,            "")
        XCTAssertEqual(track2.userDelay,           0)
        XCTAssertEqual(track2.state,               [])
        XCTAssertEqual(track2.plugins,             ["EQ3 7-Band (mono)", "Trim (mono)"])
        
        XCTAssertEqual(track2.clips.count,         1)
        
        let track2clip1 = track2.clips[0]
        XCTAssertEqual(track2clip1.channel,        1)
        XCTAssertEqual(track2clip1.event,          1)
        XCTAssertEqual(track2clip1.name,           "Audio 2 Clip1")
        XCTAssertEqual(
            track2clip1.startTime,
            .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 06, f: 15), at: .fps23_976))
        )
        XCTAssertEqual(
            track2clip1.endTime,
            .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 10, f: 03), at: .fps23_976))
        )
        XCTAssertEqual(
            track2clip1.duration,
            .timecode(try ProTools.formTimecode(.init(h: 00, m: 00, s: 03, f: 12), at: .fps23_976))
        )
        XCTAssertEqual(track2clip1.state,          .unmuted)
        
        let track3 = tracks[2]
        
        XCTAssertEqual(track3.name,                "Audio 3 (Stereo)")
        XCTAssertEqual(track3.comments,            "")
        XCTAssertEqual(track3.userDelay,           0)
        XCTAssertEqual(track3.state,               [])
        XCTAssertEqual(track3.plugins,             [])
        
        XCTAssertEqual(track3.clips.count,         4)
        
        let track3clip1 = track3.clips[0]
        XCTAssertEqual(track3clip1.channel,        1)
        XCTAssertEqual(track3clip1.event,          1)
        XCTAssertEqual(track3clip1.name,           "Audio 3 Clip1.L")
        XCTAssertEqual(
            track3clip1.startTime,
            .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 12, f: 18), at: .fps23_976))
        )
        XCTAssertEqual(
            track3clip1.endTime,
            .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 17, f: 08), at: .fps23_976))
        )
        XCTAssertEqual(
            track3clip1.duration,
            .timecode(try ProTools.formTimecode(.init(h: 00, m: 00, s: 04, f: 14), at: .fps23_976))
        )
        XCTAssertEqual(track3clip1.state,          .unmuted)
        
        let track3clip2 = track3.clips[1]
        XCTAssertEqual(track3clip2.channel,        1)
        XCTAssertEqual(track3clip2.event,          2)
        XCTAssertEqual(track3clip2.name,           "Audio 3 Clip2.L")
        XCTAssertEqual(
            track3clip2.startTime,
            .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 18, f: 17), at: .fps23_976))
        )
        XCTAssertEqual(
            track3clip2.endTime,
            .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 21, f: 19), at: .fps23_976))
        )
        XCTAssertEqual(
            track3clip2.duration,
            .timecode(try ProTools.formTimecode(.init(h: 00, m: 00, s: 03, f: 02), at: .fps23_976))
        )
        XCTAssertEqual(track3clip2.state,          .muted)
        
        let track3clip3 = track3.clips[2]
        XCTAssertEqual(track3clip3.channel,        2)
        XCTAssertEqual(track3clip3.event,          1)
        XCTAssertEqual(track3clip3.name,           "Audio 3 Clip1.R")
        XCTAssertEqual(
            track3clip3.startTime,
            .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 12, f: 18), at: .fps23_976))
        )
        XCTAssertEqual(
            track3clip3.endTime,
            .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 17, f: 08), at: .fps23_976))
        )
        XCTAssertEqual(
            track3clip3.duration,
            .timecode(try ProTools.formTimecode(.init(h: 00, m: 00, s: 04, f: 14), at: .fps23_976))
        )
        XCTAssertEqual(track3clip3.state,          .unmuted)
        
        let track3clip4 = track3.clips[3]
        XCTAssertEqual(track3clip4.channel,        2)
        XCTAssertEqual(track3clip4.event,          2)
        XCTAssertEqual(track3clip4.name,           "Audio 3 Clip2.R")
        XCTAssertEqual(
            track3clip4.startTime,
            .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 18, f: 17), at: .fps23_976))
        )
        XCTAssertEqual(
            track3clip4.endTime,
            .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 21, f: 19), at: .fps23_976))
        )
        XCTAssertEqual(
            track3clip4.duration,
            .timecode(try ProTools.formTimecode(.init(h: 00, m: 00, s: 03, f: 02), at: .fps23_976))
        )
        XCTAssertEqual(track3clip4.state,          .muted)
        
        let track4 = tracks[3]
        
        _ = track4
        // TODO: track 4 contains fades on a clip - may abstract in a certain way in the future
        
        let track5 = tracks[4]
        
        XCTAssertEqual(track5.name,                "Audio 5 (Stereo)")
        XCTAssertEqual(track5.comments,            "")
        XCTAssertEqual(track5.userDelay,           0)
        XCTAssertEqual(track5.state,               [.inactive])
        XCTAssertEqual(track5.plugins,             [])
        
        XCTAssertEqual(track5.clips.count,         2)
        
        let track5clip1 = track5.clips[0]
        XCTAssertEqual(track5clip1.channel,        1)
        XCTAssertEqual(track5clip1.event,          1)
        XCTAssertEqual(track5clip1.name,           "Audio 5 Offline Clip1.L")
        XCTAssertEqual(
            track5clip1.startTime,
            .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 05, f: 14), at: .fps23_976))
        )
        XCTAssertEqual(
            track5clip1.endTime,
            .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 11, f: 10), at: .fps23_976))
        )
        XCTAssertEqual(
            track5clip1.duration,
            .timecode(try ProTools.formTimecode(.init(h: 00, m: 00, s: 05, f: 20), at: .fps23_976))
        )
        XCTAssertEqual(track5clip1.state,          .unmuted)
        
        let track5clip2 = track5.clips[1]
        XCTAssertEqual(track5clip2.channel,        2)
        XCTAssertEqual(track5clip2.event,          1)
        XCTAssertEqual(track5clip2.name,           "Audio 5 Offline Clip1.R")
        XCTAssertEqual(
            track5clip2.startTime,
            .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 05, f: 14), at: .fps23_976))
        )
        XCTAssertEqual(
            track5clip2.endTime,
            .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 11, f: 10), at: .fps23_976))
        )
        XCTAssertEqual(
            track5clip2.duration,
            .timecode(try ProTools.formTimecode(.init(h: 00, m: 00, s: 05, f: 20), at: .fps23_976))
        )
        XCTAssertEqual(track5clip2.state,          .unmuted)
        
        // markers
        
        let markers = try XCTUnwrap(sessionInfo.markers)
        
        XCTAssertEqual(markers.count,              2)
        
        let marker1 = markers[0]
        XCTAssertEqual(marker1.number,             1)
        XCTAssertEqual(
            marker1.location,
            .timecode(try ProTools.formTimecode(.init(h: 00, m: 59, s: 58, f: 00), at: .fps23_976))
        )
        XCTAssertEqual(marker1.timeReference,      .samples(144_144))
        XCTAssertEqual(marker1.name,               "Marker 1")
        XCTAssertEqual(marker1.comment,            nil)
        XCTAssertEqual(marker1.trackName,          "Markers") // default for old txt format
        XCTAssertEqual(marker1.trackType,          .ruler) // will always be ruler for old txt format
        
        let marker2 = markers[1]
        XCTAssertEqual(marker2.number,             2)
        XCTAssertEqual(
            marker2.location,
            .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 00, f: 00), at: .fps23_976))
        )
        XCTAssertEqual(marker2.timeReference,      .barsAndBeats(bar: 3, beat: 3, ticks: nil))
        XCTAssertEqual(marker2.name,               "Marker 2")
        XCTAssertEqual(marker2.comment,            "This marker has comments.")
        XCTAssertEqual(marker2.trackName,          "Markers") // default for old txt format
        XCTAssertEqual(marker2.trackType,          .ruler) // will always be ruler for old txt format
        
        // orphan data
        
        XCTAssertNil(sessionInfo.orphanData)       // none
    }
}
