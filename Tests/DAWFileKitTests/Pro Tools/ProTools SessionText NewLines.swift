//
//  ProTools SessionText NewLines.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import XCTest
@testable import DAWFileKit
import OTCore
import TimecodeKit

class ProTools_SessionText_NewLines: XCTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    func testSessionText_TracksOnly() throws {
        // load file
        
        let filename = "SessionText_NewLines_DefaultExportOptions_PT2023.6"
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
        
        XCTAssertEqual(sessionInfo.main.name,              "SessionText_NewLines")
        XCTAssertEqual(sessionInfo.main.sampleRate,        48000.0)
        XCTAssertEqual(sessionInfo.main.bitDepth,          "24-bit")
        XCTAssertEqual(
            sessionInfo.main.startTimecode,
            try ProTools.formTimecode(TCC(h: 0, m: 59, s: 55, f: 00), at: ._23_976)
        )
        XCTAssertEqual(sessionInfo.main.frameRate,         ._23_976)
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
        
        XCTAssertEqual(markers.count,              4)
        
        let marker1 = markers[0]
        XCTAssertEqual(marker1.number,             1)
        XCTAssertEqual(
            marker1.location,
            .timecode(try ProTools.formTimecode(TCC(h: 01, m: 00, s: 00, f: 00), at: ._23_976))
        )
        XCTAssertEqual(marker1.timeReference,      .samples(240240))
        XCTAssertEqual(marker1.name,               "Marker Name\nWith New Line")
        XCTAssertEqual(marker1.comment,            nil)
        
        let marker2 = markers[1]
        XCTAssertEqual(marker2.number,             2)
        XCTAssertEqual(
            marker2.location,
            .timecode(try ProTools.formTimecode(TCC(h: 01, m: 00, s: 01, f: 00), at: ._23_976))
        )
        XCTAssertEqual(marker2.timeReference,      .samples(288288))
        XCTAssertEqual(marker2.name,               "Normal Marker Name")
        XCTAssertEqual(marker2.comment,            "Comment Here\nWith New Line")
        
        let marker3 = markers[2]
        XCTAssertEqual(marker3.number,             3)
        XCTAssertEqual(
            marker3.location,
            .timecode(try ProTools.formTimecode(TCC(h: 01, m: 00, s: 02, f: 00), at: ._23_976))
        )
        XCTAssertEqual(marker3.timeReference,      .samples(336336))
        XCTAssertEqual(marker3.name,               "Marker Name Again\nWith New Line Again")
        XCTAssertEqual(marker3.comment,            "Comment Here Again\nWith New Line Again")
        
        let marker4 = markers[3]
        XCTAssertEqual(marker4.number,             4)
        XCTAssertEqual(
            marker4.location,
            .timecode(try ProTools.formTimecode(TCC(h: 01, m: 00, s: 03, f: 00), at: ._23_976))
        )
        XCTAssertEqual(marker4.timeReference,      .samples(384384))
        XCTAssertEqual(marker4.name,               "Normal Maker Name Again")
        XCTAssertEqual(marker4.comment,            nil)
        
        // orphan data
        
        XCTAssertNil(sessionInfo.orphanData) // none
    }
}
