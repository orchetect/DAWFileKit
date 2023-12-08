//
//  FinalCutPro FCPXML BasicMarkers_1HourProjectStart.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
@testable import DAWFileKit
import OTCore
import TimecodeKit

final class FinalCutPro_FCPXML_BasicMarkers_1HourProjectStart: FCPXMLTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    func testParse() throws {
        // load file
        
        let rawData = try XCTUnwrap(loadFileContents(
            forResource: "BasicMarkers_1HourProjectStart",
            withExtension: "fcpxml",
            subFolder: .fcpxmlExports
        ))
        
        // load
        
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // version
        
        XCTAssertEqual(fcpxml.version, .ver1_9)
        
        // resources
        
        let resources = try XCTUnwrap(fcpxml.resourcesElement)
        
        XCTAssertEqual(resources.childElements.count, 2)
        
        let r1 = try XCTUnwrap(resources.childElements[safe: 0]?.fcpAsFormat)
        XCTAssertEqual(r1.id, "r1")
        XCTAssertEqual(r1.name, "FFVideoFormat1080p2997")
        XCTAssertEqual(r1.frameDuration, Fraction(1001, 30000))
        XCTAssertEqual(r1.fieldOrder, nil)
        XCTAssertEqual(r1.width, 1920)
        XCTAssertEqual(r1.height, 1080)
        XCTAssertEqual(r1.paspH, nil)
        XCTAssertEqual(r1.paspV, nil)
        XCTAssertEqual(r1.colorSpace, "1-1-1 (Rec. 709)")
        XCTAssertEqual(r1.projection, nil)
        XCTAssertEqual(r1.stereoscopic, nil)
        
        let r2 = try XCTUnwrap(resources.childElements[safe: 1]?.fcpAsEffect)
        XCTAssertEqual(r2.id, "r2")
        XCTAssertEqual(r2.name, "Basic Title")
        XCTAssertEqual(r2.uid, ".../Titles.localized/Bumper:Opener.localized/Basic Title.localized/Basic Title.moti")
        XCTAssertEqual(r2.src, nil)
        
        // library
        
        let library = try XCTUnwrap(fcpxml.libraryElement?.fcpAsLibrary)
        
        let libraryURL = URL(string: "file:///Users/user/Movies/MyLibrary.fcpbundle/")
        XCTAssertEqual(library.name, "MyLibrary")
        XCTAssertEqual(library.location, libraryURL)
        XCTAssertEqual(library.events.count, 1)
        
        // events
        
        let events = fcpxml.allEvents().map(\.fcpAsEvent!)
        XCTAssertEqual(events.count, 1)
        
        let event = try XCTUnwrap(events[safe: 0])
        XCTAssertEqual(event.name, "Test Event")
        
        // projects
        
        let projects = try XCTUnwrap(events[safe: 0]).projects.map(\.fcpAsProject!)
        XCTAssertEqual(projects.count, 1)
        
        let project = try XCTUnwrap(projects[safe: 0])
        XCTAssertEqual(project.name, "Test Project")
        XCTAssertEqual(project.startTimecode, Self.tc("01:00:00:00", .fps29_97))
        
        // sequence
        
        let sequence = try XCTUnwrap(projects[safe: 0]?.sequence?.fcpAsSequence)
        XCTAssertEqual(sequence.format, "r1")
        XCTAssertEqual(sequence.tcStartAsTimecode, Self.tc("01:00:00:00", .fps29_97))
        XCTAssertEqual(sequence.tcStartAsTimecode?.frameRate, .fps29_97)
        XCTAssertEqual(sequence.tcStartAsTimecode?.subFramesBase, .max80SubFrames)
        XCTAssertEqual(sequence.durationAsTimecode, Self.tc("00:01:03:29", .fps29_97))
        XCTAssertEqual(sequence.audioLayout, .stereo)
        XCTAssertEqual(sequence.audioRate, .rate48kHz)
        
        // story elements (clips etc.)
        
        let spine = try XCTUnwrap(sequence.spine.fcpAsSpine)
        XCTAssertEqual(spine.storyElements.count, 1)
        
        let element1 = try XCTUnwrap(spine.storyElements[safe: 0]?.fcpAsTitle)
        XCTAssertEqual(element1.ref, "r2")
        XCTAssertEqual(element1.offsetAsTimecode, Self.tc("01:00:00:00", .fps29_97))
        XCTAssertEqual(element1.offsetAsTimecode?.frameRate, .fps29_97)
        XCTAssertEqual(element1.name, "Basic Title")
        XCTAssertEqual(element1.startAsTimecode, Self.tc("00:10:00:00", .fps29_97))
        XCTAssertEqual(element1.startAsTimecode?.frameRate, .fps29_97)
        XCTAssertEqual(element1.durationAsTimecode, Self.tc("00:01:03:29", .fps29_97))
        XCTAssertEqual(element1.durationAsTimecode?.frameRate, .fps29_97)
        
        // markers
        
        // TODO: make this a more convenient global method
        let markers = element1.contents.filter {
            $0.fcpElementType == .story(.annotation(.marker(.marker))) ||
            $0.fcpElementType == .story(.annotation(.marker(.chapterMarker)))
        }
        
        XCTAssertEqual(markers.count, 4)
        
        #warning("> TODO: finish this - but can't test absolute timecodes without running element extraction")
//        let expectedMarker0 = FinalCutPro.FCPXML.Marker(
//            start: Self.tc("01:00:29:14", .fps29_97),
//            duration: Self.tc("00:00:00:01", .fps29_97),
//            name: "Standard Marker",
//            metaData: .standard,
//            note: "some notes here"
//        )
//        XCTAssertEqual(markers[safe: 0], expectedMarker0)
//        
//        let expectedMarker1 = FinalCutPro.FCPXML.Marker(
//            start: Self.tc("01:00:29:15", .fps29_97),
//            duration: Self.tc("00:00:00:01", .fps29_97),
//            name: "To Do Marker, Incomplete",
//            metaData: .toDo(completed: false),
//            note: "more notes here"
//        )
//        XCTAssertEqual(markers[safe: 1], expectedMarker1)
//        
//        let expectedMarker2 = FinalCutPro.FCPXML.Marker(
//            start: Self.tc("01:00:29:16", .fps29_97),
//            duration: Self.tc("00:00:00:01", .fps29_97),
//            name: "To Do Marker, Completed",
//            metaData: .toDo(completed: true),
//            note: "notes yay"
//        )
//        XCTAssertEqual(markers[safe: 2], expectedMarker2)
//        
//        let expectedMarker3 = FinalCutPro.FCPXML.Marker(
//            start: Self.tc("01:00:29:17", .fps29_97),
//            duration: Self.tc("00:00:00:01", .fps29_97),
//            name: "Chapter Marker",
//            metaData: .chapter(posterOffset: .init(Self.tc("00:00:00:10.79", .fps29_97))),
//            note: nil
//        )
//        XCTAssertEqual(markers[safe: 3], expectedMarker3)
    }
}

#endif
