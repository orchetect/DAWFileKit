//
//  FinalCutPro FCPXML TransitionMarkers2.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
@testable import DAWFileKit
import SwiftExtensions
import TimecodeKit

final class FinalCutPro_FCPXML_TransitionMarkers2: FCPXMLTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try XCTUnwrap(loadFileContents(
            forResource: "TransitionMarkers2",
            withExtension: "fcpxml",
            subFolder: .fcpxmlExports
        ))
    } }
    
    /// Project @ 24fps.
    let projectFrameRate: TimecodeFrameRate = .fps24
    
    func testParse() throws {
        // load
        let rawData = try fileContents
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // version
        XCTAssertEqual(fcpxml.version, .ver1_13)
        
        // event
        let events = fcpxml.allEvents()
        XCTAssertEqual(events.count, 1)
        
        let event = try XCTUnwrap(events[safe: 0])
        XCTAssertEqual(event.name, "Test Event")
        
        // project
        let projects = event.projects.zeroIndexed
        XCTAssertEqual(projects.count, 1)
        
        let project = try XCTUnwrap(projects[safe: 0])
        
        // sequence
        let sequence = try XCTUnwrap(project.sequence)
        
        // spine
        let spine = try XCTUnwrap(sequence.spine)
        
        let storyElements = spine.storyElements.zeroIndexed
        XCTAssertEqual(storyElements.count, 4)
        
        // story elements
        
        let transitionClip1 = try XCTUnwrap(storyElements[safe: 0]?.fcpAsTransition)
        XCTAssertEqual(transitionClip1.name, "Cross Dissolve")
        XCTAssertEqual(transitionClip1.offsetAsTimecode(), Self.tc("01:00:00:00", projectFrameRate))
        XCTAssertEqual(transitionClip1.offsetAsTimecode()?.frameRate, projectFrameRate)
        XCTAssertEqual(transitionClip1.timelineStartAsTimecode(), Self.tc("01:00:00:00", projectFrameRate))
        XCTAssertEqual(transitionClip1.durationAsTimecode(), Self.tc("00:00:02:00", projectFrameRate))
        XCTAssertEqual(transitionClip1.durationAsTimecode()?.frameRate, projectFrameRate)
        
        let titleClip1 = try XCTUnwrap(storyElements[safe: 1]?.fcpAsTitle)
        
        let transitionClip2 = try XCTUnwrap(storyElements[safe: 2]?.fcpAsTransition)
        XCTAssertEqual(transitionClip2.name, "Band")
        XCTAssertEqual(transitionClip2.offsetAsTimecode(), Self.tc("01:00:09:13", projectFrameRate))
        XCTAssertEqual(transitionClip2.offsetAsTimecode()?.frameRate, projectFrameRate)
        XCTAssertEqual(transitionClip2.durationAsTimecode(), Self.tc("00:00:01:00", projectFrameRate))
        XCTAssertEqual(transitionClip2.durationAsTimecode()?.frameRate, projectFrameRate)
        
        let titleClip2 = try XCTUnwrap(storyElements[safe: 3]?.fcpAsTitle)
        
        // transition clip 1 markers
        
        let trs1StoryElements = transitionClip1.storyElements
        let trs1Marker1 = try XCTUnwrap(trs1StoryElements[1].fcpAsMarker)
        XCTAssertEqual(trs1Marker1.name, "Marker 1")
        XCTAssertEqual(trs1Marker1.start, Fraction(3600, 1))
        XCTAssertEqual(trs1Marker1.startAsTimecode(), Self.tc("01:00:00:00", projectFrameRate)) // start attr, not absolute
        XCTAssertEqual(trs1Marker1.startAsTimecode()?.frameRate, projectFrameRate)
        let trs1Marker2 = try XCTUnwrap(trs1StoryElements[2].fcpAsMarker)
        XCTAssertEqual(trs1Marker2.name, "Marker 2")
        XCTAssertEqual(trs1Marker2.startAsTimecode(), Self.tc("01:00:00:12", projectFrameRate)) // start attr, not absolute
        let trs1Marker3 = try XCTUnwrap(trs1StoryElements[3].fcpAsMarker)
        XCTAssertEqual(trs1Marker3.name, "Marker 3")
        XCTAssertEqual(trs1Marker3.startAsTimecode(), Self.tc("01:00:01:23", projectFrameRate)) // start attr, not absolute
        
        let clip1StoryElements = titleClip1.storyElements
        let clip1Marker1 = try XCTUnwrap(clip1StoryElements[2].fcpAsMarker)
        XCTAssertEqual(clip1Marker1.name, "Marker 4")
        XCTAssertEqual(clip1Marker1.startAsTimecode(), Self.tc("01:00:02:00", projectFrameRate)) // start attr, happens to be absolute
        XCTAssertEqual(clip1Marker1.startAsTimecode()?.frameRate, projectFrameRate)
        let clip1Marker2 = try XCTUnwrap(clip1StoryElements[3].fcpAsMarker)
        XCTAssertEqual(clip1Marker2.name, "Marker 5")
        XCTAssertEqual(clip1Marker2.startAsTimecode(), Self.tc("01:00:02:01", projectFrameRate)) // start attr, happens to be absolute
        let clip1Marker3 = try XCTUnwrap(clip1StoryElements[4].fcpAsMarker)
        XCTAssertEqual(clip1Marker3.name, "Marker 6")
        XCTAssertEqual(clip1Marker3.startAsTimecode(), Self.tc("01:00:09:12", projectFrameRate)) // start attr, happens to be absolute
        
        let trs2StoryElements = transitionClip2.storyElements
        let trs2Marker1 = try XCTUnwrap(trs2StoryElements[1].fcpAsMarker)
        XCTAssertEqual(trs2Marker1.name, "Marker 7")
        XCTAssertEqual(trs2Marker1.startAsTimecode(), Self.tc("01:00:00:00", projectFrameRate)) // start attr, not absolute
        XCTAssertEqual(trs2Marker1.startAsTimecode()?.frameRate, projectFrameRate)
        let trs2Marker2 = try XCTUnwrap(trs2StoryElements[2].fcpAsMarker)
        XCTAssertEqual(trs2Marker2.name, "Marker 8")
        XCTAssertEqual(trs2Marker2.startAsTimecode(), Self.tc("01:00:00:01", projectFrameRate)) // start attr, not absolute
        
        let clip2StoryElements = titleClip2.storyElements
        let clip2Marker1 = try XCTUnwrap(clip2StoryElements[3].fcpAsMarker)
        XCTAssertEqual(clip2Marker1.name, "Marker 9")
        XCTAssertEqual(clip2Marker1.startAsTimecode(), Self.tc("01:00:00:12", projectFrameRate)) // start attr, with 1-frame clip offset
        XCTAssertEqual(clip2Marker1.startAsTimecode()?.frameRate, projectFrameRate)
        let clip2Marker2 = try XCTUnwrap(clip2StoryElements[4].fcpAsMarker)
        XCTAssertEqual(clip2Marker2.name, "Marker 10")
        XCTAssertEqual(clip2Marker2.startAsTimecode(), Self.tc("01:00:00:13", projectFrameRate)) // start attr, with 1-frame clip offset
    }
    
    func testExtractMarkers() async throws {
        // load file
        let rawData = try fileContents
        
        // load
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // project
        let project = try XCTUnwrap(fcpxml.allProjects().first)
        
        let extractedMarkers = await project
            .extract(preset: .markers, scope: .mainTimeline)
            .sortedByAbsoluteStartTimecode()
            // .zeroIndexed // not necessary after sorting - sort returns new array
        
        let markers = extractedMarkers
        
        let expectedMarkerCount = 10
        XCTAssertEqual(markers.count, expectedMarkerCount)
        
        print("Markers sorted by absolute timecode:")
        print(Self.debugString(for: markers))
        
        let marker1 = try XCTUnwrap(markers[safe: 0])
        XCTAssertEqual(marker1.name, "Marker 1")
        XCTAssertEqual(marker1.timecode(), Self.tc("01:00:00:00", projectFrameRate))
        XCTAssertEqual(marker1.timecode()?.frameRate, projectFrameRate)
        
        let marker2 = try XCTUnwrap(markers[safe: 1])
        XCTAssertEqual(marker2.name, "Marker 2")
        XCTAssertEqual(marker2.timecode(), Self.tc("01:00:00:12", projectFrameRate))
        
        let marker3 = try XCTUnwrap(markers[safe: 2])
        XCTAssertEqual(marker3.name, "Marker 3")
        XCTAssertEqual(marker3.timecode(), Self.tc("01:00:01:23", projectFrameRate))
        
        let marker4 = try XCTUnwrap(markers[safe: 3])
        XCTAssertEqual(marker4.name, "Marker 4")
        XCTAssertEqual(marker4.timecode(), Self.tc("01:00:02:00", projectFrameRate))
        
        let marker5 = try XCTUnwrap(markers[safe: 4])
        XCTAssertEqual(marker5.name, "Marker 5")
        XCTAssertEqual(marker5.timecode(), Self.tc("01:00:02:01", projectFrameRate))
        
        let marker6 = try XCTUnwrap(markers[safe: 5])
        XCTAssertEqual(marker6.name, "Marker 6")
        XCTAssertEqual(marker6.timecode(), Self.tc("01:00:09:12", projectFrameRate))
        
        let marker7 = try XCTUnwrap(markers[safe: 6])
        XCTAssertEqual(marker7.name, "Marker 7")
        XCTAssertEqual(marker7.timecode(), Self.tc("01:00:09:13", projectFrameRate))
        
        let marker8 = try XCTUnwrap(markers[safe: 7])
        XCTAssertEqual(marker8.name, "Marker 8")
        XCTAssertEqual(marker8.timecode(), Self.tc("01:00:09:14", projectFrameRate))
        
        let marker9 = try XCTUnwrap(markers[safe: 8])
        XCTAssertEqual(marker9.name, "Marker 9")
        XCTAssertEqual(marker9.timecode(), Self.tc("01:00:10:13", projectFrameRate))
        
        let marker10 = try XCTUnwrap(markers[safe: 9])
        XCTAssertEqual(marker10.name, "Marker 10")
        XCTAssertEqual(marker10.timecode(), Self.tc("01:00:10:14", projectFrameRate))
    }
}

#endif
