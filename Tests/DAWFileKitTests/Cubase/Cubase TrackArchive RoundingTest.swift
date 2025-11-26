//
//  Cubase TrackArchive RoundingTest.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
@testable import DAWFileKit
import SwiftExtensions
import TimecodeKit

class Cubase_TrackArchive_RoundingTest: XCTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    func testRoundingTest() throws {
        let filename = "RoundingTest"
        guard let rawData = loadFileContents(
            forResource: filename,
            withExtension: "xml",
            subFolder: .cubaseTrackArchiveXML
        )
        else { XCTFail("Could not form URL, possibly could not find file."); return }
        
        // parse
        
        var parseMessages: [Cubase.TrackArchive.ParseMessage] = []
        let trackArchive = try Cubase.TrackArchive(fileContent: rawData, messages: &parseMessages)
        
        // parse messages
        
        XCTAssertEqual(parseMessages.errors.count, 0)
        if !parseMessages.errors.isEmpty {
            dump(parseMessages.errors)
        }
        
        // ---- tracks ----
        
        XCTAssertEqual(trackArchive.tracks?.count, 2)
        
        // track 1 - musical mode
        
        let track1 = trackArchive.tracks?[0] as? Cubase.TrackArchive.MarkerTrack
        XCTAssertNotNil(track1)
        XCTAssertEqual(track1?.events.count, 4)
        
        let track1event1 = track1?.events[safe: 0] as? Cubase.TrackArchive.Marker
        let track1event2 = track1?.events[safe: 1] as? Cubase.TrackArchive.Marker
        let track1event3 = track1?.events[safe: 2] as? Cubase.TrackArchive.Marker
        let track1event4 = track1?.events[safe: 3] as? Cubase.TrackArchive.Marker
        
        XCTAssertEqual(
            track1event1?.startTimecode.stringValue(format: [.showSubFrames]),
            "01:00:01:29.00"
        ) // as displayed in Cubase
        XCTAssertEqual(
            track1event2?.startTimecode.stringValue(format: [.showSubFrames]),
            "01:00:01:29.78"
        ) // as displayed in Cubase
        XCTAssertEqual(
            track1event3?.startTimecode.stringValue(format: [.showSubFrames]),
            "01:00:01:29.79"
        ) // as displayed in Cubase
        XCTAssertEqual(
            track1event4?.startTimecode.stringValue(format: [.showSubFrames]),
            "01:00:02:00.00"
        ) // as displayed in Cubase
        
        // track 2 - linear mode
        
        let track2 = trackArchive.tracks?[1] as? Cubase.TrackArchive.MarkerTrack
        XCTAssertNotNil(track2)
        XCTAssertEqual(track2?.events.count, 4)
        
        let track2event1 = track2?.events[safe: 0] as? Cubase.TrackArchive.Marker
        let track2event2 = track2?.events[safe: 1] as? Cubase.TrackArchive.Marker
        let track2event3 = track2?.events[safe: 2] as? Cubase.TrackArchive.Marker
        let track2event4 = track2?.events[safe: 3] as? Cubase.TrackArchive.Marker
        
        XCTAssertEqual(
            track2event1?.startTimecode.stringValue(format: [.showSubFrames]),
            "01:00:01:29.00"
        ) // as displayed in Cubase
        XCTAssertEqual(
            track2event2?.startTimecode.stringValue(format: [.showSubFrames]),
            "01:00:01:29.78"
        ) // as displayed in Cubase
        XCTAssertEqual(
            track2event3?.startTimecode.stringValue(format: [.showSubFrames]),
            "01:00:01:29.79"
        ) // as displayed in Cubase
        XCTAssertEqual(
            track2event4?.startTimecode.stringValue(format: [.showSubFrames]),
            "01:00:02:00.00"
        ) // as displayed in Cubase
    }
}

#endif
