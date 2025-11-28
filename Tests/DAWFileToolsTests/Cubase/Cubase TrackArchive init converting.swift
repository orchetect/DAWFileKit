//
//  Cubase TrackArchive init converting.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

@testable import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore
import XCTest

class Cubase_TrackArchive_ConvertingDAWMarkers: XCTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    func testConvertingDAWMarkers_IncludeComments_NoComments() throws {
        let dawMarkers: [DAWMarker] = [
            DAWMarker(storage: .init(value: .realTime(relativeToStart: 0.5), frameRate: .fps24, base: .max80SubFrames), name: "Marker1", comment: nil),
            DAWMarker(storage: .init(value: .realTime(relativeToStart: 1.0), frameRate: .fps24, base: .max80SubFrames), name: "Marker2", comment: nil)
        ]
        
        var buildMessages: [Cubase.TrackArchive.EncodeMessage] = []
        let trackArchive = Cubase.TrackArchive(
            converting: dawMarkers,
            at: .fps24,
            startTimecode: Timecode(.zero, at: .fps24),
            includeComments: true,
            separateCommentsTrack: false,
            buildMessages: &buildMessages
        )
        
        // build messages
        XCTAssertEqual(buildMessages.count, 0)
        if !buildMessages.errors.isEmpty {
            dump(buildMessages.errors)
        }
        
        // main
        XCTAssertEqual(trackArchive.main.startTimecode, Timecode(.zero, at: .fps24))
        XCTAssertEqual(trackArchive.main.frameRate, .fps24)
        
        // markers
        
        let tracks = try XCTUnwrap(trackArchive.tracks)
        XCTAssertEqual(tracks.count, 1)
        
