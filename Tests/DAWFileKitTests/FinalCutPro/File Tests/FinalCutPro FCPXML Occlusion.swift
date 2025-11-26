//
//  FinalCutPro FCPXML Occlusion.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
/* @testable */ import DAWFileKit
import SwiftExtensions
import TimecodeKitCore

final class FinalCutPro_FCPXML_Occlusion: FCPXMLTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try XCTUnwrap(loadFileContents(
            forResource: "Occlusion",
            withExtension: "fcpxml",
            subFolder: .fcpxmlExports
        ))
    } }
    
    func testParseAndOcclusion() async throws {
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
        let extractedEvent = await event.element.fcpExtract()
        XCTAssertEqual(extractedEvent.value(forContext: .occlusion), .notOccluded)
        XCTAssertEqual(extractedEvent.value(forContext: .effectiveOcclusion), .notOccluded)
        
        /// projects
        let projects = event.projects.zeroIndexed
        XCTAssertEqual(projects.count, 1)
        
        let project = try XCTUnwrap(projects[safe: 0])
        let extractedProject = await event.element.fcpExtract()
        XCTAssertEqual(extractedProject.value(forContext: .occlusion), .notOccluded)
        XCTAssertEqual(extractedProject.value(forContext: .effectiveOcclusion), .notOccluded)
        
        let sequence = project.sequence
        let extractedSequence = await sequence.element.fcpExtract()
        XCTAssertEqual(extractedSequence.value(forContext: .occlusion), .notOccluded)
        XCTAssertEqual(extractedSequence.value(forContext: .effectiveOcclusion), .notOccluded)
        
        // spine
        let spine = sequence.spine
        let storyElements = spine.storyElements.zeroIndexed
        XCTAssertEqual(storyElements.count, 9)
        
        // story elements
        
        // title1 - 3 markers not occluded, 1 marker fully occluded
        
        let title1 = try XCTUnwrap(storyElements[safe: 0]?.fcpAsTitle)
        XCTAssertEqual(title1.ref, "r2")
        XCTAssertEqual(title1.offsetAsTimecode(), Self.tc("00:00:00:00", .fps24))
        XCTAssertEqual(title1.offsetAsTimecode()?.frameRate, .fps24)
        XCTAssertEqual(title1.name, "Basic Title 1")
        XCTAssertEqual(title1.startAsTimecode(), Self.tc("01:00:00:00", .fps24))
        XCTAssertEqual(title1.durationAsTimecode(), Self.tc("00:00:30:00", .fps24))
        XCTAssertEqual(title1.durationAsTimecode()?.frameRate, .fps24)
        let extractedTitle1 = await title1.element.fcpExtract()
        XCTAssertEqual(
            extractedTitle1.value(forContext: .absoluteStartAsTimecode()),
            Self.tc("00:00:00:00", .fps24)
        )
        XCTAssertEqual(extractedTitle1.value(forContext: .occlusion), .notOccluded)
        XCTAssertEqual(extractedTitle1.value(forContext: .effectiveOcclusion), .notOccluded)

        let title1Markers = title1.storyElements.filter(whereFCPElement: .marker).zeroIndexed
        XCTAssertEqual(title1Markers.count, 4)
        
        let title1M1 = try XCTUnwrap(title1Markers[safe: 0])
        XCTAssertEqual(title1M1.name, "Marker on Start")
        let extractedTitle1M1 = await title1M1.element.fcpExtract()
        XCTAssertEqual(
            extractedTitle1M1.value(forContext: .absoluteStartAsTimecode()),
            Self.tc("00:00:00:00", .fps24)
        )
        XCTAssertEqual(extractedTitle1M1.value(forContext: .occlusion), .notOccluded)
        XCTAssertEqual(extractedTitle1M1.value(forContext: .effectiveOcclusion), .notOccluded)

        let title1M2 = try XCTUnwrap(title1Markers[safe: 1])
        XCTAssertEqual(title1M2.name, "Marker in Middle")
        let extractedTitle1M2 = await title1M2.element.fcpExtract()
        XCTAssertEqual(
            extractedTitle1M2.value(forContext: .absoluteStartAsTimecode()),
            Self.tc("00:00:15:00", .fps24)
        )
        XCTAssertEqual(extractedTitle1M2.value(forContext: .occlusion), .notOccluded)
        XCTAssertEqual(extractedTitle1M2.value(forContext: .effectiveOcclusion), .notOccluded)
        
        let title1M3 = try XCTUnwrap(title1Markers[safe: 2])
        XCTAssertEqual(title1M3.name, "Marker 1 Frame Before End")
        let extractedTitle1M3 = await title1M3.element.fcpExtract()
        XCTAssertEqual(
            extractedTitle1M3.value(forContext: .absoluteStartAsTimecode()),
            Self.tc("00:00:29:23", .fps24)
        )
        XCTAssertEqual(extractedTitle1M3.value(forContext: .occlusion), .notOccluded)
        XCTAssertEqual(extractedTitle1M3.value(forContext: .effectiveOcclusion), .notOccluded)
        
        // this marker is not visible from the main timeline, FCP hides it
        let title1M4 = try XCTUnwrap(title1Markers[safe: 3])
        XCTAssertEqual(title1M4.name, "Marker on End")
        let extractedTitle1M4 = await title1M4.element.fcpExtract()
        XCTAssertEqual(
            extractedTitle1M4.value(forContext: .absoluteStartAsTimecode()),
            Self.tc("00:00:30:00", .fps24)
        )
        XCTAssertEqual(extractedTitle1M4.value(forContext: .occlusion), .fullyOccluded)
        XCTAssertEqual(extractedTitle1M4.value(forContext: .effectiveOcclusion), .fullyOccluded)
        
        // title2 - 1 marker not occluded, 2 markers fully occluded
        
        let title2 = try XCTUnwrap(storyElements[safe: 2]?.fcpAsTitle)
        XCTAssertEqual(title2.ref, "r2")
        XCTAssertEqual(title2.offsetAsTimecode(), Self.tc("00:00:40:00", .fps24))
        XCTAssertEqual(title2.offsetAsTimecode()?.frameRate, .fps24)
        XCTAssertEqual(title2.name, "Basic Title 2")
        XCTAssertEqual(title2.startAsTimecode(), Self.tc("01:00:10:00", .fps24))
        XCTAssertEqual(title2.durationAsTimecode(), Self.tc("00:00:10:00", .fps24))
        XCTAssertEqual(title2.durationAsTimecode()?.frameRate, .fps24)
        let extractedTitle2 = await title2.element.fcpExtract()
        XCTAssertEqual(
            extractedTitle2.value(forContext: .absoluteStartAsTimecode()),
            Self.tc("00:00:40:00", .fps24))
        XCTAssertEqual(extractedTitle2.value(forContext: .occlusion), .notOccluded)
        XCTAssertEqual(extractedTitle2.value(forContext: .effectiveOcclusion), .notOccluded)
        
        let title2Markers = title2.storyElements.filter(whereFCPElement: .marker).zeroIndexed
        XCTAssertEqual(title2Markers.count, 3)
        
        // this marker is not visible from the main timeline, FCP hides it
        let title2M1 = try XCTUnwrap(title2Markers[safe: 0])
        XCTAssertEqual(title2M1.name, "Marker Before Start")
        let extractedTitle2M1 = await title2M1.element.fcpExtract()
        XCTAssertEqual(
            extractedTitle2M1.value(forContext: .absoluteStartAsTimecode()),
            Self.tc("00:00:30:00", .fps24)
        )
        XCTAssertEqual(extractedTitle2M1.value(forContext: .occlusion), .fullyOccluded)
        XCTAssertEqual(extractedTitle2M1.value(forContext: .effectiveOcclusion), .fullyOccluded)
        
        let title2M2 = try XCTUnwrap(title2Markers[safe: 1])
        XCTAssertEqual(title2M2.name, "Marker in Middle")
        let extractedTitle2M2 = await title2M2.element.fcpExtract()
        XCTAssertEqual(
            extractedTitle2M2.value(forContext: .absoluteStartAsTimecode()),
            Self.tc("00:00:45:00", .fps24)
        )
        XCTAssertEqual(extractedTitle2M2.value(forContext: .occlusion), .notOccluded)
        XCTAssertEqual(extractedTitle2M2.value(forContext: .effectiveOcclusion), .notOccluded)

        // this marker is not visible from the main timeline, FCP hides it
        let title2M3 = try XCTUnwrap(title2Markers[safe: 2])
        XCTAssertEqual(title2M3.name, "Marker Past End")
        let extractedTitle2M3 = await title2M3.element.fcpExtract()
        XCTAssertEqual(
            extractedTitle2M3.value(forContext: .absoluteStartAsTimecode()),
            Self.tc("00:01:00:00", .fps24)
        )
        XCTAssertEqual(extractedTitle2M3.value(forContext: .occlusion), .fullyOccluded)
        XCTAssertEqual(extractedTitle2M3.value(forContext: .effectiveOcclusion), .fullyOccluded)

        // refClip1 - contains 1 clip not occluded in media sequence or from main timeline
        
        let refClip1 = try XCTUnwrap(storyElements[safe: 4]?.fcpAsRefClip)
        XCTAssertEqual(refClip1.name, "Occlusion Clip 1")
        
        #warning("> TODO: occlusion within a ref-clip must be tested with `fcpExtract(types:scope:)` and not `fcpExtract()`")
//        let refClip1Sequence = refClip1.sequence
//        XCTAssertEqual(refClip1Sequence.context[.occlusion], .notOccluded)
//        XCTAssertEqual(refClip1Sequence.context[.effectiveOcclusion], .notOccluded)
//        
//        let refClip1Title = try XCTUnwrap(refClip1Sequence.spine.contents[safe: 0])
//        XCTAssertEqual(refClip1Title.name, "Basic Title 3")
//        XCTAssertEqual(refClip1Title.context[.occlusion], .notOccluded)
//        XCTAssertEqual(refClip1Title.context[.effectiveOcclusion], .notOccluded)
//        
//        // refClip2 - contains 1 clip partially occluded from main timeline, but not media sequence
//        
//        guard case let .anyClip(.refClip(refClip2)) = spine.contents[safe: 6]
//        else { XCTFail("Clip was not expected type.") ; return }
//        XCTAssertEqual(refClip2.name, "Occlusion Clip 2")
//        
//        let refClip2Sequence = refClip2.sequence
//        XCTAssertEqual(refClip2Sequence.context[.occlusion], .partiallyOccluded)
//        XCTAssertEqual(refClip2Sequence.context[.effectiveOcclusion], .partiallyOccluded)
//        
//        let refClip2Title = try XCTUnwrap(refClip2Sequence.spine.contents[safe: 0])
//        XCTAssertEqual(refClip2Title.name, "Basic Title 4")
//        XCTAssertEqual(refClip2Title.context[.occlusion], .notOccluded) // in media sequence
//        XCTAssertEqual(refClip2Title.context[.effectiveOcclusion], .partiallyOccluded)
//        
//        // refClip3 - contains 1 clip fully occluded from main timeline, but not media sequence
//        
//        guard case let .anyClip(.refClip(refClip3)) = spine.contents[safe: 8]
//        else { XCTFail("Clip was not expected type.") ; return }
//        XCTAssertEqual(refClip3.name, "Occlusion Clip 3")
//        
//        let refClip3Sequence = refClip3.sequence
//        XCTAssertEqual(refClip3Sequence.context[.occlusion], .partiallyOccluded)
//        XCTAssertEqual(refClip3Sequence.context[.effectiveOcclusion], .partiallyOccluded)
//        
//        let refClip3Title = try XCTUnwrap(refClip3Sequence.spine.contents[safe: 1]) // gap before
//        XCTAssertEqual(refClip3Title.name, "Basic Title 5")
//        XCTAssertEqual(refClip3Title.context[.occlusion], .notOccluded) // in media sequence
//        XCTAssertEqual(refClip3Title.context[.effectiveOcclusion], .fullyOccluded)
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
        assert(
            FinalCutPro.FCPXML.ExtractionScope.mainTimeline.occlusions
            == [.notOccluded, .partiallyOccluded]
        )
        let extractedMarkers = await event
            .extract(preset: .markers, scope: .mainTimeline)
            .zeroIndexed
        XCTAssertEqual(extractedMarkers.count, 4)
        
        XCTAssertEqual(
            extractedMarkers.map(\.name),
            ["Marker on Start", "Marker in Middle", "Marker 1 Frame Before End", "Marker in Middle"]
        )
    }
    
    /// Test main timeline markers extraction with all occlusion conditions.
    func testExtractMarkers_MainTimeline_AllOcclusions() async throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try XCTUnwrap(fcpxml.allEvents().first)
        
        // extract markers
        var scope: FinalCutPro.FCPXML.ExtractionScope = .mainTimeline
        scope.occlusions = .allCases
        let extractedMarkers = await event
            .extract(preset: .markers, scope: scope)
            .zeroIndexed
        XCTAssertEqual(extractedMarkers.count, 7)
        
        XCTAssertEqual(
            extractedMarkers.map(\.name),
            ["Marker on Start", "Marker in Middle", "Marker 1 Frame Before End", "Marker on End",
             "Marker Before Start", "Marker in Middle", "Marker Past End"]
        )
    }
}

#endif
