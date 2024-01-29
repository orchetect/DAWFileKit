//
//  ProTools SessionText 2023.12 Markers.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import XCTest
@testable import DAWFileKit
import OTCore
import TimecodeKit

class ProTools_SessionText_2023_12_Markers: XCTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    func testSessionText() throws {
        // load file
        
        let filename = "SessionText_MarkerRulersAndTrackMarkers_PT2023.12"
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
        
        XCTAssertEqual(sessionInfo.main.name,            "Test")
        XCTAssertEqual(sessionInfo.main.sampleRate,      48000.0)
        XCTAssertEqual(sessionInfo.main.bitDepth,        "24-bit")
        XCTAssertEqual(
            sessionInfo.main.startTimecode,
            try ProTools.formTimecode(.init(h: 0, m: 59, s: 50, f: 00), at: .fps24)
        )
        XCTAssertEqual(sessionInfo.main.frameRate,       .fps24)
        XCTAssertEqual(sessionInfo.main.audioTrackCount, 2)
        XCTAssertEqual(sessionInfo.main.audioClipCount,  0)
        XCTAssertEqual(sessionInfo.main.audioFileCount,  0)
        
        // markers
        
        let markers = try XCTUnwrap(sessionInfo.markers)
        XCTAssertEqual(markers.count, 7)
        
        XCTAssertEqual(
            markers[safe: 0],
            ProTools.SessionInfo.Marker(
                number: 1,
                location: .timecode(try ProTools.formTimecode(.init(h: 1, m: 00, s: 00, f: 00), at: .fps24)),
                timeReference: .samples(480000),
                name: "Marker 1",
                trackName: "Markers",
                trackType: .ruler,
                comment: nil
            )
        )
        
        XCTAssertEqual(
            markers[safe: 1],
            ProTools.SessionInfo.Marker(
                number: 2,
                location: .timecode(try ProTools.formTimecode(.init(h: 1, m: 00, s: 01, f: 00), at: .fps24)),
                timeReference: .samples(528000),
                name: "Marker 2",
                trackName: "Markers 2",
                trackType: .ruler,
                comment: "Some comments"
            )
        )
        
        XCTAssertEqual(
            markers[safe: 2],
            ProTools.SessionInfo.Marker(
                number: 3,
                location: .timecode(try ProTools.formTimecode(.init(h: 1, m: 00, s: 02, f: 00), at: .fps24)),
                timeReference: .samples(576000),
                name: "Marker 3",
                trackName: "Markers 3",
                trackType: .ruler,
                comment: nil
            )
        )
        
        XCTAssertEqual(
            markers[safe: 3],
            ProTools.SessionInfo.Marker(
                number: 4,
                location: .timecode(try ProTools.formTimecode(.init(h: 1, m: 00, s: 03, f: 00), at: .fps24)),
                timeReference: .samples(624000),
                name: "Marker 4",
                trackName: "Markers 4",
                trackType: .ruler,
                comment: nil
            )
        )
        
        XCTAssertEqual(
            markers[safe: 4],
            ProTools.SessionInfo.Marker(
                number: 5,
                location: .timecode(try ProTools.formTimecode(.init(h: 1, m: 00, s: 04, f: 00), at: .fps24)),
                timeReference: .samples(672000),
                name: "Marker 5",
                trackName: "Markers 5",
                trackType: .ruler,
                comment: nil
            )
        )
        
        XCTAssertEqual(
            markers[safe: 5],
            ProTools.SessionInfo.Marker(
                number: 6,
                location: .timecode(try ProTools.formTimecode(.init(h: 1, m: 00, s: 05, f: 00), at: .fps24)),
                timeReference: .samples(720000),
                name: "Marker 6",
                trackName: "Audio 1",
                trackType: .track,
                comment: "More comments"
            )
        )
        
        XCTAssertEqual(
            markers[safe: 6],
            ProTools.SessionInfo.Marker(
                number: 7,
                location: .timecode(try ProTools.formTimecode(.init(h: 1, m: 00, s: 06, f: 00), at: .fps24)),
                timeReference: .samples(768000),
                name: "Marker 7",
                trackName: "Audio 2",
                trackType: .track,
                comment: nil
            )
        )
        
        // orphan data
        
        XCTAssertNil(sessionInfo.orphanData)       // none
    }
}