        guard case let .marker(track1) = tracks[0] else { XCTFail(); return }
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
            DAWMarker(storage: .init(value: .realTime(relativeToStart: 0.5), frameRate: .fps24, base: .max80SubFrames), name: "Marker1", comment: nil),
            DAWMarker(storage: .init(value: .realTime(relativeToStart: 1.0), frameRate: .fps24, base: .max80SubFrames), name: "Marker2", comment: "Comment2")
        ]
        
        var buildMessages: [Cubase.TrackArchive.EncodeMessage] = []
        let trackArchive = Cubase.TrackArchive(
            converting: dawMarkers,
            at: .fps24,
            startTimecode: Timecode(.zero, at: .fps24),
            includeComments: true,
            separateCommentsTrack: false,
            buildMessages: &buildMessages
        )
        
        // build messages
        XCTAssertEqual(buildMessages.count, 0)
        if !buildMessages.errors.isEmpty {
            dump(buildMessages.errors)
        }
        
        // main
        XCTAssertEqual(trackArchive.main.startTimecode, Timecode(.zero, at: .fps24))
        XCTAssertEqual(trackArchive.main.frameRate, .fps24)
        
        // markers
        
        let tracks = try XCTUnwrap(trackArchive.tracks)
        XCTAssertEqual(tracks.count, 1)
        
        guard case let .marker(track1) = tracks[0] else { XCTFail(); return }
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
    
    func testConvertingDAWMarkers_IncludeComments_SeparateCommentsTrack_VariedComments() throws {
        let dawMarkers: [DAWMarker] = [
            DAWMarker(storage: .init(value: .realTime(relativeToStart: 0.5), frameRate: .fps24, base: .max80SubFrames), name: "Marker1", comment: nil),
            DAWMarker(storage: .init(value: .realTime(relativeToStart: 1.0), frameRate: .fps24, base: .max80SubFrames), name: "Marker2", comment: "Comment2")
        ]
        
        var buildMessages: [Cubase.TrackArchive.EncodeMessage] = []
        let trackArchive = Cubase.TrackArchive(
            converting: dawMarkers,
            at: .fps24,
            startTimecode: Timecode(.zero, at: .fps24),
            includeComments: true,
            separateCommentsTrack: true,
            buildMessages: &buildMessages
        )
        
        // build messages
        XCTAssertEqual(buildMessages.count, 0)
        if !buildMessages.errors.isEmpty {
            dump(buildMessages.errors)
        }
        
        // main
        XCTAssertEqual(trackArchive.main.startTimecode, Timecode(.zero, at: .fps24))
        XCTAssertEqual(trackArchive.main.frameRate, .fps24)
        
        // markers
        
        let tracks = try XCTUnwrap(trackArchive.tracks)
        XCTAssertEqual(tracks.count, 2)
        
        // track 1 (markers)
        
        do {
            guard case let .marker(track1) = tracks[0] else { XCTFail(); return }
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
        
        // track 2 (comments)
        
        do {
            guard case let .marker(track2) = tracks[1] else { XCTFail(); return }
            XCTAssertEqual(track2.name, "Comments")
            
            XCTAssertEqual(track2.events.count, 1)
            
            let marker = track2.events[0]
            XCTAssertEqual(marker.name, "Comment2")
            XCTAssertEqual(marker.startRealTime, nil) // not stored since we're computing based on start timecode
            XCTAssertEqual(marker.startTimecode, try Timecode(.components(s: 1), at: .fps24))
        }
    }
    
    func testConvertingDAWMarkers_DoNotIncludeComments_WithComments() throws {
        let dawMarkers: [DAWMarker] = [
            DAWMarker(storage: .init(value: .realTime(relativeToStart: 0.5), frameRate: .fps24, base: .max80SubFrames), name: "Marker1", comment: nil),
            DAWMarker(storage: .init(value: .realTime(relativeToStart: 1.0), frameRate: .fps24, base: .max80SubFrames), name: "Marker2", comment: "Comment2")
        ]
        
        var buildMessages: [Cubase.TrackArchive.EncodeMessage] = []
        let trackArchive = Cubase.TrackArchive(
            converting: dawMarkers,
            at: .fps24,
            startTimecode: Timecode(.zero, at: .fps24),
            includeComments: false,
            separateCommentsTrack: false,
            buildMessages: &buildMessages
        )
        
        // build messages
        XCTAssertEqual(buildMessages.count, 0)
        if !buildMessages.errors.isEmpty {
            dump(buildMessages.errors)
        }
        
        // main
        XCTAssertEqual(trackArchive.main.startTimecode, Timecode(.zero, at: .fps24))
        XCTAssertEqual(trackArchive.main.frameRate, .fps24)
        
        // markers
        
        let tracks = try XCTUnwrap(trackArchive.tracks)
        XCTAssertEqual(tracks.count, 1)
        
        guard case let .marker(track1) = tracks[0] else { XCTFail(); return }
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
    
    func testConvertingDAWMarkers_TimecodeStorage() throws {
        let dawMarkers: [DAWMarker] = [
            DAWMarker(storage: .init(value: .timecodeString(absolute: "00:00:00:12"), frameRate: .fps24, base: .max80SubFrames), name: "Marker1", comment: nil),
            DAWMarker(storage: .init(value: .timecodeString(absolute: "00:00:01:00"), frameRate: .fps24, base: .max80SubFrames), name: "Marker2", comment: nil)
        ]
        
        var buildMessages: [Cubase.TrackArchive.EncodeMessage] = []
        let trackArchive = Cubase.TrackArchive(
            converting: dawMarkers,
            at: .fps24,
            startTimecode: Timecode(.zero, at: .fps24),
            includeComments: true,
            separateCommentsTrack: false,
            buildMessages: &buildMessages
        )
        
        // build messages
        XCTAssertEqual(buildMessages.count, 0)
        if !buildMessages.errors.isEmpty {
            dump(buildMessages.errors)
        }
        
        // main
        XCTAssertEqual(trackArchive.main.startTimecode, Timecode(.zero, at: .fps24))
        XCTAssertEqual(trackArchive.main.frameRate, .fps24)
        
        // markers
        
        let tracks = try XCTUnwrap(trackArchive.tracks)
        XCTAssertEqual(tracks.count, 1)
        
        guard case let .marker(track1) = tracks[0] else { XCTFail(); return }
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
    
    func testConvertingDAWMarkers_NonZeroTimelineStart() throws {
        let dawMarkers: [DAWMarker] = [
            DAWMarker(storage: .init(value: .timecodeString(absolute: "00:00:00:12"), frameRate: .fps24, base: .max80SubFrames), name: "Marker1", comment: nil),
            DAWMarker(storage: .init(value: .timecodeString(absolute: "00:00:01:00"), frameRate: .fps24, base: .max80SubFrames), name: "Marker2", comment: nil)
        ]
        
        var buildMessages: [Cubase.TrackArchive.EncodeMessage] = []
        let trackArchive = Cubase.TrackArchive(
            converting: dawMarkers,
            at: .fps24,
            startTimecode: try Timecode(.components(h: 23), at: .fps24),
            includeComments: true,
            separateCommentsTrack: false,
            buildMessages: &buildMessages
        )
        
        // build messages
        XCTAssertEqual(buildMessages.count, 0)
        if !buildMessages.errors.isEmpty {
            dump(buildMessages.errors)
        }
        
        // main
        XCTAssertEqual(trackArchive.main.startTimecode, try Timecode(.components(h: 23), at: .fps24))
        XCTAssertEqual(trackArchive.main.frameRate, .fps24)
        
        // markers
        
        let tracks = try XCTUnwrap(trackArchive.tracks)
        XCTAssertEqual(tracks.count, 1)
        
        guard case let .marker(track1) = tracks[0] else { XCTFail(); return }
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
