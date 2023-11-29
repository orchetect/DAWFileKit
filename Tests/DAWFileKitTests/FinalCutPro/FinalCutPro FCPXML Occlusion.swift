//
//  FinalCutPro FCPXML Occlusion.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
/* @testable */ import DAWFileKit
import OTCore
import TimecodeKit

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
    
    func testParseAndOcclusion() throws {
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
        XCTAssertEqual(spine.contents.count, 9)
        
        // story elements
        
        // title1 - 3 markers not occluded, 1 marker fully occluded
        
        guard case let .anyClip(.title(title1)) = spine.contents[0]
        else { XCTFail("Clip was not expected type.") ; return }
        
        XCTAssertEqual(title1.ref, "r2")
        XCTAssertEqual(title1.offset, Self.tc("00:00:00:00", .fps24))
        XCTAssertEqual(title1.offset?.frameRate, .fps24)
        XCTAssertEqual(title1.name, "Basic Title 1")
        XCTAssertEqual(title1.start, Self.tc("01:00:00:00", .fps24))
        XCTAssertEqual(title1.duration, Self.tc("00:00:30:00", .fps24))
        XCTAssertEqual(title1.duration?.frameRate, .fps24)
        XCTAssertEqual(title1.context[.absoluteStart], Self.tc("00:00:00:00", .fps24))
        XCTAssertEqual(title1.context[.occlusion], .notOccluded)
        
        let title1Markers = title1.contents.annotations().markers()
        XCTAssertEqual(title1Markers.count, 4)
        
        let title1M1 = try XCTUnwrap(title1Markers[safe: 0])
        XCTAssertEqual(title1M1.name, "Marker on Start")
        XCTAssertEqual(title1M1.context[.absoluteStart], Self.tc("00:00:00:00", .fps24))
        XCTAssertEqual(title1M1.context[.occlusion], .notOccluded)
        XCTAssertEqual(title1M1.context[.effectiveOcclusion], .notOccluded)
        
        let title1M2 = try XCTUnwrap(title1Markers[safe: 1])
        XCTAssertEqual(title1M2.name, "Marker in Middle")
        XCTAssertEqual(title1M2.context[.absoluteStart], Self.tc("00:00:15:00", .fps24))
        XCTAssertEqual(title1M2.context[.occlusion], .notOccluded)
        XCTAssertEqual(title1M2.context[.effectiveOcclusion], .notOccluded)
        
        let title1M3 = try XCTUnwrap(title1Markers[safe: 2])
        XCTAssertEqual(title1M3.name, "Marker 1 Frame Before End")
        XCTAssertEqual(title1M3.context[.absoluteStart], Self.tc("00:00:29:23", .fps24))
        XCTAssertEqual(title1M3.context[.occlusion], .notOccluded)
        XCTAssertEqual(title1M3.context[.effectiveOcclusion], .notOccluded)
        
        // this marker is not visible from the main timeline, FCP hides it
        let title1M4 = try XCTUnwrap(title1Markers[safe: 3])
        XCTAssertEqual(title1M4.name, "Marker on End")
        XCTAssertEqual(title1M4.context[.absoluteStart], Self.tc("00:00:30:00", .fps24))
        XCTAssertEqual(title1M4.context[.occlusion], .fullyOccluded)
        XCTAssertEqual(title1M4.context[.effectiveOcclusion], .fullyOccluded)
        
        // title2 - 1 marker not occluded, 2 markers fully occluded
        
        guard case let .anyClip(.title(title2)) = spine.contents[2]
        else { XCTFail("Clip was not expected type.") ; return }
        XCTAssertEqual(title2.ref, "r2")
        XCTAssertEqual(title2.offset, Self.tc("00:00:40:00", .fps24))
        XCTAssertEqual(title2.offset?.frameRate, .fps24)
        XCTAssertEqual(title2.name, "Basic Title 2")
        XCTAssertEqual(title2.start, Self.tc("01:00:10:00", .fps24))
        XCTAssertEqual(title2.duration, Self.tc("00:00:10:00", .fps24))
        XCTAssertEqual(title2.duration?.frameRate, .fps24)
        XCTAssertEqual(title2.context[.absoluteStart], Self.tc("00:00:40:00", .fps24))
        XCTAssertEqual(title2.context[.occlusion], .notOccluded)
        XCTAssertEqual(title2.context[.effectiveOcclusion], .notOccluded)
        
        let title2Markers = title2.contents.annotations().markers()
        XCTAssertEqual(title2Markers.count, 3)
        
        // this marker is not visible from the main timeline, FCP hides it
        let title2M1 = try XCTUnwrap(title2Markers[safe: 0])
        XCTAssertEqual(title2M1.name, "Marker Before Start")
        XCTAssertEqual(title2M1.context[.absoluteStart], Self.tc("00:00:30:00", .fps24))
        XCTAssertEqual(title2M1.context[.occlusion], .fullyOccluded)
        XCTAssertEqual(title2M1.context[.effectiveOcclusion], .fullyOccluded)
        
        let title2M2 = try XCTUnwrap(title2Markers[safe: 1])
        XCTAssertEqual(title2M2.name, "Marker in Middle")
        XCTAssertEqual(title2M2.context[.absoluteStart], Self.tc("00:00:45:00", .fps24))
        XCTAssertEqual(title2M2.context[.occlusion], .notOccluded)
        XCTAssertEqual(title2M2.context[.effectiveOcclusion], .notOccluded)
        
        // this marker is not visible from the main timeline, FCP hides it
        let title2M3 = try XCTUnwrap(title2Markers[safe: 2])
        XCTAssertEqual(title2M3.name, "Marker Past End")
        XCTAssertEqual(title2M3.context[.absoluteStart], Self.tc("00:01:00:00", .fps24))
        XCTAssertEqual(title2M3.context[.occlusion], .fullyOccluded)
        XCTAssertEqual(title2M3.context[.effectiveOcclusion], .fullyOccluded)
        
        // refClip1 - contains 1 clip not occluded in media sequence or from main timeline
        
        guard case let .anyClip(.refClip(refClip1)) = spine.contents[safe: 4]
        else { XCTFail("Clip was not expected type.") ; return }
        XCTAssertEqual(refClip1.name, "Occlusion Clip 1")
        
        let refClip1Sequence = try XCTUnwrap(getSequence(from: refClip1))
        XCTAssertEqual(refClip1Sequence.context[.occlusion], .notOccluded)
        XCTAssertEqual(refClip1Sequence.context[.effectiveOcclusion], .notOccluded)
        
        let refClip1Title = try XCTUnwrap(refClip1Sequence.spine.contents[safe: 0])
        XCTAssertEqual(refClip1Title.name, "Basic Title 3")
        XCTAssertEqual(refClip1Title.context[.occlusion], .notOccluded)
        XCTAssertEqual(refClip1Title.context[.effectiveOcclusion], .notOccluded)
        
        // refClip2 - contains 1 clip partially occluded from main timeline, but not media sequence
        
        guard case let .anyClip(.refClip(refClip2)) = spine.contents[safe: 6]
        else { XCTFail("Clip was not expected type.") ; return }
        XCTAssertEqual(refClip2.name, "Occlusion Clip 2")
        
        let refClip2Sequence = try XCTUnwrap(getSequence(from: refClip2))
        XCTAssertEqual(refClip2Sequence.context[.occlusion], .partiallyOccluded)
        XCTAssertEqual(refClip2Sequence.context[.effectiveOcclusion], .partiallyOccluded)
        
        let refClip2Title = try XCTUnwrap(refClip2Sequence.spine.contents[safe: 0])
        XCTAssertEqual(refClip2Title.name, "Basic Title 4")
        XCTAssertEqual(refClip2Title.context[.occlusion], .notOccluded) // in media sequence
        XCTAssertEqual(refClip2Title.context[.effectiveOcclusion], .partiallyOccluded)
        
        // refClip3 - contains 1 clip fully occluded from main timeline, but not media sequence
        
        guard case let .anyClip(.refClip(refClip3)) = spine.contents[safe: 8]
        else { XCTFail("Clip was not expected type.") ; return }
        XCTAssertEqual(refClip3.name, "Occlusion Clip 3")
        
        let refClip3Sequence = try XCTUnwrap(getSequence(from: refClip3))
        XCTAssertEqual(refClip3Sequence.context[.occlusion], .partiallyOccluded)
        XCTAssertEqual(refClip3Sequence.context[.effectiveOcclusion], .partiallyOccluded)
        
        let refClip3Title = try XCTUnwrap(refClip3Sequence.spine.contents[safe: 1]) // gap before
        XCTAssertEqual(refClip3Title.name, "Basic Title 5")
        XCTAssertEqual(refClip3Title.context[.occlusion], .notOccluded) // in media sequence
        XCTAssertEqual(refClip3Title.context[.effectiveOcclusion], .fullyOccluded)
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
