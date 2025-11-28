//
//  FinalCutPro FCPXML 24.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
@testable import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore

final class FinalCutPro_FCPXML_24: FCPXMLTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try XCTUnwrap(loadFileContents(
            forResource: "24",
            withExtension: "fcpxml",
            subFolder: .fcpxmlExports
        ))
    } }
    
    /// Project @ 24fps.
    /// Contains media @ 23.976fps and 29.97fps.
    let projectFrameRate: TimecodeFrameRate = .fps24
    
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
        XCTAssertEqual(project.name, "24_V1")
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
        XCTAssertEqual(sequence.durationAsTimecode(), Self.tc("00:04:22:23", projectFrameRate))
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
        
        // 3 x markers in r8 media resource (resource is used twice which produces 6 markers):
        // 30 x markers in sequence (listed in chronological order as seen in FCP's marker list):
        
        struct MarkerData {
            let absTC: String // Absolute timecode, as seen in FCP
            let name: String
            let config: FinalCutPro.FCPXML.Marker.Configuration
            let occ: FinalCutPro.FCPXML.ElementOcclusion
        }
        
        // swiftformat:disable all
        let markerList: [MarkerData] = [
            MarkerData(absTC: "00:00:16:14.00", name: "Shot_01", config: .toDo(completed: false), occ: .notOccluded),
            MarkerData(absTC: "00:00:52:05.00", name: "Shot_02", config: .toDo(completed: false), occ: .notOccluded),
            MarkerData(absTC: "00:01:26:13.00", name: "Shot_03", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:01:53:12.76", name: "Shot_04", config: .toDo(completed: false), occ: .notOccluded),
            MarkerData(absTC: "00:02:10:13.00", name: "Shot_05", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:02:18:07.02", name: "Shot_06", config: .toDo(completed: false), occ: .notOccluded),
            MarkerData(absTC: "00:02:24:00.00", name: "Shot_07", config: .toDo(completed: false), occ: .notOccluded),
            MarkerData(absTC: "00:03:16:22.58", name: "Shot_08", config: .chapter(posterOffset: Fraction(11, 24)), occ: .notOccluded), // off by 1 subframe
            MarkerData(absTC: "00:03:36:00.00", name: "Shot_09", config: .toDo(completed: false), occ: .notOccluded),
            MarkerData(absTC: "00:03:44:15.00", name: "Shot_10", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:03:54:22.18", name: "Marker 2", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:03:57:17.01", name: "Marker 3", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:03:59:07.36", name: "Marker 4", config: .standard, occ: .notOccluded),
            
            // r8 media markers
            MarkerData(absTC: "00:04:01:18.50", name: "INSIDE 1", config: .standard, occ: .notOccluded),   // 00:04:00:09 @ 24 + 00:00:01:12 @ 29.97
            MarkerData(absTC: "00:04:03:09.69", name: "INSIDE 2", config: .standard, occ: .notOccluded),   // 00:04:00:09 @ 24 + 00:00:03:01 @ 29.97
            MarkerData(absTC: "00:04:04:21.72", name: "INSIDE 3", config: .standard, occ: .fullyOccluded), // 00:04:00:09 @ 24 + 00:00:04:16 @ 29.97
            
            MarkerData(absTC: "00:04:05:04.02", name: "Marker 8", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:06:10.37", name: "Marker 9", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:07:13.32", name: "Marker 1", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:07:17.32", name: "Marker 10", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:07:23.01", name: "Marker 11", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:08:04.48", name: "Marker 13", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:08:04.49", name: "Marker 12", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:08:08.48", name: "Marker 14", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:08:11.64", name: "Marker 15", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:08:19.66", name: "Marker 16", config: .standard, occ: .notOccluded), // off by 1 subframe
            MarkerData(absTC: "00:04:09:00.16", name: "Marker 17", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:13:04.70", name: "Marker 18", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:15:01.58", name: "Marker 19", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:17:15.49", name: "Marker 23", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:17:16.03", name: "Marker 20", config: .standard, occ: .notOccluded),
            
            // r8 media markers
            MarkerData(absTC: "00:04:18:03.50", name: "INSIDE 1", config: .standard, occ: .notOccluded),   // 00:04:16:18 @ 24 + 00:00:01:12 @ 29.97
            MarkerData(absTC: "00:04:19:18.69", name: "INSIDE 2", config: .standard, occ: .fullyOccluded), // 00:04:16:18 @ 24 + 00:00:03:01 @ 29.97
            
            MarkerData(absTC: "00:04:20:08.72", name: "Marker 21", config: .standard, occ: .notOccluded),
            
            // r8 media markers
            MarkerData(absTC: "00:04:21:06.72", name: "INSIDE 3", config: .standard, occ: .fullyOccluded), // 00:04:16:18 @ 24 + 00:00:04:16 @ 29.97
            
            MarkerData(absTC: "00:04:22:04.11", name: "Marker 22", config: .standard, occ: .notOccluded)
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
