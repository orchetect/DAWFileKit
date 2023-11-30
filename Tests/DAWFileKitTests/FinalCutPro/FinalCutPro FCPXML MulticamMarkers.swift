//
//  FinalCutPro FCPXML MulticamMarkers.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
/* @testable */ import DAWFileKit
import OTCore
import TimecodeKit

final class FinalCutPro_FCPXML_MulticamMarkers: FCPXMLTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try XCTUnwrap(loadFileContents(
            forResource: "MulticamMarkers",
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
        let resources = fcpxml.resources()
        
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
        XCTAssertEqual(spine.contents.count, 2)
        
        // mc-clip 1
        
        guard case let .anyClip(.mcClip(mcClip1)) = spine.contents[safe: 0]
        else { XCTFail("Clip was not expected type.") ; return }
        
        XCTAssertEqual(mcClip1.ref, "r2")
        XCTAssertEqual(mcClip1.lane, nil)
        XCTAssertEqual(mcClip1.offset, Self.tc("01:00:00:00", .fps23_976))
        XCTAssertEqual(mcClip1.offset?.frameRate, .fps23_976)
        XCTAssertEqual(mcClip1.name, "MC")
        XCTAssertEqual(mcClip1.start, Self.tc("00:00:10:01", .fps23_976))
        XCTAssertEqual(mcClip1.duration, Self.tc("00:00:40:00", .fps23_976))
        XCTAssertEqual(mcClip1.duration?.frameRate, .fps23_976)
        XCTAssertEqual(mcClip1.enabled, true)
        XCTAssertEqual(mcClip1.context[.absoluteStart], Self.tc("01:00:00:00", .fps23_976))
        XCTAssertEqual(mcClip1.context[.occlusion], .notOccluded)
        XCTAssertEqual(mcClip1.context[.effectiveOcclusion], .notOccluded)
        
        let mc1Markers = mcClip1.contents.annotations().markers()
        XCTAssertEqual(mc1Markers.count, 1)
        
        let mc1Marker = try XCTUnwrap(mc1Markers[safe: 0])
        XCTAssertEqual(mc1Marker.name, "Marker on Multicam Clip 1")
        XCTAssertEqual(mc1Marker.context[.absoluteStart], Self.tc("01:00:01:09", .fps23_976))
        XCTAssertEqual(mc1Marker.context[.occlusion], .notOccluded) // within mc-clip 1
        XCTAssertEqual(mc1Marker.context[.effectiveOcclusion], .notOccluded) // main timeline
        // TODO: test roles
        
        // mc-clip 2
        
        guard case let .anyClip(.mcClip(mcClip2)) = spine.contents[safe: 1]
        else { XCTFail("Clip was not expected type.") ; return }
        
        XCTAssertEqual(mcClip2.ref, "r2")
        XCTAssertEqual(mcClip2.lane, nil)
        XCTAssertEqual(mcClip2.offset, Self.tc("01:00:40:00", .fps23_976))
        XCTAssertEqual(mcClip2.offset?.frameRate, .fps23_976)
        XCTAssertEqual(mcClip2.name, "MC")
        XCTAssertEqual(mcClip2.start, Self.tc("00:00:13:01", .fps23_976))
        XCTAssertEqual(mcClip2.duration, Self.tc("00:00:10:00", .fps23_976))
        XCTAssertEqual(mcClip2.duration?.frameRate, .fps23_976)
        XCTAssertEqual(mcClip2.enabled, true)
        XCTAssertEqual(mcClip2.context[.absoluteStart], Self.tc("01:00:40:00", .fps23_976))
        XCTAssertEqual(mcClip2.context[.occlusion], .notOccluded)
        XCTAssertEqual(mcClip2.context[.effectiveOcclusion], .notOccluded)
        
        let mc2Markers = mcClip2.contents.annotations().markers()
        XCTAssertEqual(mc2Markers.count, 1)
        
        let mc2Marker = try XCTUnwrap(mc2Markers[safe: 0])
        XCTAssertEqual(mc2Marker.name, "Marker on Multicam Clip 2")
        XCTAssertEqual(mc2Marker.context[.absoluteStart], Self.tc("01:00:44:08", .fps23_976))
        XCTAssertEqual(mc2Marker.context[.occlusion], .notOccluded) // within mc-clip 2
        XCTAssertEqual(mc2Marker.context[.effectiveOcclusion], .notOccluded) // main timeline
        // TODO: test roles
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
        XCTAssertEqual(extractedMarkers.count, 2)
        
        XCTAssertEqual(
            extractedMarkers.map(\.name),
            ["Marker on Multicam Clip 1", "Marker on Multicam Clip 2"]
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
        XCTAssertEqual(extractedMarkers.count, 2)
        
        XCTAssertEqual(
            extractedMarkers.map(\.name),
            ["Marker on Multicam Clip 1", "Marker on Multicam Clip 2"]
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
        // 1 on each mc clip, and 5 within each mc-clip
        XCTAssertEqual(extractedMarkers.count, 2 * (1 + 5))
        
        // note these are not sorted chronologically; they're in parsing order
        XCTAssertEqual(extractedMarkers.map(\.name), [
            "Marker on Multicam Clip 1", // on mc-clip 1
            "Marker in Multicam Clip on Angle A", // within mc-clip 1
            "Marker in Multicam Clip on Angle B", // within mc-clip 1
            "Marker in Multicam Clip on Angle C", // within mc-clip 1
            "Marker in Multicam Clip on Angle D", // within mc-clip 1
            "Marker in Multicam Clip on Audio", // within mc-clip 1
            "Marker on Multicam Clip 2", // on mc-clip 2
            "Marker in Multicam Clip on Angle A", // within mc-clip 2
            "Marker in Multicam Clip on Angle B", // within mc-clip 2
            "Marker in Multicam Clip on Angle C", // within mc-clip 2
            "Marker in Multicam Clip on Angle D", // within mc-clip 2
            "Marker in Multicam Clip on Audio", // within mc-clip 2
        ])
    }
    
    // MARK: - Utils
    
    func getSequence(
        from refClip: FinalCutPro.FCPXML.RefClip
    ) -> FinalCutPro.FCPXML.Sequence? {
        guard case let .sequence(sequence) = refClip.mediaType
        else { return nil }
        
        return sequence
    }
}

#endif
