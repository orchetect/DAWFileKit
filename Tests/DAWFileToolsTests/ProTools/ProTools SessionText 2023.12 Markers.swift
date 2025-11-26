//
//  ProTools SessionText 2023.12 Markers.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import XCTest
@testable import DAWFileTools
import SwiftExtensions
import TimecodeKitCore

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
    
    func testDAWMarkerTrackConversion() throws {
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
        
        let frameRate = try XCTUnwrap(sessionInfo.main.frameRate)
        
        // parse messages
        
        XCTAssertEqual(parseMessages.errors.count, 0)
        if !parseMessages.errors.isEmpty {
            dump(parseMessages.errors)
        }
        
        // markers
        
        let dawMarkerTracks = try XCTUnwrap(
            sessionInfo.markers?.convertToDAWMarkers(originalFrameRate: frameRate)
        )
        XCTAssertEqual(dawMarkerTracks.count, 7)
        
        // spot check a few, we won't check them all
        
        let dawMarkerTrack1 = try XCTUnwrap(dawMarkerTracks[safe: 0])
        XCTAssertEqual(dawMarkerTrack1.name, "Markers")
        XCTAssertEqual(dawMarkerTrack1.trackType, .ruler)
        XCTAssertEqual(dawMarkerTrack1.markers.count, 1)
        let marker1 = try XCTUnwrap(dawMarkerTrack1.markers.first)
        XCTAssertEqual(marker1.name, "Marker 1")
        XCTAssertEqual(
            marker1.timeStorage,
            .init(value: .timecodeString(absolute: "01:00:00:00"),
                  frameRate: .fps24,
                  base: .max100SubFrames)
        )
        
        let dawMarkerTrack2 = try XCTUnwrap(dawMarkerTracks[safe: 1])
        XCTAssertEqual(dawMarkerTrack2.name, "Markers 2")
        XCTAssertEqual(dawMarkerTrack2.trackType, .ruler)
        XCTAssertEqual(dawMarkerTrack2.markers.count, 1)
        let marker2 = try XCTUnwrap(dawMarkerTrack2.markers.first)
        XCTAssertEqual(marker2.name, "Marker 2")
        XCTAssertEqual(
            marker2.timeStorage,
            .init(value: .timecodeString(absolute: "01:00:01:00"),
                  frameRate: .fps24,
                  base: .max100SubFrames)
        )
        
        let dawMarkerTrack6 = try XCTUnwrap(dawMarkerTracks[safe: 5])
        XCTAssertEqual(dawMarkerTrack6.name, "Audio 1")
        XCTAssertEqual(dawMarkerTrack6.trackType, .track)
        XCTAssertEqual(dawMarkerTrack6.markers.count, 1)
        let marker6 = try XCTUnwrap(dawMarkerTrack6.markers.first)
        XCTAssertEqual(marker6.name, "Marker 6")
        XCTAssertEqual(
            marker6.timeStorage,
            .init(value: .timecodeString(absolute: "01:00:05:00"),
                  frameRate: .fps24,
                  base: .max100SubFrames)
        )
    }
}
