//
//  FinalCutPro FCPXML CompoundClips.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

@testable import DAWFileKit
import SwiftExtensions
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
        XCTAssertEqual(extractedMarkers.count, 2)
        
        // just test basic marker info to identify the marker
        let marker0 = try XCTUnwrap(extractedMarkers[safe: 0])
        XCTAssertEqual(marker0.name, "Marker On Title Compound Clip in Main Timeline")
        XCTAssertEqual(
            marker0.value(forContext: .absoluteStartAsTimecode()),
            Self.tc("01:00:04:00", .fps25)
        )
        
        let marker2 = try XCTUnwrap(extractedMarkers[safe: 1])
        XCTAssertEqual(marker2.name, "Marker On Clouds Compound Clip in Main Timeline")
        XCTAssertEqual(
            marker2.value(forContext: .absoluteStartAsTimecode()),
            Self.tc("01:00:25:00", .fps25)
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
        XCTAssertEqual(extractedMarkers.count, 6)
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
        
        XCTAssertEqual(extractedMarkers.count, 6)
    }
    
    /// Test metadata that applies to marker(s).
    func testExtractMarkersMetadata_MainTimeline() async throws {
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
        
        let expectedMarkerCount = 2
        XCTAssertEqual(markers.count, expectedMarkerCount)
        
        print("Markers sorted by absolute timecode:")
        print(Self.debugString(for: markers))
        
        // markers
        
        func md(
            in mdtm: [FinalCutPro.FCPXML.Metadata.Metadatum],
            key: FinalCutPro.FCPXML.Metadata.Key
        ) -> FinalCutPro.FCPXML.Metadata.Metadatum? {
            let matches = mdtm.filter { $0.key == key }
            XCTAssertLessThan(matches.count, 2)
            return matches.first
        }
        
        // marker 1
        // - compound clip has metadata, but the interior `title` clip has none
        do {
            let marker = try XCTUnwrap(markers[safe: 0])
            let mtdm = marker.value(forContext: .metadata)
            XCTAssertEqual(mtdm.count, 5)
            
            XCTAssertEqual(marker.name, "Marker On Title Compound Clip in Main Timeline")
            
            // metadata from media
            XCTAssertEqual(md(in: mtdm, key: .reel)?.value, "Title Compound Clip Reel")
            XCTAssertEqual(md(in: mtdm, key: .scene)?.value, "Title Compound Clip Scene")
            XCTAssertEqual(md(in: mtdm, key: .take)?.value, "Title Compound Clip Take")
            XCTAssertEqual(md(in: mtdm, key: .cameraAngle)?.value, "Title Compound Clip Camera Angle")
            XCTAssertEqual(md(in: mtdm, key: .cameraName)?.value, "Title Compound Clip Camera Name")
            
            // these happen to not be present probably because we're using Titles within this clip
            XCTAssertEqual(md(in: mtdm, key: .rawToLogConversion)?.value, nil)
            XCTAssertEqual(md(in: mtdm, key: .colorProfile)?.value, nil)
            XCTAssertEqual(md(in: mtdm, key: .cameraISO)?.value, nil)
            XCTAssertEqual(md(in: mtdm, key: .cameraColorTemperature)?.value, nil)
            XCTAssertEqual(md(in: mtdm, key: .codecs)?.valueArray, nil)
            XCTAssertEqual(md(in: mtdm, key: .ingestDate)?.value, nil)
        }
        
        // marker 2
        // - compound clip itself has no metadata, but both internal clips have metadata in FCP.
        // - however, FCP doesn't seem to export the metadata in the XML for titles and generators.
        // - this marker happens to overlay on a portion of the compound clip where the internal clip
        //   does have its metadata present in the XML however.
        do {
            let marker = try XCTUnwrap(markers[safe: 1])
            let mtdm = marker.value(forContext: .metadata)
            XCTAssertEqual(mtdm.count, 0)
            
            XCTAssertEqual(marker.name, "Marker On Clouds Compound Clip in Main Timeline")
            
            // metadata from media
            XCTAssertEqual(md(in: mtdm, key: .reel)?.value, nil)
            XCTAssertEqual(md(in: mtdm, key: .scene)?.value, nil)
            XCTAssertEqual(md(in: mtdm, key: .take)?.value, nil)
            XCTAssertEqual(md(in: mtdm, key: .cameraAngle)?.value, nil)
            XCTAssertEqual(md(in: mtdm, key: .cameraName)?.value, nil)
            
            // these happen to not be present probably because we're using Titles within this clip
            XCTAssertEqual(md(in: mtdm, key: .rawToLogConversion)?.value, nil)
            XCTAssertEqual(md(in: mtdm, key: .colorProfile)?.value, nil)
            XCTAssertEqual(md(in: mtdm, key: .cameraISO)?.value, nil)
            XCTAssertEqual(md(in: mtdm, key: .cameraColorTemperature)?.value, nil)
            XCTAssertEqual(md(in: mtdm, key: .codecs)?.valueArray, nil)
            XCTAssertEqual(md(in: mtdm, key: .ingestDate)?.value, nil)
        }
    }
}

#endif
