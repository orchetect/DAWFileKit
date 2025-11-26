//
//  FinalCutPro FCPXML 29.97.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
@testable import DAWFileTools
import SwiftExtensions
import TimecodeKitCore

final class FinalCutPro_FCPXML_29_97: FCPXMLTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try XCTUnwrap(loadFileContents(
            forResource: "29.97",
            withExtension: "fcpxml",
            subFolder: .fcpxmlExports
        ))
    } }
    
    /// Project @ 29.97fps.
    /// Contains media @ 23.976fps and 29.97fps.
    let projectFrameRate: TimecodeFrameRate = .fps29_97
    
    func testParse() throws {
        // load
        let rawData = try fileContents
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // version
        XCTAssertEqual(fcpxml.version, .ver1_11)
        
        // event
        let events = fcpxml.allEvents()
        let event = try XCTUnwrap(events[safe: 0])
        
        // project
        let projects = event.projects.zeroIndexed
        let project = try XCTUnwrap(projects[safe: 0])
        XCTAssertEqual(project.name, "29.97_V1")
        XCTAssertEqual(
            project.startTimecode(),
            try Timecode(.rational(0, 1), at: projectFrameRate, base: .max80SubFrames)
        )
        
        // sequence
        let sequence = try XCTUnwrap(projects[safe: 0]).sequence
        XCTAssertEqual(sequence.format, "r1")
        XCTAssertEqual(sequence.tcStartAsTimecode(), Self.tc("00:00:00:00", projectFrameRate))
        XCTAssertEqual(sequence.tcStartAsTimecode()?.frameRate, projectFrameRate)
        XCTAssertEqual(sequence.tcStartAsTimecode()?.subFramesBase, .max80SubFrames)
        XCTAssertEqual(sequence.durationAsTimecode(), Self.tc("00:00:29:17", projectFrameRate))
        XCTAssertEqual(sequence.audioLayout, .stereo)
        XCTAssertEqual(sequence.audioRate, .rate48kHz)
        
        // spine
        let spine = try XCTUnwrap(sequence.spine)
        
        let storyElements = spine.storyElements.zeroIndexed
        XCTAssertEqual(storyElements.count, 7)
    }
    
    func testExtractMarkers() async throws {
        // load file
        let rawData = try fileContents
        
        // load
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // project
        let project = try XCTUnwrap(fcpxml.allProjects().first)
        
        let extractedMarkers = await project
            .extract(preset: .markers, scope: .deep())
            .sortedByAbsoluteStartTimecode()
            // .zeroIndexed // not necessary after sorting - sort returns new array
        
        let markers = extractedMarkers
        
        // 3 x markers in r3 media resource (resource is used twice which produces 6 markers)
        // 20 x markers in sequence
        
        struct MarkerData {
            let absTC: String // Absolute timecode, as seen in FCP
            let name: String
            let config: FinalCutPro.FCPXML.Marker.Configuration
            let occ: FinalCutPro.FCPXML.ElementOcclusion
        }
        
        // swiftformat:disable all
        let markerList: [MarkerData] = [
            MarkerData(absTC: "00:00:01:14.00", name: "Marker 2", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:00:04:08.00", name: "Marker 3", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:00:05:26.00", name: "Marker 4", config: .standard, occ: .notOccluded),
            
            // r3 media markers
            MarkerData(absTC: "00:00:08:11.00", name: "INSIDE 1", config: .standard, occ: .notOccluded),   // 00:00:06:29 @ 29.97 + 00:00:01:12 @ 29.97
            MarkerData(absTC: "00:00:10:00.00", name: "INSIDE 2", config: .standard, occ: .notOccluded),   // 00:00:06:29 @ 29.97 + 00:00:03:01 @ 29.97
            MarkerData(absTC: "00:00:11:15.00", name: "INSIDE 3", config: .standard, occ: .fullyOccluded), // 00:00:06:29 @ 29.97 + 00:00:04:16 @ 29.97
            
            MarkerData(absTC: "00:00:11:23.00", name: "Marker 8", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:00:13:01.00", name: "Marker 9", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:00:14:05.00", name: "Marker 1", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:00:14:10.00", name: "Marker 10", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:00:14:17.00", name: "Marker 11", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:00:14:24.00", name: "Marker 12", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:00:14:24.00", name: "Marker 13", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:00:15:00.00", name: "Marker 14", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:00:15:04.00", name: "Marker 15", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:00:15:13.00", name: "Marker 16", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:00:15:20.00", name: "Marker 17", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:00:19:25.00", name: "Marker 18", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:00:21:21.00", name: "Marker 19", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:00:24:08.00", name: "Marker 20", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:00:24:08.00", name: "Marker 23", config: .standard, occ: .notOccluded),
            
            // r3 media markers
            MarkerData(absTC: "00:00:24:23.00", name: "INSIDE 1", config: .standard, occ: .notOccluded),   // 00:00:23:11 @ 29.97 + 00:00:01:12 @ 29.97
            MarkerData(absTC: "00:00:26:12.00", name: "INSIDE 2", config: .standard, occ: .fullyOccluded), // 00:00:23:11 @ 29.97 + 00:00:03:01 @ 29.97
            
            MarkerData(absTC: "00:00:26:29.00", name: "Marker 21", config: .standard, occ: .notOccluded),
            
            // r3 media markers
            MarkerData(absTC: "00:00:27:27.00", name: "INSIDE 3", config: .standard, occ: .fullyOccluded), // 00:00:23:11 @ 29.97 + 00:00:04:16 @ 29.97
            
            MarkerData(absTC: "00:00:28:23.00", name: "Marker 22", config: .standard, occ: .notOccluded)
        ]
        // swiftformat:enable all
        let expectedMarkerCount = 20 + (2 * 3)
        assert(markerList.count == expectedMarkerCount) // unit test sanity check
        
        XCTAssertEqual(markers.count, expectedMarkerCount)
        
        print("Markers sorted by absolute timecode:")
        print(Self.debugString(for: markers))
        
        for (index, markerData) in markerList.enumerated() {
            let marker = try XCTUnwrap(markers[safe: index])
            let desc = marker.name
            
            // name
            guard marker.name == markerData.name else {
                XCTFail(
                    "Fail: marker name mismatch at index \(index). "
                    + "Expected \(markerData.name.quoted) but found \(marker.name.quoted)."
                )
                continue
            }
            
            // config
            XCTAssertEqual(marker.configuration, markerData.config, desc)
            
            // absolute timecode
            let tc = try XCTUnwrap(marker.timecode(), marker.name)
            XCTAssertEqual(tc, Self.tc(markerData.absTC, projectFrameRate), desc)
            XCTAssertEqual(tc.frameRate, projectFrameRate, desc)
            
            // occlusion
            XCTAssertEqual(marker.value(forContext: .effectiveOcclusion), markerData.occ, desc)
        }
    }
    
    /// Just check that the correct number of markers are extracted for main timeline.
    func testExtractMarkers_MainTimeline() async throws {
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
        
        XCTAssertEqual(extractedMarkers.count, 20)
    }
}

#endif
