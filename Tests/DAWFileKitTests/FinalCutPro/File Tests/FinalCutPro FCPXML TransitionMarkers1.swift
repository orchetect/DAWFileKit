//
//  FinalCutPro FCPXML TransitionMarkers1.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
@testable import DAWFileKit
import OTCore
import TimecodeKit

final class FinalCutPro_FCPXML_TransitionMarkers1: FCPXMLTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try XCTUnwrap(loadFileContents(
            forResource: "TransitionMarkers1",
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
        XCTAssertEqual(storyElements.count, 7)
        
        // story elements
        
        // (start of timeline)
        let transitionClip1 = try XCTUnwrap(storyElements[safe: 0]?.fcpAsTransition)
        XCTAssertEqual(transitionClip1.name, "Cross Dissolve")
        XCTAssertEqual(transitionClip1.offsetAsTimecode(), Self.tc("01:00:00:00", projectFrameRate))
        XCTAssertEqual(transitionClip1.offsetAsTimecode()?.frameRate, projectFrameRate)
        XCTAssertEqual(transitionClip1.timelineStartAsTimecode(), Self.tc("01:00:00:00", projectFrameRate))
        XCTAssertEqual(transitionClip1.durationAsTimecode(), Self.tc("00:00:01:00", projectFrameRate))
        XCTAssertEqual(transitionClip1.durationAsTimecode()?.frameRate, projectFrameRate)
        
        let titleClip1 = try XCTUnwrap(storyElements[safe: 1]?.fcpAsTitle)
        XCTAssertEqual(titleClip1.startAsTimecode(), Self.tc("01:00:00:00", projectFrameRate))
        XCTAssertEqual(titleClip1.startAsTimecode()?.frameRate, projectFrameRate)
        XCTAssertEqual(titleClip1.offsetAsTimecode(), Self.tc("01:00:00:00", projectFrameRate))
        XCTAssertEqual(titleClip1.offsetAsTimecode()?.frameRate, projectFrameRate)
        
        let transitionClip2 = try XCTUnwrap(storyElements[safe: 2]?.fcpAsTransition)
        XCTAssertEqual(transitionClip2.name, "Cross Dissolve")
        XCTAssertEqual(transitionClip2.offsetAsTimecode(), Self.tc("01:00:09:12", projectFrameRate))
        XCTAssertEqual(transitionClip2.offsetAsTimecode()?.frameRate, projectFrameRate)
        XCTAssertEqual(transitionClip2.durationAsTimecode(), Self.tc("00:00:01:00", projectFrameRate))
        XCTAssertEqual(transitionClip2.durationAsTimecode()?.frameRate, projectFrameRate)
        
        let titleClip2 = try XCTUnwrap(storyElements[safe: 3]?.fcpAsTitle)
        XCTAssertEqual(titleClip2.startAsTimecode(), Self.tc("01:00:00:00", projectFrameRate))
        XCTAssertEqual(titleClip2.startAsTimecode()?.frameRate, projectFrameRate)
        XCTAssertEqual(titleClip2.offsetAsTimecode(), Self.tc("01:00:10:00", projectFrameRate))
        XCTAssertEqual(titleClip2.offsetAsTimecode()?.frameRate, projectFrameRate)
        
        let transitionClip3 = try XCTUnwrap(storyElements[safe: 4]?.fcpAsTransition)
        XCTAssertEqual(transitionClip3.name, "Cross Dissolve")
        XCTAssertEqual(transitionClip3.offsetAsTimecode(), Self.tc("01:00:19:12", projectFrameRate))
        XCTAssertEqual(transitionClip3.offsetAsTimecode()?.frameRate, projectFrameRate)
        XCTAssertEqual(transitionClip3.durationAsTimecode(), Self.tc("00:00:01:00", projectFrameRate))
        XCTAssertEqual(transitionClip3.durationAsTimecode()?.frameRate, projectFrameRate)
        
        let titleClip3 = try XCTUnwrap(storyElements[safe: 5]?.fcpAsTitle)
        XCTAssertEqual(titleClip3.startAsTimecode(), Self.tc("01:00:00:00", projectFrameRate))
        XCTAssertEqual(titleClip3.startAsTimecode()?.frameRate, projectFrameRate)
        XCTAssertEqual(titleClip3.offsetAsTimecode(), Self.tc("01:00:20:00", projectFrameRate))
        XCTAssertEqual(titleClip3.offsetAsTimecode()?.frameRate, projectFrameRate)
        
        // (end of timeline)
        let transitionClip4 = try XCTUnwrap(storyElements[safe: 6]?.fcpAsTransition)
        XCTAssertEqual(transitionClip4.name, "Cross Dissolve")
        XCTAssertEqual(transitionClip4.offsetAsTimecode(), Self.tc("01:00:29:00", projectFrameRate))
        XCTAssertEqual(transitionClip4.offsetAsTimecode()?.frameRate, projectFrameRate)
        XCTAssertEqual(transitionClip4.durationAsTimecode(), Self.tc("00:00:01:00", projectFrameRate))
        XCTAssertEqual(transitionClip4.durationAsTimecode()?.frameRate, projectFrameRate)
        
        // transition clip 1 markers
        
        let trs1StoryElements = transitionClip1.storyElements
        let trs1Marker1 = try XCTUnwrap(trs1StoryElements[1].fcpAsMarker)
        XCTAssertEqual(trs1Marker1.name, "Marker 1")
        XCTAssertEqual(trs1Marker1.start, Fraction(3600, 1))
        XCTAssertEqual(trs1Marker1.startAsTimecode(), Self.tc("01:00:00:00", projectFrameRate)) // start attr, not absolute
        XCTAssertEqual(trs1Marker1.startAsTimecode()?.frameRate, projectFrameRate)
        XCTAssertEqual(trs1Marker1.element._fcpCalculateAbsoluteStart(), 3600.0)
        let trs1Marker2 = try XCTUnwrap(trs1StoryElements[2].fcpAsMarker)
        XCTAssertEqual(trs1Marker2.name, "Marker 2")
        XCTAssertEqual(trs1Marker2.startAsTimecode(), Self.tc("01:00:00:12", projectFrameRate)) // start attr, not absolute
        XCTAssertEqual(trs1Marker2.element._fcpCalculateAbsoluteStart(), 3600.5)
        
        let clip1StoryElements = titleClip1.storyElements
        let clip1Marker1 = try XCTUnwrap(clip1StoryElements[2].fcpAsMarker)
        XCTAssertEqual(clip1Marker1.name, "Marker 3")
        XCTAssertEqual(clip1Marker1.startAsTimecode(), Self.tc("01:00:01:00", projectFrameRate)) // start attr, not absolute
        XCTAssertEqual(clip1Marker1.startAsTimecode()?.frameRate, projectFrameRate)
        XCTAssertEqual(clip1Marker1.element._fcpCalculateAbsoluteStart(), 3601.0)
        
        let trs2StoryElements = transitionClip2.storyElements
        let trs2Marker1 = try XCTUnwrap(trs2StoryElements[1].fcpAsMarker)
        XCTAssertEqual(trs2Marker1.name, "Marker 4")
        XCTAssertEqual(trs2Marker1.startAsTimecode(), Self.tc("01:00:00:00", projectFrameRate)) // start attr, not absolute
        XCTAssertEqual(trs2Marker1.startAsTimecode()?.frameRate, projectFrameRate)
        XCTAssertEqual(trs2Marker1.element._fcpCalculateAbsoluteStart(), 3609.5)
        let trs2Marker2 = try XCTUnwrap(trs2StoryElements[2].fcpAsMarker)
        XCTAssertEqual(trs2Marker2.name, "Marker 5")
        XCTAssertEqual(trs2Marker2.startAsTimecode(), Self.tc("01:00:00:12", projectFrameRate)) // start attr, not absolute
        XCTAssertEqual(trs2Marker2.element._fcpCalculateAbsoluteStart(), 3610.0)
        
        let clip2StoryElements = titleClip2.storyElements
        let clip2Marker1 = try XCTUnwrap(clip2StoryElements[2].fcpAsMarker)
        XCTAssertEqual(clip2Marker1.name, "Marker 6")
        XCTAssertEqual(clip2Marker1.startAsTimecode(), Self.tc("01:00:00:12", projectFrameRate)) // start attr, not absolute
        XCTAssertEqual(clip2Marker1.startAsTimecode()?.frameRate, projectFrameRate)
        XCTAssertEqual(clip2Marker1.element._fcpCalculateAbsoluteStart(), 3610.5)
        
        let trs3StoryElements = transitionClip3.storyElements
        let trs3Marker1 = try XCTUnwrap(trs3StoryElements[1].fcpAsMarker)
        XCTAssertEqual(trs3Marker1.name, "Marker 7")
        XCTAssertEqual(trs3Marker1.startAsTimecode(), Self.tc("01:00:00:00", projectFrameRate)) // start attr, not absolute
        XCTAssertEqual(trs3Marker1.startAsTimecode()?.frameRate, projectFrameRate)
        XCTAssertEqual(trs3Marker1.element._fcpCalculateAbsoluteStart(), 3619.5)
        let trs3Marker2 = try XCTUnwrap(trs3StoryElements[2].fcpAsMarker)
        XCTAssertEqual(trs3Marker2.name, "Marker 8")
        XCTAssertEqual(trs3Marker2.startAsTimecode(), Self.tc("01:00:00:12", projectFrameRate)) // start attr, not absolute
        XCTAssertEqual(trs3Marker2.element._fcpCalculateAbsoluteStart(), 3620.0)
        
        let clip3StoryElements = titleClip3.storyElements
        let clip3Marker1 = try XCTUnwrap(clip3StoryElements[2].fcpAsMarker)
        XCTAssertEqual(clip3Marker1.name, "Marker 9")
        XCTAssertEqual(clip3Marker1.startAsTimecode(), Self.tc("01:00:00:12", projectFrameRate)) // start attr, not absolute
        XCTAssertEqual(clip3Marker1.startAsTimecode()?.frameRate, projectFrameRate)
        XCTAssertEqual(clip3Marker1.element._fcpCalculateAbsoluteStart(), 3620.5)
        
        let trs4StoryElements = transitionClip4.storyElements
        let trs4Marker1 = try XCTUnwrap(trs4StoryElements[1].fcpAsMarker)
        XCTAssertEqual(trs4Marker1.name, "Marker 10")
        XCTAssertEqual(trs4Marker1.startAsTimecode(), Self.tc("01:00:00:00", projectFrameRate)) // start attr, not absolute
        XCTAssertEqual(trs4Marker1.startAsTimecode()?.frameRate, projectFrameRate)
        XCTAssertEqual(trs4Marker1.element._fcpCalculateAbsoluteStart(), 3629.0)
        let trs4Marker2 = try XCTUnwrap(trs4StoryElements[2].fcpAsMarker)
        XCTAssertEqual(trs4Marker2.name, "Marker 11")
        XCTAssertEqual(trs4Marker2.startAsTimecode(), Self.tc("01:00:00:12", projectFrameRate)) // start attr, not absolute
        XCTAssertEqual(trs4Marker2.element._fcpCalculateAbsoluteStart(), 3629.5)
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
        
        let expectedMarkerCount = 11
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
        XCTAssertEqual(marker3.timecode(), Self.tc("01:00:01:00", projectFrameRate))
        
        let marker4 = try XCTUnwrap(markers[safe: 3])
        XCTAssertEqual(marker4.name, "Marker 4")
        XCTAssertEqual(marker4.timecode(), Self.tc("01:00:09:12", projectFrameRate))
        
        let marker5 = try XCTUnwrap(markers[safe: 4])
        XCTAssertEqual(marker5.name, "Marker 5")
        XCTAssertEqual(marker5.timecode(), Self.tc("01:00:10:00", projectFrameRate))
        
        let marker6 = try XCTUnwrap(markers[safe: 5])
        XCTAssertEqual(marker6.name, "Marker 6")
        XCTAssertEqual(marker6.timecode(), Self.tc("01:00:10:12", projectFrameRate))
        
        let marker7 = try XCTUnwrap(markers[safe: 6])
        XCTAssertEqual(marker7.name, "Marker 7")
        XCTAssertEqual(marker7.timecode(), Self.tc("01:00:19:12", projectFrameRate))
        
        let marker8 = try XCTUnwrap(markers[safe: 7])
        XCTAssertEqual(marker8.name, "Marker 8")
        XCTAssertEqual(marker8.timecode(), Self.tc("01:00:20:00", projectFrameRate))
        
        let marker9 = try XCTUnwrap(markers[safe: 8])
        XCTAssertEqual(marker9.name, "Marker 9")
        XCTAssertEqual(marker9.timecode(), Self.tc("01:00:20:12", projectFrameRate))
        
        let marker10 = try XCTUnwrap(markers[safe: 9])
        XCTAssertEqual(marker10.name, "Marker 10")
        XCTAssertEqual(marker10.timecode(), Self.tc("01:00:29:00", projectFrameRate))
        
        let marker11 = try XCTUnwrap(markers[safe: 10])
        XCTAssertEqual(marker11.name, "Marker 11")
        XCTAssertEqual(marker11.timecode(), Self.tc("01:00:29:12", projectFrameRate))
    }
}

#endif
