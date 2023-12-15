//
//  FinalCutPro FCPXML CompoundClips.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

@testable import DAWFileKit
import OTCore
import TimecodeKit
import XCTest

final class FinalCutPro_FCPXML_CompoundClips: FCPXMLTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try XCTUnwrap(loadFileContents(
            forResource: "CompoundClips",
            withExtension: "fcpxml",
            subFolder: .fcpxmlExports
        ))
    } }
    
    /// Ensure that markers directly attached to compound clips (`ref-clip`s) on the main timeline
    /// are preserved, while all markers within compound clips are discarded.
    func testExtract_MainTimeline() async throws {
        // load file
        let rawData = try fileContents
        
        // load
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try XCTUnwrap(fcpxml.allEvents().first)
        
        // extract markers
        let extractedMarkers = await event
            .extract(preset: .markers, scope: .mainTimeline)
            .zeroIndexed
        XCTAssertEqual(extractedMarkers.count, 1)
        
        // just test basic marker info to identify the marker
        let marker = try XCTUnwrap(extractedMarkers[safe: 0])
        XCTAssertEqual(marker.name, "Marker On Compound Clip in Main Timeline")
        XCTAssertEqual(
            marker.value(forContext: .absoluteStartAsTimecode()),
            Self.tc("01:00:04:00", .fps25)
        )
    }
    
    func testExtract_Deep() async throws {
        // load file
        let rawData = try fileContents
        
        // load
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try XCTUnwrap(fcpxml.allEvents().first)
        
        // extract markers
        let extractedMarkers = await event
            .extract(preset: .markers, scope: .deep())
            .zeroIndexed
        XCTAssertEqual(extractedMarkers.count, 5)
    }
    
    func testExtract_allElementTypes() async throws {
        // load file
        let rawData = try fileContents
        
        // load
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try XCTUnwrap(fcpxml.allEvents().first)
        
        // extract markers
        let extractedMarkers = await event.extract(
            types: [.marker, .chapterMarker],
            scope: FinalCutPro.FCPXML.ExtractionScope(
                auditions: .all,
                mcClipAngles: .all,
                occlusions: .allCases,
                filteredTraversalTypes: [],
                excludedTraversalTypes: [],
                excludedExtractionTypes: [],
                traversalPredicate: nil,
                extractionPredicate: nil
            )
        )
        .zeroIndexed
        
        XCTAssertEqual(extractedMarkers.count, 5)
    }
}

#endif
