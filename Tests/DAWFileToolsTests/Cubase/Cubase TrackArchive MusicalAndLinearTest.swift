//
//  Cubase TrackArchive MusicalAndLinearTest.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
@testable import DAWFileTools
import SwiftExtensions
import TimecodeKitCore

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
        let trackArchive = try Cubase.TrackArchive(fileContent: rawData, messages: &parseMessages)
        
        // parse messages
        
        XCTAssertEqual(parseMessages.errors.count, 0)
        if !parseMessages.errors.isEmpty {
            dump(parseMessages.errors)
        }
        
        // ---- tracks ----
        
        XCTAssertEqual(trackArchive.tracks?.count, 2)
        
        // track 1 - musical mode
        
        guard case let .marker(track1) = trackArchive.tracks?[0] else { XCTFail(); return }
        
        guard case let .marker(track1event1) = track1.events[safe: 0] else { XCTFail(); return }
        XCTAssertEqual(track1event1.startTimecode.stringValue(), "01:00:02:00")
        
        guard case let .cycleMarker(track1event2) = track1.events[safe: 1] else { XCTFail(); return }
        XCTAssertEqual(track1event2.startTimecode.stringValue(), "01:00:04:00")
        
        guard case let .marker(track1event3) = track1.events[safe: 2] else { XCTFail(); return }
        XCTAssertEqual(track1event3.startTimecode.stringValue(), "01:00:09:18")
        
        guard case let .cycleMarker(track1event4) = track1.events[safe: 3] else { XCTFail(); return }
        XCTAssertEqual(track1event4.startTimecode.stringValue(), "01:00:11:06")
        
        guard case let .marker(track1event5) = track1.events[safe: 4] else { XCTFail(); return }
        XCTAssertEqual(track1event5.startTimecode.stringValue(), "01:00:16:05")
        
        guard case let .cycleMarker(track1event6) = track1.events[safe: 5] else { XCTFail(); return }
        XCTAssertEqual(track1event6.startTimecode.stringValue(), "01:00:17:29")
        
        #warning(
            "> TODO: these four asserts are correct, but will fail for now until tempo ramp events are implemented"
        )
        
        guard case let .marker(track1event7) = track1.events[safe: 6] else { XCTFail(); return }
        // XCTAssertEqual(track1event7.startTimecode.stringValue(), "01:00:26:02")
        _ = track1event7 // silence warning
        
        guard case let .marker(track1event8) = track1.events[safe: 7] else { XCTFail(); return }
        // XCTAssertEqual(track1event8.startTimecode.stringValue(), "01:00:29:09")
        _ = track1event8 // silence warning
        
        guard case let .marker(track1event9) = track1.events[safe: 8] else { XCTFail(); return }
        // XCTAssertEqual(track1event9.startTimecode.stringValue(), "01:00:31:24")
        _ = track1event9 // silence warning
        
        guard case let .marker(track1event10) = track1.events[safe: 9] else { XCTFail(); return }
        // XCTAssertEqual(track1event10.startTimecode.stringValue(), "01:50:25:07")
        _ = track1event10 // silence warning
        
        // track 2 - linear mode
        
        guard case let .marker(track2) = trackArchive.tracks?[1] else { XCTFail(); return }
        XCTAssertNotNil(track2)
        
        guard case let .marker(track2event1) = track2.events[safe: 0] else { XCTFail(); return }
        XCTAssertEqual(track2event1.startTimecode.stringValue(), "01:00:02:00")
        
        guard case let .cycleMarker(track2event2) = track2.events[safe: 1] else { XCTFail(); return }
        XCTAssertEqual(track2event2.startTimecode.stringValue(), "01:00:04:00")
        
        guard case let .marker(track2event3) = track2.events[safe: 2] else { XCTFail(); return }
        XCTAssertEqual(track2event3.startTimecode.stringValue(), "01:00:09:18")
        
        guard case let .cycleMarker(track2event4) = track2.events[safe: 3] else { XCTFail(); return }
        XCTAssertEqual(track2event4.startTimecode.stringValue(), "01:00:11:06")
        
        guard case let .marker(track2event5) = track2.events[safe: 4] else { XCTFail(); return }
        XCTAssertEqual(track2event5.startTimecode.stringValue(), "01:00:16:05")
        
        guard case let .cycleMarker(track2event6) = track2.events[safe: 5] else { XCTFail(); return }
        XCTAssertEqual(track2event6.startTimecode.stringValue(), "01:00:17:29")
        
        guard case let .marker(track2event7) = track2.events[safe: 6] else { XCTFail(); return }
        XCTAssertEqual(track2event7.startTimecode.stringValue(), "01:00:26:02")
        
        guard case let .marker(track2event8) = track2.events[safe: 7] else { XCTFail(); return }
        XCTAssertEqual(track2event8.startTimecode.stringValue(), "01:00:29:09")
        
        guard case let .marker(track2event9) = track2.events[safe: 8] else { XCTFail(); return }
        XCTAssertEqual(track2event9.startTimecode.stringValue(), "01:00:31:24")
        
        guard case let .marker(track2event10) = track2.events[safe: 9] else { XCTFail(); return }
        XCTAssertEqual(track2event10.startTimecode.stringValue(), "01:50:25:07")
    }
}

#endif
