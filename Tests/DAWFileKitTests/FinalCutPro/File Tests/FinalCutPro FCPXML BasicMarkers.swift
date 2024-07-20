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

final class FinalCutPro_FCPXML_BasicMarkers: FCPXMLTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try XCTUnwrap(loadFileContents(
            forResource: "BasicMarkers",
            withExtension: "fcpxml",
            subFolder: .fcpxmlExports
        ))
    } }
    
    // MARK: - Tests
    
    func testParse() throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // version
        XCTAssertEqual(fcpxml.version, .ver1_9)
        
        // resources (from XML document)
        
        // make sure these aren't nil and they point to the expected elements
        let root = try XCTUnwrap(fcpxml.xml.rootElement()) // `fcpxml` element
        XCTAssertEqual(root, try XCTUnwrap(fcpxml.xml.rootElement()?.fcpRoot))
        XCTAssertEqual(root, try XCTUnwrap(fcpxml.root.element))
        
        // resources (from model)
        
        let resources = fcpxml.root.resources
        let xml_resources = try XCTUnwrap(fcpxml.xml.rootElement()?.fcpRootResources)
        // make sure these aren't nil and they point to the expected elements
        XCTAssertEqual(resources, xml_resources)
        
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
        
        let library = try XCTUnwrap(fcpxml.root.library)
        
        let libraryURL = URL(string: "file:///Users/user/Movies/MyLibrary.fcpbundle/")
        XCTAssertEqual(library.name, "MyLibrary")
        XCTAssertEqual(library.location, libraryURL)
        XCTAssertEqual(library.events.count, 1)
        
        // events
        
        let events = fcpxml.allEvents()
        XCTAssertEqual(events.count, 1)
        
        let event = try XCTUnwrap(events.zeroIndexed[safe: 0])
        XCTAssertEqual(event.name, "Test Event")
        
        // projects
        
        let projects = event.projects.zeroIndexed
        XCTAssertEqual(projects.count, 1)
        
        let project = try XCTUnwrap(projects[safe: 0])
        XCTAssertEqual(project.name, "Test Project")
        XCTAssertEqual(project.startTimecode(), Self.tc("00:00:00:00", .fps29_97))
        
        // sequence
        
        let sequence = try XCTUnwrap(project.sequence)
        XCTAssertEqual(sequence.format, "r1")
        XCTAssertEqual(sequence.tcStartAsTimecode(), Self.tc("00:00:00:00", .fps29_97))
        XCTAssertEqual(sequence.tcStartAsTimecode()?.frameRate, .fps29_97)
        XCTAssertEqual(sequence.tcStartAsTimecode()?.subFramesBase, .max80SubFrames)
        XCTAssertEqual(sequence.durationAsTimecode(), Self.tc("00:01:03:29", .fps29_97))
        XCTAssertEqual(sequence.audioLayout, .stereo)
        XCTAssertEqual(sequence.audioRate, .rate48kHz)
        
        // story elements (clips etc.)
        
        let spine = try XCTUnwrap(sequence.spine)
        XCTAssertEqual(spine.storyElements.count, 1)
        
        let storyElements = spine.storyElements.zeroIndexed
        
        let element1 = try XCTUnwrap(storyElements[safe: 0]?.fcpAsTitle)
        XCTAssertEqual(element1.ref, "r2")
        XCTAssertEqual(element1.name, "Basic Title")
        XCTAssertEqual(element1.offsetAsTimecode(), Self.tc("00:00:00:00", .fps29_97))
        XCTAssertEqual(element1.offsetAsTimecode()?.frameRate, .fps29_97)
        XCTAssertEqual(element1.startAsTimecode(), Self.tc("00:10:00:00", .fps29_97))
        XCTAssertEqual(element1.startAsTimecode()?.frameRate, .fps29_97)
        XCTAssertEqual(element1.durationAsTimecode(), Self.tc("00:01:03:29", .fps29_97))
        XCTAssertEqual(element1.durationAsTimecode()?.frameRate, .fps29_97)
        
        // markers
        
        let markers = element1.contents
            .filter(whereFCPElement: .marker)
            .zeroIndexed
        
        XCTAssertEqual(markers.count, 4)
    }
    
    func testExtractMarkers() async throws {
        // load file
        let rawData = try fileContents
        
        // load
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // project
        let project = try XCTUnwrap(fcpxml.allProjects().first)
        
        var scope = FinalCutPro.FCPXML.ExtractionScope.mainTimeline
        scope.occlusions = .allCases
        
        // clips
        
        let clips = await project
            .extract(types: [.title], scope: .mainTimeline)
        let clip = try XCTUnwrap(clips.first)
        XCTAssertEqual(clip.element.fcpName, "Basic Title")
        // test timecode for both main timeline and local timeline
        XCTAssertEqual(
            clip.value(forContext: .absoluteStartAsTimecode(frameRateSource: .mainTimeline)),
            Self.tc("00:00:00:00", .fps29_97)
        )
        XCTAssertEqual(
            clip.value(forContext: .absoluteStartAsTimecode(frameRateSource: .localToElement)),
            Self.tc("00:10:00:00", .fps29_97)
        )
        XCTAssertEqual(
            clip.value(forContext: .absoluteEndAsTimecode(frameRateSource: .mainTimeline)),
            Self.tc("00:01:03:29", .fps29_97)
        )
        XCTAssertEqual(
            clip.value(forContext: .absoluteEndAsTimecode(frameRateSource: .localToElement)),
            Self.tc("00:11:03:29", .fps29_97)
        )
        
        // markers
        
        let extractedMarkers = await project
            .extract(preset: .markers, scope: scope)
            .sortedByAbsoluteStartTimecode()
        // .zeroIndexed // not necessary after sorting - sort returns new array
        
        // note that all these markers are past the end of the clip (occluded)
        XCTAssertEqual(extractedMarkers.count, 4)
        
        let marker0 = try XCTUnwrap(extractedMarkers[safe: 0])
        let marker1 = try XCTUnwrap(extractedMarkers[safe: 1])
        let marker2 = try XCTUnwrap(extractedMarkers[safe: 2])
        let marker3 = try XCTUnwrap(extractedMarkers[safe: 3])
        
        // test timecode for both main timeline and local timeline
        // main timeline start: 00:00:00:00
        // local clip timeline start: 00:10:00:00
        
        XCTAssertEqual(marker0.timecode(frameRateSource: .mainTimeline), Self.tc("00:50:29:14", .fps29_97))
        XCTAssertEqual(marker0.timecode(frameRateSource: .localToElement), Self.tc("01:00:29:14", .fps29_97))
        
        XCTAssertEqual(marker1.timecode(frameRateSource: .mainTimeline), Self.tc("00:50:29:15", .fps29_97))
        XCTAssertEqual(marker1.timecode(frameRateSource: .localToElement), Self.tc("01:00:29:15", .fps29_97))
        
        XCTAssertEqual(marker2.timecode(frameRateSource: .mainTimeline), Self.tc("00:50:29:16", .fps29_97))
        XCTAssertEqual(marker2.timecode(frameRateSource: .localToElement), Self.tc("01:00:29:16", .fps29_97))
        
        XCTAssertEqual(marker3.timecode(frameRateSource: .mainTimeline), Self.tc("00:50:29:17", .fps29_97))
        XCTAssertEqual(marker3.timecode(frameRateSource: .localToElement), Self.tc("01:00:29:17", .fps29_97))
    }
}

#endif
