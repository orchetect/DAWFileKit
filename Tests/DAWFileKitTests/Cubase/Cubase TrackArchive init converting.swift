//
//  Cubase TrackArchive init converting.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

@testable import DAWFileKit
import OTCore
import TimecodeKit
import XCTest

class Cubase_TrackArchive_ConvertingDAWMarkers: XCTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    func testConvertingDAWMarkers_IncludeComments_NoComments() throws {
        let dawMarkers: [DAWMarker] = [
            DAWMarker(storage: .init(value: .realTime(0.5), frameRate: .fps24, base: .max80SubFrames), name: "Marker1", comment: nil),
            DAWMarker(storage: .init(value: .realTime(1.0), frameRate: .fps24, base: .max80SubFrames), name: "Marker2", comment: nil)
        ]
        
        let trackArchive = Cubase.TrackArchive(
            converting: dawMarkers,
            at: .fps24,
            startTimecode: Timecode(.zero, at: .fps24),
            includeComments: true
        )
        
        // main
        XCTAssertEqual(trackArchive.main.startTimecode, Timecode(.zero, at: .fps24))
        XCTAssertEqual(trackArchive.main.frameRate, .fps24)
        
        // markers
        
        let tracks = try XCTUnwrap(trackArchive.tracks)
        XCTAssertEqual(tracks.count, 1)
        
        let track1 = try XCTUnwrap(tracks[0] as? Cubase.TrackArchive.MarkerTrack)
        XCTAssertEqual(track1.name, "Markers")
        
        XCTAssertEqual(track1.events.count, 2)
        
        let marker1 = track1.events[0]
        XCTAssertEqual(marker1.name, "Marker1")
        XCTAssertEqual(marker1.startRealTime, nil) // not stored since we're computing based on start timecode
        XCTAssertEqual(marker1.startTimecode, try Timecode(.components(f: 12), at: .fps24))
        
        let marker2 = track1.events[1]
        XCTAssertEqual(marker2.name, "Marker2")
        XCTAssertEqual(marker2.startRealTime, nil) // not stored since we're computing based on start timecode
        XCTAssertEqual(marker2.startTimecode, try Timecode(.components(s: 1), at: .fps24))
    }
    
    func testConvertingDAWMarkers_IncludeComments_WithComments() throws {
        let dawMarkers: [DAWMarker] = [
            DAWMarker(storage: .init(value: .realTime(0.5), frameRate: .fps24, base: .max80SubFrames), name: "Marker1", comment: nil),
            DAWMarker(storage: .init(value: .realTime(1.0), frameRate: .fps24, base: .max80SubFrames), name: "Marker2", comment: "Comment2")
        ]
        
        let trackArchive = Cubase.TrackArchive(
            converting: dawMarkers,
            at: .fps24,
            startTimecode: Timecode(.zero, at: .fps24),
            includeComments: true
        )
        
        // main
        XCTAssertEqual(trackArchive.main.startTimecode, Timecode(.zero, at: .fps24))
        XCTAssertEqual(trackArchive.main.frameRate, .fps24)
        
        // markers
        
        let tracks = try XCTUnwrap(trackArchive.tracks)
        XCTAssertEqual(tracks.count, 1)
        
        let track1 = try XCTUnwrap(tracks[0] as? Cubase.TrackArchive.MarkerTrack)
        XCTAssertEqual(track1.name, "Markers")
        
        XCTAssertEqual(track1.events.count, 2)
        
        let marker1 = track1.events[0]
        XCTAssertEqual(marker1.name, "Marker1")
        XCTAssertEqual(marker1.startRealTime, nil) // not stored since we're computing based on start timecode
        XCTAssertEqual(marker1.startTimecode, try Timecode(.components(f: 12), at: .fps24))
        
        let marker2 = track1.events[1]
        XCTAssertEqual(marker2.name, "Marker2 - Comment2")
        XCTAssertEqual(marker2.startRealTime, nil) // not stored since we're computing based on start timecode
        XCTAssertEqual(marker2.startTimecode, try Timecode(.components(s: 1), at: .fps24))
    }
    
    func testConvertingDAWMarkers_DoNotIncludeComments_WithComments() throws {
        let dawMarkers: [DAWMarker] = [
            DAWMarker(storage: .init(value: .realTime(0.5), frameRate: .fps24, base: .max80SubFrames), name: "Marker1", comment: nil),
            DAWMarker(storage: .init(value: .realTime(1.0), frameRate: .fps24, base: .max80SubFrames), name: "Marker2", comment: "Comment2")
        ]
        
        let trackArchive = Cubase.TrackArchive(
            converting: dawMarkers,
            at: .fps24,
            startTimecode: Timecode(.zero, at: .fps24),
            includeComments: false
        )
        
        // main
        XCTAssertEqual(trackArchive.main.startTimecode, Timecode(.zero, at: .fps24))
        XCTAssertEqual(trackArchive.main.frameRate, .fps24)
        
        // markers
        
        let tracks = try XCTUnwrap(trackArchive.tracks)
        XCTAssertEqual(tracks.count, 1)
        
        let track1 = try XCTUnwrap(tracks[0] as? Cubase.TrackArchive.MarkerTrack)
        XCTAssertEqual(track1.name, "Markers")
        
        XCTAssertEqual(track1.events.count, 2)
        
        let marker1 = track1.events[0]
        XCTAssertEqual(marker1.name, "Marker1")
        XCTAssertEqual(marker1.startRealTime, nil) // not stored since we're computing based on start timecode
        XCTAssertEqual(marker1.startTimecode, try Timecode(.components(f: 12), at: .fps24))
        
        let marker2 = track1.events[1]
        XCTAssertEqual(marker2.name, "Marker2")
        XCTAssertEqual(marker2.startRealTime, nil) // not stored since we're computing based on start timecode
        XCTAssertEqual(marker2.startTimecode, try Timecode(.components(s: 1), at: .fps24))
    }
}

#endif
