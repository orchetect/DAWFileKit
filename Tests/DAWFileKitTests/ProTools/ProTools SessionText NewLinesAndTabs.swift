//
//  ProTools SessionText NewLinesAndTabs.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import XCTest
@testable import DAWFileKit
import SwiftExtensions
import TimecodeKitCore

class ProTools_SessionText_NewLinesAndTabs: XCTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    func testSessionText_NewLinesAndTabs() throws {
        // load file
        
        let filename = "SessionText_NewLinesAndTabs_DefaultExportOptions_PT2023.6"
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
        
        XCTAssertEqual(sessionInfo.main.name,              "SessionText_NewLinesAndTabs")
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
        
        let markers = try XCTUnwrap(sessionInfo.markers)
        
        XCTAssertEqual(markers.count,              12)
        
        let marker1 = markers[0]
        XCTAssertEqual(marker1.number,             1)
        XCTAssertEqual(
            marker1.location,
            .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 00, f: 00), at: .fps23_976))
        )
        XCTAssertEqual(marker1.timeReference,      .samples(240240))
        XCTAssertEqual(marker1.name,               "Marker Name\nWith New Line")
        XCTAssertEqual(marker1.comment,            nil)
        
        let marker2 = markers[1]
        XCTAssertEqual(marker2.number,             2)
        XCTAssertEqual(
            marker2.location,
            .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 01, f: 00), at: .fps23_976))
        )
        XCTAssertEqual(marker2.timeReference,      .samples(288288))
        XCTAssertEqual(marker2.name,               "Normal Marker Name")
        XCTAssertEqual(marker2.comment,            "Comment Here\nWith New Line")
        
        let marker3 = markers[2]
        XCTAssertEqual(marker3.number,             3)
        XCTAssertEqual(
            marker3.location,
            .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 02, f: 00), at: .fps23_976))
        )
        XCTAssertEqual(marker3.timeReference,      .samples(336336))
        XCTAssertEqual(marker3.name,               "Marker Name Again\nWith New Line Again")
        XCTAssertEqual(marker3.comment,            "Comment Here Again\nWith New Line Again")
        
        let marker4 = markers[3]
        XCTAssertEqual(marker4.number,             4)
        XCTAssertEqual(
            marker4.location,
            .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 03, f: 00), at: .fps23_976))
        )
        XCTAssertEqual(marker4.timeReference,      .samples(384384))
        XCTAssertEqual(marker4.name,               "Normal Marker Name Again")
        XCTAssertEqual(marker4.comment,            nil)
        
        let marker5 = markers[4]
        XCTAssertEqual(marker5.number,             5)
        XCTAssertEqual(
            marker5.location,
            .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 04, f: 00), at: .fps23_976))
        )
        XCTAssertEqual(marker5.timeReference,      .samples(432432))
        XCTExpectFailure("No reasonable way to parse tabs in this manner.") // ⚠️
        XCTAssertEqual(marker5.name,               "Marker Name\tWith Tab")
        XCTExpectFailure("No reasonable way to parse tabs in this manner.") // ⚠️
        XCTAssertEqual(marker5.comment,            nil)
        
        let marker6 = markers[5]
        XCTAssertEqual(marker6.number,             6)
        XCTAssertEqual(
            marker6.location,
            .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 05, f: 00), at: .fps23_976))
        )
        XCTAssertEqual(marker6.timeReference,      .samples(480480))
        XCTAssertEqual(marker6.name,               "Normal Marker Name")
        XCTAssertEqual(marker6.comment,            "Comments Here\tWith Tab")
        
        let marker7 = markers[6]
        XCTAssertEqual(marker7.number,             7)
        XCTAssertEqual(
            marker7.location,
            .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 06, f: 00), at: .fps23_976))
        )
        XCTAssertEqual(marker7.timeReference,      .samples(528528))
        XCTExpectFailure("No reasonable way to parse tabs in this manner.") // ⚠️
        XCTAssertEqual(marker7.name,               "Marker Name\tWith Tab")
        XCTExpectFailure("No reasonable way to parse tabs in this manner.") // ⚠️
        XCTAssertEqual(marker7.comment,            "Comments Here\tWith Tab")
        
        let marker8 = markers[7]
        XCTAssertEqual(marker8.number,             8)
        XCTAssertEqual(
            marker8.location,
            .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 07, f: 00), at: .fps23_976))
        )
        XCTAssertEqual(marker8.timeReference,      .samples(576576))
        XCTExpectFailure("No reasonable way to parse tabs in this manner.") // ⚠️
        XCTAssertEqual(marker8.name,               "Marker Name\tWith Tab\tAnd Another Tab")
        XCTExpectFailure("No reasonable way to parse tabs in this manner.") // ⚠️
        XCTAssertEqual(marker8.comment,            nil)
        
        let marker9 = markers[8]
        XCTAssertEqual(marker9.number,             9)
        XCTAssertEqual(
            marker9.location,
            .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 08, f: 00), at: .fps23_976))
        )
        XCTAssertEqual(marker9.timeReference,      .samples(624624))
        XCTAssertEqual(marker9.name,               "Normal Marker Name")
        XCTAssertEqual(marker9.comment,            "Comment Here\tWith Tab\tAnd Another Tab")
        
        let marker10 = markers[9]
        XCTAssertEqual(marker10.number,            10)
        XCTAssertEqual(
            marker10.location,
            .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 09, f: 00), at: .fps23_976))
        )
        XCTAssertEqual(marker10.timeReference,     .samples(672672))
        XCTExpectFailure("No reasonable way to parse tabs in this manner.") // ⚠️
        XCTAssertEqual(marker10.name,              "Marker Name\tWith Tab\tAnd Another Tab")
        XCTExpectFailure("No reasonable way to parse tabs in this manner.") // ⚠️
        XCTAssertEqual(marker10.comment,           "Comment Here\tWith Tab\tAnd Another Tab")
        
        let marker11 = markers[10]
        XCTAssertEqual(marker11.number,            11)
        XCTAssertEqual(
            marker11.location,
            .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 10, f: 00), at: .fps23_976))
        )
        XCTAssertEqual(marker11.timeReference,     .samples(720720))
        XCTExpectFailure("No reasonable way to parse tabs in this manner.") // ⚠️
        XCTAssertEqual(marker11.name,              "Marker Name\tWith Tab\nAnd Newline")
        XCTExpectFailure("No reasonable way to parse tabs in this manner.") // ⚠️
        XCTAssertEqual(marker11.comment,           nil)
        
        let marker12 = markers[11]
        XCTAssertEqual(marker12.number,            12)
        XCTAssertEqual(
            marker12.location,
            .timecode(try ProTools.formTimecode(.init(h: 01, m: 00, s: 11, f: 00), at: .fps23_976))
        )
        XCTAssertEqual(marker12.timeReference,     .samples(768768))
        XCTExpectFailure("No reasonable way to parse tabs in this manner.") // ⚠️
        XCTAssertEqual(marker12.name,              "Normal Marker Name")
        XCTExpectFailure("No reasonable way to parse tabs in this manner.") // ⚠️
        XCTAssertEqual(marker12.comment,           "Comment Here\tWith Tab\nAnd Newline")
        
        // orphan data
        
        XCTAssertNil(sessionInfo.orphanData) // none
    }
}
