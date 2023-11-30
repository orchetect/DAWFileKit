//
//  FinalCutPro FCPXML MulticamMarkers2.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
@testable import DAWFileKit
import OTCore
import TimecodeKit

final class FinalCutPro_FCPXML_MulticamMarkers2: FCPXMLTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try XCTUnwrap(loadFileContents(
            forResource: "MulticamMarkers2",
            withExtension: "fcpxml",
            subFolder: .fcpxmlExports
        ))
    } }
    
    func testParse() throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // resources
        // let resources = fcpxml.resources()
        
        // events
        let events = fcpxml.allEvents()
        XCTAssertEqual(events.count, 1)
        
        let event = try XCTUnwrap(events[safe: 0])
        XCTAssertEqual(event.name, "Test Event")
        XCTAssertEqual(event.context[.occlusion], .notOccluded)
        
        // projects
        let projects = event.projects
        XCTAssertEqual(projects.count, 1)
        
        let project = try XCTUnwrap(projects.first)
        XCTAssertEqual(project.context[.occlusion], .notOccluded)
        
        // sequence
        let sequence = project.sequence
        XCTAssertEqual(sequence.context[.occlusion], .notOccluded)
        
        // spine
        let spine = sequence.spine
        XCTAssertEqual(spine.contents.count, 1)
        
        // mc-clip
        
        guard case let .anyClip(.mcClip(mcClip)) = spine.contents[safe: 0]
        else { XCTFail("Clip was not expected type.") ; return }
        
        XCTAssertEqual(mcClip.ref, "r2")
        XCTAssertEqual(mcClip.lane, nil)
        XCTAssertEqual(mcClip.offset, Self.tc("01:00:00:00", .fps23_976))
        XCTAssertEqual(mcClip.offset?.frameRate, .fps23_976)
        XCTAssertEqual(mcClip.name, "MC")
        XCTAssertEqual(mcClip.start, Self.tc("00:00:13:01", .fps23_976))
        XCTAssertEqual(mcClip.duration, Self.tc("00:00:10:00", .fps23_976))
        XCTAssertEqual(mcClip.duration?.frameRate, .fps23_976)
        XCTAssertEqual(mcClip.enabled, true)
        XCTAssertEqual(mcClip.context[.absoluteStart], Self.tc("01:00:00:00", .fps23_976))
        XCTAssertEqual(mcClip.context[.occlusion], .notOccluded)
        XCTAssertEqual(mcClip.context[.effectiveOcclusion], .notOccluded)
        XCTAssertEqual(mcClip.context[.localRoles], [
            .audio(raw: "music.music-1")!,
            .video(raw: "Custom Video Role.Custom Video Role A")!
        ])
        XCTAssertEqual(mcClip.context[.inheritedRoles], [
            .inherited(.audio(raw: "music.music-1")!),
            .inherited(.video(raw: "Custom Video Role.Custom Video Role A")!)
        ])
        
        // mc-clip multicam media
        
        let mc = mcClip.multicam
        
        XCTAssertEqual(mc.format, "r1")
        XCTAssertEqual(mc.tcStart, Self.tc("00:00:00:00", .fps23_976))
        XCTAssertEqual(mc.angles.count, 6)
        
        // multicam media angles
        
        let mcAngle1 = try XCTUnwrap(mc.angles[safe: 0])
        XCTAssertEqual(mcAngle1.name, "A")
        XCTAssertEqual(mcAngle1.angleID, "+L5xmXXnRXOGdjFq1Eo7EQ")
        XCTAssertEqual(mcAngle1.contents.count, 2)
        
        let mcAngle2 = try XCTUnwrap(mc.angles[safe: 1])
        XCTAssertEqual(mcAngle2.name, "B")
        XCTAssertEqual(mcAngle2.angleID, "FCw5EnkUQcOHu8fwK2TiQQ")
        XCTAssertEqual(mcAngle2.contents.count, 2)
        
        let mcAngle3 = try XCTUnwrap(mc.angles[safe: 2])
        XCTAssertEqual(mcAngle3.name, "C")
        XCTAssertEqual(mcAngle3.angleID, "LphqqelgRX6/pXqi35MoGA")
        XCTAssertEqual(mcAngle3.contents.count, 2)
        
        let mcAngle4 = try XCTUnwrap(mc.angles[safe: 3])
        XCTAssertEqual(mcAngle4.name, "D")
        XCTAssertEqual(mcAngle4.angleID, "gA31yYbYRRSetqQyxAwC8g")
        XCTAssertEqual(mcAngle4.contents.count, 2)
        
        let mcAngle5 = try XCTUnwrap(mc.angles[safe: 4])
        XCTAssertEqual(mcAngle5.name, "Music Angle")
        XCTAssertEqual(mcAngle5.angleID, "9jilYFZRQZ+GI27X4ckxpQ")
        XCTAssertEqual(mcAngle5.contents.count, 1)
        
        let mcAngle6 = try XCTUnwrap(mc.angles[safe: 5])
        XCTAssertEqual(mcAngle6.name, "Sound FX Angle")
        XCTAssertEqual(mcAngle6.angleID, "u6FMsIKMT/eATN52hY2/rA")
        XCTAssertEqual(mcAngle6.contents.count, 2)
        
        // mc-clip marker on main timeline
        
        let mc1Markers = mcClip.contents.annotations().markers()
        XCTAssertEqual(mc1Markers.count, 1)
        
        let mc1Marker = try XCTUnwrap(mc1Markers[safe: 0])
        XCTAssertEqual(mc1Marker.name, "Marker on Multicam Clip")
        XCTAssertEqual(mc1Marker.context[.absoluteStart], Self.tc("01:00:04:08", .fps23_976))
        XCTAssertEqual(mc1Marker.context[.occlusion], .notOccluded) // within mc-clip
        XCTAssertEqual(mc1Marker.context[.effectiveOcclusion], .notOccluded) // main timeline
        XCTAssertEqual(mc1Marker.context[.localRoles], []) // markers never contain roles
        XCTAssertEqual(mc1Marker.context[.inheritedRoles], [
            .inherited(.audio(raw: "music.music-1")!),
            .inherited(.video(raw: "Custom Video Role.Custom Video Role A")!)
        ])
    }
    
    /// Test main timeline markers extraction with limited occlusion conditions.
    func testExtractMarkers_MainTimeline_LimitedOcclusions() throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try XCTUnwrap(fcpxml.allEvents().first)
        
        // extract markers
        let extractedMarkers = event.extractElements(preset: .markers, settings: .mainTimeline)
        XCTAssertEqual(extractedMarkers.count, 1)
        
        XCTAssertEqual(
            extractedMarkers.map(\.name),
            ["Marker on Multicam Clip"]
        )
    }
    
    /// Test main timeline markers extraction with all occlusion conditions.
    func testExtractMarkers_MainTimeline_AllOcclusions() throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try XCTUnwrap(fcpxml.allEvents().first)
        
        // extract markers
        var settings = FinalCutPro.FCPXML.ExtractionSettings.mainTimeline
        settings.occlusions = .allCases
        let extractedMarkers = event.extractElements(preset: .markers, settings: settings)
        XCTAssertEqual(extractedMarkers.count, 1)
        
        XCTAssertEqual(
            extractedMarkers.map(\.name),
            ["Marker on Multicam Clip"]
        )
    }
    
    /// Test deep markers extraction with all occlusion conditions.
    func testExtractMarkers_Deep_AllOcclusions() throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try XCTUnwrap(fcpxml.allEvents().first)
        
        // extract markers
        var settings = FinalCutPro.FCPXML.ExtractionSettings.deep()
        settings.occlusions = .allCases
        let extractedMarkers = event.extractElements(preset: .markers, settings: settings)
        // 1 on mc-clip, and 5 with the mc-clip
        XCTAssertEqual(extractedMarkers.count, 1 + 5)
        
        // note these are not sorted chronologically; they're in parsing order
        XCTAssertEqual(extractedMarkers.map(\.name), [
            "Marker on Multicam Clip", // on mc-clip
            "Marker in Multicam Clip on Angle A", // within mc-clip
            "Marker in Multicam Clip on Angle B", // within mc-clip
            "Marker in Multicam Clip on Angle C", // within mc-clip
            "Marker in Multicam Clip on Angle D", // within mc-clip
            "Marker in Multicam Clip on Music Angle" // within mc-clip
        ])
    }
}

#endif
