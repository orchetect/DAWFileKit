//
//  FinalCutPro FCPXML 59.94.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
@testable import DAWFileTools
import SwiftExtensions
import TimecodeKitCore

final class FinalCutPro_FCPXML_59_94: FCPXMLTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try XCTUnwrap(loadFileContents(
            forResource: "59.94",
            withExtension: "fcpxml",
            subFolder: .fcpxmlExports
        ))
    } }
    
    /// Project @ 59.94fps.
    /// Contains media @ 23.976fps and 29.97fps.
    let projectFrameRate: TimecodeFrameRate = .fps59_94
    
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
        XCTAssertEqual(project.name, "59.94_V1")
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
        XCTAssertEqual(sequence.durationAsTimecode(), Self.tc("00:04:23:25", projectFrameRate))
        XCTAssertEqual(sequence.audioLayout, .stereo)
        XCTAssertEqual(sequence.audioRate, .rate48kHz)
        
        // spine
        let spine = try XCTUnwrap(sequence.spine)
        
        let storyElements = spine.storyElements.zeroIndexed
        XCTAssertEqual(storyElements.count, 17)
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
        
        // 3 x markers in r8 media resource (resource is used twice which produces 6 markers)
        // 30 x markers in sequence
        
        struct MarkerData {
            let absTC: String // Absolute timecode, as seen in FCP
            let name: String
            let config: FinalCutPro.FCPXML.Marker.Configuration
            let occ: FinalCutPro.FCPXML.ElementOcclusion
        }
        
        // swiftformat:disable all
        let markerList: [MarkerData] = [
            MarkerData(absTC: "00:00:16:34.00", name: "Shot_01", config: .toDo(completed: false), occ: .notOccluded),
            MarkerData(absTC: "00:00:52:13.24", name: "Shot_02", config: .toDo(completed: false), occ: .notOccluded),
            MarkerData(absTC: "00:01:26:35.60", name: "Shot_03", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:01:53:38.23", name: "Shot_04", config: .toDo(completed: false), occ: .notOccluded),
            MarkerData(absTC: "00:02:10:40.72", name: "Shot_05", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:02:18:27.38", name: "Shot_06", config: .toDo(completed: false), occ: .notOccluded),
            MarkerData(absTC: "00:02:24:10.57", name: "Shot_07", config: .toDo(completed: false), occ: .notOccluded),
            MarkerData(absTC: "00:03:17:05.48", name: "Shot_08", config: .chapter(posterOffset: Fraction(11, 24)), occ: .notOccluded),
            MarkerData(absTC: "00:03:36:13.23", name: "Shot_09", config: .toDo(completed: false), occ: .notOccluded),
            MarkerData(absTC: "00:03:44:48.09", name: "Shot_10", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:03:55:11.00", name: "Marker 2", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:03:58:03.00", name: "Marker 3", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:03:59:39.00", name: "Marker 4", config: .standard, occ: .notOccluded),
            
            // r8 media markers
            MarkerData(absTC: "00:04:02:07.00", name: "INSIDE 1", config: .standard, occ: .notOccluded),   // 00:04:00:43 @ 59.94 + 00:00:01:12 @ 29.97
            MarkerData(absTC: "00:04:03:45.00", name: "INSIDE 2", config: .standard, occ: .notOccluded),   // 00:04:00:43 @ 59.94 + 00:00:03:01 @ 29.97
            MarkerData(absTC: "00:04:05:15.00", name: "INSIDE 3", config: .standard, occ: .fullyOccluded), // 00:04:00:43 @ 59.94 + 00:00:04:16 @ 29.97
            
            MarkerData(absTC: "00:04:05:33.40", name: "Marker 8", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:06:49.40", name: "Marker 9", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:07:59.00", name: "Marker 1", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:08:09.00", name: "Marker 10", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:08:23.00", name: "Marker 11", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:08:37.00", name: "Marker 12", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:08:38.00", name: "Marker 13", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:08:48.00", name: "Marker 14", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:08:56.00", name: "Marker 15", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:09:15.00", name: "Marker 16", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:09:30.00", name: "Marker 17", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:13:41.10", name: "Marker 18", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:15:33.10", name: "Marker 19", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:18:08.00", name: "Marker 23", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:18:11.00", name: "Marker 20", config: .standard, occ: .notOccluded),
            
            // r8 media markers
            MarkerData(absTC: "00:04:18:38.00", name: "INSIDE 1", config: .standard, occ: .notOccluded),   // 00:04:17:14 @ 59.94 + 00:00:01:12 @ 29.97
            MarkerData(absTC: "00:04:20:16.00", name: "INSIDE 2", config: .standard, occ: .fullyOccluded), // 00:04:17:14 @ 59.94 + 00:00:03:01 @ 29.97
            
            MarkerData(absTC: "00:04:20:53.00", name: "Marker 21", config: .standard, occ: .notOccluded),
            
            // r8 media markers
            MarkerData(absTC: "00:04:21:46.00", name: "INSIDE 3", config: .standard, occ: .fullyOccluded), // 00:04:17:14 @ 59.94 + 00:00:04:16 @ 29.97
            
            MarkerData(absTC: "00:04:22:41.00", name: "Marker 22", config: .standard, occ: .notOccluded)
        ]
        // swiftformat:enable all
        let expectedMarkerCount = 30 + (2 * 3)
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
        
        XCTAssertEqual(extractedMarkers.count, 30)
    }
}

#endif
