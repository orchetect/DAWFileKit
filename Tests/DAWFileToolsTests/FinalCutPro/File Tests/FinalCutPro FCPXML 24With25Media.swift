//
//  FinalCutPro FCPXML 24With25Media.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
@testable import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore

final class FinalCutPro_FCPXML_24With25Media: FCPXMLTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try XCTUnwrap(loadFileContents(
            forResource: "24With25Media",
            withExtension: "fcpxml",
            subFolder: .fcpxmlExports
        ))
    } }
    
    /// Project @ 24fps.
    /// Contains media @ 25fps.
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
        XCTAssertEqual(project.name, "24With25Media")
        XCTAssertEqual(
            project.startTimecode(),
            try Timecode(.components(h: 1), at: projectFrameRate, base: .max80SubFrames)
        )
        
        // sequence
        let sequence = try XCTUnwrap(projects[safe: 0]).sequence
        XCTAssertEqual(sequence.format, "r1")
        XCTAssertEqual(sequence.tcStartAsTimecode(), Self.tc("01:00:00:00", projectFrameRate))
        XCTAssertEqual(sequence.tcStartAsTimecode()?.frameRate, projectFrameRate)
        XCTAssertEqual(sequence.tcStartAsTimecode()?.subFramesBase, .max80SubFrames)
        XCTAssertEqual(sequence.durationAsTimecode(), Self.tc("00:02:42:23", projectFrameRate))
        XCTAssertEqual(sequence.audioLayout, .stereo)
        XCTAssertEqual(sequence.audioRate, .rate48kHz)
        
        // spine
        let spine = try XCTUnwrap(sequence.spine)
        
        let storyElements = spine.storyElements.zeroIndexed
        XCTAssertEqual(storyElements.count, 4)
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
        
        // 3 x markers
        
        struct MarkerData {
            let absTC: String // Absolute timecode, as seen in FCP
            let name: String
            let config: FinalCutPro.FCPXML.Marker.Configuration
            let occ: FinalCutPro.FCPXML.ElementOcclusion
        }
        
        // swiftformat:disable all
        let markerList: [MarkerData] = [
            MarkerData(absTC: "01:00:10:01.00", name: "Marker 1", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "01:02:09:17.00", name: "Marker 2", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "01:02:28:18.00", name: "Marker 3", config: .standard, occ: .notOccluded)
        ]
        // swiftformat:enable all
        let expectedMarkerCount = 3
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
        
        XCTAssertEqual(extractedMarkers.count, 3)
    }
}

#endif
