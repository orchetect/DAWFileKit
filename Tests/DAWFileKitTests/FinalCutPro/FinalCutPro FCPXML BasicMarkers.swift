//
//  FinalCutPro FCPXML BasicMarkers.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
@testable import DAWFileKit
import OTCore
import TimecodeKit

class FinalCutPro_FCPXML_BasicMarkers: XCTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    func testParse() throws {
        // load file
        
        let rawData = try XCTUnwrap(loadFileContents(
            forResource: "BasicMarkers",
            withExtension: "fcpxml",
            subFolder: .fcpxmlExports
        ))
        
        // load
        
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // version
        
        XCTAssertEqual(fcpxml.version, .ver1_9)
        
        // resources
        
        let resources = fcpxml.resources()
        
        XCTAssertEqual(resources.count, 2)
        
        let r1 = FinalCutPro.FCPXML.Format(
            id: "r1",
            name: "FFVideoFormat1080p2997",
            frameDuration: "1001/30000s",
            fieldOrder: nil,
            width: 1920,
            height: 1080,
            paspH: nil,
            paspV: nil,
            colorSpace: "1-1-1 (Rec. 709)",
            projection: nil,
            stereoscopic: nil
        )
        XCTAssertEqual(resources["r1"], .format(r1))
        
        let r2 = FinalCutPro.FCPXML.Effect(
            id: "r2",
            name: "Basic Title",
            uid: ".../Titles.localized/Bumper:Opener.localized/Basic Title.localized/Basic Title.moti",
            src: nil
        )
        XCTAssertEqual(resources["r2"], .effect(r2))
        
        // library
        
        let library = try XCTUnwrap(fcpxml.library())
        
        let libraryURL = URL(string: "file:///Users/user/Movies/MyLibrary.fcpbundle/")
        XCTAssertEqual(library.location, libraryURL)
        
        // events
        
        let events = fcpxml.events()
        
        XCTAssertEqual(events.count, 1)
        
        let event = try XCTUnwrap(events[safe: 0])
        XCTAssertEqual(event.name, "Test Event")
        
        // projects
        
        let projects = try XCTUnwrap(events[safe: 0]).projects
        
        XCTAssertEqual(projects.count, 1)
        
        let project = try XCTUnwrap(projects[safe: 0])
        XCTAssertEqual(project.name, "Test Project")
        XCTAssertEqual(project.startTimecode, try Timecode(.rational(0, 1), at: .fps29_97, base: .max80SubFrames))
        
        // sequence
        
        let sequence = try XCTUnwrap(projects[safe: 0]).sequence
        
        XCTAssertEqual(sequence.formatID, "r1")
        XCTAssertEqual(sequence.startTimecode, Timecode(.zero, at: .fps29_97, base: .max80SubFrames))
        XCTAssertEqual(sequence.startTimecode?.frameRate, .fps29_97)
        XCTAssertEqual(sequence.startTimecode?.subFramesBase, .max80SubFrames)
        XCTAssertEqual(sequence.duration, try Timecode(.components(h: 00, m: 01, s: 03, f: 29), at: .fps29_97, base: .max80SubFrames))
        XCTAssertEqual(sequence.audioLayout, .stereo)
        XCTAssertEqual(sequence.audioRate, .rate48kHz)
        
        // story elements (clips etc.)
        
        let spine = sequence.spine
        
        XCTAssertEqual(spine.elements.count, 1)
        
        guard case let .anyClip(.title(element1)) = spine.elements[0] else { XCTFail("Clip was not expected type.") ; return }
        
        XCTAssertEqual(element1.ref, "r2")
        XCTAssertEqual(element1.offset, Timecode(.zero, at: .fps29_97, base: .max80SubFrames))
        XCTAssertEqual(element1.offset?.frameRate, .fps29_97)
        XCTAssertEqual(element1.name, "Basic Title")
        XCTAssertEqual(element1.start, try Timecode(.components(m: 10), at: .fps29_97, base: .max80SubFrames))
        XCTAssertEqual(element1.start?.frameRate, .fps29_97)
        XCTAssertEqual(element1.duration, try Timecode(.components(h: 00, m: 01, s: 03, f: 29), at: .fps29_97, base: .max80SubFrames))
        XCTAssertEqual(element1.duration?.frameRate, .fps29_97)
        
        // markers
        
        let markers = element1.markers
        
        XCTAssertEqual(markers.count, 4)
        
        let expectedMarker0 = FinalCutPro.FCPXML.Marker(
            start: try Timecode(.components(h: 01, m: 00, s: 29, f: 14), at: .fps29_97, base: .max80SubFrames),
            duration: try Timecode(.components(f: 1), at: .fps29_97, base: .max80SubFrames),
            name: "Standard Marker",
            metaData: .standard,
            note: "some notes here"
        )
        XCTAssertEqual(markers[safe: 0], expectedMarker0)
        
        let expectedMarker1 = FinalCutPro.FCPXML.Marker(
            start: try Timecode(.components(h: 01, m: 00, s: 29, f: 15), at: .fps29_97, base: .max80SubFrames),
            duration: try Timecode(.components(f: 1), at: .fps29_97, base: .max80SubFrames),
            name: "To Do Marker, Incomplete",
            metaData: .toDo(completed: false),
            note: "more notes here"
        )
        XCTAssertEqual(markers[safe: 1], expectedMarker1)
        
        let expectedMarker2 = FinalCutPro.FCPXML.Marker(
            start: try Timecode(.components(h: 01, m: 00, s: 29, f: 16), at: .fps29_97, base: .max80SubFrames),
            duration: try Timecode(.components(f: 1), at: .fps29_97, base: .max80SubFrames),
            name: "To Do Marker, Completed",
            metaData: .toDo(completed: true),
            note: "notes yay"
        )
        XCTAssertEqual(markers[safe: 2], expectedMarker2)
        
        let expectedMarker3 = FinalCutPro.FCPXML.Marker(
            start: try Timecode(.components(h: 01, m: 00, s: 29, f: 17), at: .fps29_97, base: .max80SubFrames),
            duration: try Timecode(.components(f: 1), at: .fps29_97),
            name: "Chapter Marker",
            metaData: .chapter(posterOffset: .init(try Timecode(.components(f: 10, sf: 79), at: .fps29_97, base: .max80SubFrames))),
            note: nil
        )
        XCTAssertEqual(markers[safe: 3], expectedMarker3)
    }
}

#endif
