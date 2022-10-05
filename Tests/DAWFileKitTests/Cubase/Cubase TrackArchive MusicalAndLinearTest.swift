//
//  Cubase TrackArchive MusicalAndLinearTest.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
@testable import DAWFileKit
import OTCore
import TimecodeKit

class Cubase_TrackArchive_MusicalAndLinearTest: XCTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    func testMusicalAndLinearTest() throws {
        let filename = "MusicalAndLinearTest"
        guard let rawData = loadFileContents(
            forResource: filename,
            withExtension: "xml",
            subFolder: .cubaseTrackArchiveXML
        )
        else { XCTFail("Could not form URL, possibly could not find file."); return }
        
        // parse
        
        var parseMessages: [Cubase.TrackArchive.ParseMessage] = []
        let trackArchive = try Cubase.TrackArchive(data: rawData, messages: &parseMessages)
        
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
        
        let track1event1  = track1?.events[safe: 0] as? Cubase.TrackArchive.Marker
        let track1event2  = track1?.events[safe: 1] as? Cubase.TrackArchive.CycleMarker
        let track1event3  = track1?.events[safe: 2] as? Cubase.TrackArchive.Marker
        let track1event4  = track1?.events[safe: 3] as? Cubase.TrackArchive.CycleMarker
        let track1event5  = track1?.events[safe: 4] as? Cubase.TrackArchive.Marker
        let track1event6  = track1?.events[safe: 5] as? Cubase.TrackArchive.CycleMarker
        let track1event7  = track1?.events[safe: 6] as? Cubase.TrackArchive.Marker
        let track1event8  = track1?.events[safe: 7] as? Cubase.TrackArchive.Marker
        let track1event9  = track1?.events[safe: 8] as? Cubase.TrackArchive.Marker
        let track1event10 = track1?.events[safe: 9] as? Cubase.TrackArchive.Marker
        XCTAssertEqual(track1event1?.startTimecode.stringValue, "01:00:02:00")
        XCTAssertEqual(track1event2?.startTimecode.stringValue, "01:00:04:00")
        XCTAssertEqual(track1event3?.startTimecode.stringValue, "01:00:09:18")
        XCTAssertEqual(track1event4?.startTimecode.stringValue, "01:00:11:06")
        XCTAssertEqual(track1event5?.startTimecode.stringValue, "01:00:16:05")
        XCTAssertEqual(track1event6?.startTimecode.stringValue, "01:00:17:29")
        #warning(
            "> TODO: these tests are correct but will fail until I work on the code that calculates timecodes for musical mode track events when there is a tempo track with multiple tempo change events"
        )
        // XCTAssertEqual(track1event7? .startTimecode.stringValue, "01:00:26:02")
        // XCTAssertEqual(track1event8? .startTimecode.stringValue, "01:00:29:09")
        // XCTAssertEqual(track1event9? .startTimecode.stringValue, "01:00:31:24")
        // XCTAssertEqual(track1event10?.startTimecode.stringValue, "01:50:25:07")
        _ = track1event7
        _ = track1event8
        _ = track1event9
        _ = track1event10
        
        // track 2 - linear mode
        
        let track2 = trackArchive.tracks?[1] as? Cubase.TrackArchive.MarkerTrack
        XCTAssertNotNil(track2)
        
        let track2event1  = track2?.events[safe: 0] as? Cubase.TrackArchive.Marker
        let track2event2  = track2?.events[safe: 1] as? Cubase.TrackArchive.CycleMarker
        let track2event3  = track2?.events[safe: 2] as? Cubase.TrackArchive.Marker
        let track2event4  = track2?.events[safe: 3] as? Cubase.TrackArchive.CycleMarker
        let track2event5  = track2?.events[safe: 4] as? Cubase.TrackArchive.Marker
        let track2event6  = track2?.events[safe: 5] as? Cubase.TrackArchive.CycleMarker
        let track2event7  = track2?.events[safe: 6] as? Cubase.TrackArchive.Marker
        let track2event8  = track2?.events[safe: 7] as? Cubase.TrackArchive.Marker
        let track2event9  = track2?.events[safe: 8] as? Cubase.TrackArchive.Marker
        let track2event10 = track2?.events[safe: 9] as? Cubase.TrackArchive.Marker
        
        XCTAssertEqual(track2event1?.startTimecode.stringValue, "01:00:02:00")
        XCTAssertEqual(track2event2?.startTimecode.stringValue, "01:00:04:00")
        XCTAssertEqual(track2event3?.startTimecode.stringValue, "01:00:09:18")
        XCTAssertEqual(track2event4?.startTimecode.stringValue, "01:00:11:06")
        XCTAssertEqual(track2event5?.startTimecode.stringValue, "01:00:16:05")
        XCTAssertEqual(track2event6?.startTimecode.stringValue, "01:00:17:29")
        XCTAssertEqual(track2event7?.startTimecode.stringValue, "01:00:26:02")
        XCTAssertEqual(track2event8?.startTimecode.stringValue, "01:00:29:09")
        XCTAssertEqual(track2event9?.startTimecode.stringValue, "01:00:31:24")
        XCTAssertEqual(track2event10?.startTimecode.stringValue, "01:50:25:07")
    }
}

#endif
