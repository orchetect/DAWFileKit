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
    func testExtractElements_MainTimeline() throws {
        // load file
        let rawData = try fileContents
        
        // load
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try XCTUnwrap(fcpxml.allEvents().first)
        
        // extract markers
        let extractedMarkers = event
            .extractElements(preset: .markers, settings: .mainTimeline)
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
    
    func testExtractElements_DeepSettings() throws {
        // load file
        let rawData = try fileContents
        
        // load
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try XCTUnwrap(fcpxml.allEvents().first)
        
        // extract markers
        let extractedMarkers = event
            .extractElements(preset: .markers, settings: .deep())
            .zeroIndexed
        XCTAssertEqual(extractedMarkers.count, 5)
    }
    
    func testExtractElements_allElementTypes() throws {
        // load file
        let rawData = try fileContents
        
        // load
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try XCTUnwrap(fcpxml.allEvents().first)
        
        // extract markers
        let extractedMarkers = event.extractElements(
            settings: FinalCutPro.FCPXML.ExtractionSettings(
                auditions: .activeAndAlternates,
                occlusions: .allCases,
                filteredTraversalTypes: nil,
                filteredExtractionTypes: nil,
                excludedTraversalTypes: [],
                excludedExtractionTypes: [],
                traversalPredicate: nil,
                extractionPredicate: nil
            )
        )
        .filter {
            $0.element.fcpElementType == .marker ||
            $0.element.fcpElementType == .chapterMarker
        }
        .zeroIndexed
        
        XCTAssertEqual(extractedMarkers.count, 5)
    }
}

#endif
