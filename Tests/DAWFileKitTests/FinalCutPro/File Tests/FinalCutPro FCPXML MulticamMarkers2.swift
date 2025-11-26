//
//  FinalCutPro FCPXML MulticamMarkers2.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
@testable import DAWFileKit
import SwiftExtensions
import TimecodeKitCore

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
    
    func testParse() async throws {
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
        XCTAssertEqual(event.element._fcpEffectiveOcclusion(), .notOccluded)
        
        // projects
        let projects = event.projects
        XCTAssertEqual(projects.count, 1)
        
        let project = try XCTUnwrap(projects[safe: 0])
        XCTAssertEqual(project.element._fcpEffectiveOcclusion(), .notOccluded)
        
        // sequence
        let sequence = try XCTUnwrap(project.sequence)
        XCTAssertEqual(sequence.element._fcpEffectiveOcclusion(), .notOccluded)
        
        // spine
        let spine = try XCTUnwrap(sequence.spine)
        
        let storyElements = spine.storyElements.zeroIndexed
        XCTAssertEqual(storyElements.count, 1)
        
        // mc-clip
        
        let mcClip = try XCTUnwrap(storyElements[safe: 0]?.fcpAsMCClip)
        XCTAssertEqual(mcClip.ref, "r2")
        XCTAssertEqual(mcClip.lane, nil)
        XCTAssertEqual(mcClip.offsetAsTimecode(), Self.tc("01:00:00:00", .fps23_976))
        XCTAssertEqual(mcClip.offsetAsTimecode()?.frameRate, .fps23_976)
        XCTAssertEqual(mcClip.name, "MC")
        XCTAssertEqual(mcClip.startAsTimecode(), Self.tc("00:00:13:01", .fps23_976))
        XCTAssertEqual(mcClip.durationAsTimecode(), Self.tc("00:00:10:00", .fps23_976))
        XCTAssertEqual(mcClip.durationAsTimecode()?.frameRate, .fps23_976)
        XCTAssertEqual(mcClip.enabled, true)
        let extractedMCClip = await mcClip.element.fcpExtract()
        XCTAssertEqual(
            extractedMCClip.value(forContext: .absoluteStartAsTimecode()),
            Self.tc("01:00:00:00", .fps23_976)
        )
        XCTAssertEqual(extractedMCClip.value(forContext: .occlusion), .notOccluded)
        XCTAssertEqual(extractedMCClip.value(forContext: .effectiveOcclusion), .notOccluded)
        XCTAssertEqual(extractedMCClip.value(forContext: .localRoles), [
            .video(raw: "Custom Video Role.Custom Video Role A")!,
            .audio(raw: "music.music-1")!
        ])
        XCTAssertEqual(extractedMCClip.value(forContext: .inheritedRoles), [
            .inherited(.video(raw: "Custom Video Role.Custom Video Role A")!),
            .inherited(.audio(raw: "music.music-1")!)
        ])
        
        // mc-clip multicam media
        
        let mc = try XCTUnwrap(mcClip.multicamResource)
        
        XCTAssertEqual(mc.format, "r1")
        XCTAssertEqual(mc.tcStartAsTimecode(), Self.tc("00:00:00:00", .fps23_976))
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
        
        let mcMarkers = mcClip.storyElements
            .filter(whereFCPElement: .marker)
            .zeroIndexed
        XCTAssertEqual(mcMarkers.count, 1)
        
        let mcMarker = try XCTUnwrap(mcMarkers[safe: 0])
        XCTAssertEqual(mcMarker.name, "Marker on Multicam Clip")
        let extractedMCMarker = await mcMarker.element.fcpExtract()
        XCTAssertEqual(
            extractedMCMarker.value(forContext: .absoluteStartAsTimecode()),
            Self.tc("01:00:04:08", .fps23_976)
        )
        XCTAssertEqual(extractedMCMarker.value(forContext: .occlusion), .notOccluded) // within mc-clip
        XCTAssertEqual(extractedMCMarker.value(forContext: .effectiveOcclusion), .notOccluded) // main timeline
        XCTAssertEqual(extractedMCMarker.value(forContext: .localRoles), []) // markers never contain roles
        XCTAssertEqual(extractedMCMarker.value(forContext: .inheritedRoles), [
            .inherited(.video(raw: "Custom Video Role.Custom Video Role A")!),
            .inherited(.audio(raw: "music.music-1")!)
        ])
    }
    
    /// Test main timeline markers extraction with limited occlusion conditions.
    func testExtractMarkers_MainTimeline_LimitedOcclusions() async throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try XCTUnwrap(fcpxml.allEvents().first)
        
        // extract markers
        let extractedMarkers = await event.extract(preset: .markers, scope: .mainTimeline)
        XCTAssertEqual(extractedMarkers.count, 1)
        
        XCTAssertEqual(
            extractedMarkers.map(\.name),
            ["Marker on Multicam Clip"]
        )
    }
    
    /// Test main timeline markers extraction with all occlusion conditions.
    func testExtractMarkers_MainTimeline_AllOcclusions_ActiveAngles() async throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try XCTUnwrap(fcpxml.allEvents().first)
        
        // extract markers
        var scope = FinalCutPro.FCPXML.ExtractionScope.mainTimeline
        scope.occlusions = .allCases
        let extractedMarkers = await event.extract(preset: .markers, scope: scope)
        XCTAssertEqual(extractedMarkers.count, 1)
        
        XCTAssertEqual(
            extractedMarkers.map(\.name),
            ["Marker on Multicam Clip"]
        )
    }
    
    /// Test deep markers extraction with all occlusion conditions and active angles.
    func testExtractMarkers_Deep_AllOcclusions_ActiveAngles() async throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try XCTUnwrap(fcpxml.allEvents().first)
        
        // extract markers
        var scope = FinalCutPro.FCPXML.ExtractionScope.deep()
        scope.mcClipAngles = .active
        scope.occlusions = .allCases
        let extractedMarkers = await event.extract(preset: .markers, scope: scope)
        // 1 on mc-clip, and 5 with the mc-clip
        XCTAssertEqual(extractedMarkers.count, 1 + 2)
        
        // note these are not sorted chronologically; they're in parsing order
        XCTAssertEqual(extractedMarkers.map(\.name), [
            "Marker on Multicam Clip", // on mc-clip
            "Marker in Multicam Clip on Angle B", // within mc-clip, video angle
            "Marker in Multicam Clip on Music Angle" // within mc-clip, audio angle
        ])
    }
    
    /// Test deep markers extraction with all occlusion conditions and all angles.
    func testExtractMarkers_Deep_AllOcclusions_AllAngles() async throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try XCTUnwrap(fcpxml.allEvents().first)
        
        // extract markers
        var scope = FinalCutPro.FCPXML.ExtractionScope.deep()
        scope.mcClipAngles = .all
        scope.occlusions = .allCases
        let extractedMarkers = await event.extract(preset: .markers, scope: scope)
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
