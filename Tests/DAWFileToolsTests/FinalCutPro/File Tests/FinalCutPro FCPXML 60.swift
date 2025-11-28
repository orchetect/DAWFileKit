//
//  FinalCutPro FCPXML 60.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
@testable import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore

final class FinalCutPro_FCPXML_60: FCPXMLTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try XCTUnwrap(loadFileContents(
            forResource: "60",
            withExtension: "fcpxml",
            subFolder: .fcpxmlExports
        ))
    } }
    
    /// Project @ 60fps.
    /// Contains media @ 23.976fps and 29.97fps.
    let projectFrameRate: TimecodeFrameRate = .fps60
    
    func testParse() throws {
        // load
        let rawData = try fileContents
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // version
        XCTAssertEqual(fcpxml.version, .ver1_11)
        
        // resources
        let resourcesDict = fcpxml.root.resourcesDict
        XCTAssertEqual(resourcesDict.count, 8)
        
        // library
        let library = try XCTUnwrap(fcpxml.root.library)
        let libraryURL = URL(string: "file:///Users/user/Movies/FCPXMLTest.fcpbundle/")
        XCTAssertEqual(library.location, libraryURL)
        
        // event
        let events = fcpxml.allEvents()
        XCTAssertEqual(events.count, 1)
        
        let event = try XCTUnwrap(events[safe: 0])
        XCTAssertEqual(event.name, "11-9-22")
        
        // project
        let projects = event.projects.zeroIndexed
        XCTAssertEqual(projects.count, 1)
        
        let project = try XCTUnwrap(projects[safe: 0])
        XCTAssertEqual(project.name, "60_V1")
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
        XCTAssertEqual(sequence.durationAsTimecode(), Self.tc("00:04:23:10", projectFrameRate))
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
        // -------
        // <marker start="247247/15000s" duration="1001/30000s" value="INSIDE 1"/>
        // <marker start="181181/10000s" duration="1001/30000s" value="INSIDE 2"/>
        // <marker start="49049/2500s" duration="1001/30000s" value="INSIDE 3"/>
        
        // 30 x markers in sequence (listed in chronological order as seen in FCP's marker list):
        // -------
        // <marker start="199199/12000s" duration="1001/24000s" value="Shot_01" completed="0"/>
        // <marker start="839839/12000s" duration="1001/24000s" value="Shot_02" completed="0"/>
        // <marker start="417417/4000s" duration="1001/24000s" value="Shot_03"/>
        // <marker start="10881/160s" duration="1001/24000s" value="Shot_04" completed="0"/>
        // <marker start="4445441/24000s" duration="1001/24000s" value="Shot_05"/>
        // <marker start="161441/960s" duration="1001/24000s" value="Shot_06" completed="0"/>
        // <marker start="2509507/8000s" duration="1001/24000s" value="Shot_07" completed="0"/>
        // <chapter-marker start="2757197/24000s" duration="1001/24000s" value="Shot_08" posterOffset="11/24s"/>
        // <marker start="1550549/4000s" duration="1001/24000s" value="Shot_09" completed="0"/>
        // <marker start="23023/75s" duration="1001/24000s" value="Shot_10"/>
        // <marker start="11011/7500s" duration="1001/30000s" value="Marker 2"/>
        // <marker start="239239/30000s" duration="1001/30000s" value="Marker 3"/>
        // <marker start="287287/30000s" duration="1001/30000s" value="Marker 4"/>
        // <marker start="154573/10000s" duration="1001/30000s" value="Marker 8"/>
        // <marker start="501757/30000s" duration="1001/30000s" value="Marker 9"/>
        // <marker start="109109/2500s" duration="1001/30000s" value="Marker 1"/>
        // <marker start="1314313/30000s" duration="1001/30000s" value="Marker 10"/>
        // <marker start="11011/250s" duration="1001/30000s" value="Marker 11"/>
        // <marker start="1328327/30000s" duration="1001/30000s" value="Marker 12"/>
        // <marker start="1692691/30000s" duration="1001/30000s" value="Marker 13"/>
        // <marker start="851851/15000s" duration="1001/30000s" value="Marker 14"/>
        // <marker start="853853/15000s" duration="1001/30000s" value="Marker 15"/>
        // <marker start="673673/15000s" duration="1001/30000s" value="Marker 16"/>
        // <marker start="871871/15000s" duration="1001/30000s" value="Marker 17"/>
        // <marker start="76681/2000s" duration="1001/30000s" value="Marker 18"/>
        // <marker start="1206271/30000s" duration="1001/30000s" value="Marker 19"/>
        // <marker start="9009/10000s" duration="1001/30000s" value="Marker 23"/>
        // <marker start="227227/2500s" duration="1001/30000s" value="Marker 20"/>
        // <marker start="187187/2000s" duration="1001/30000s" value="Marker 21"/>
        // <marker start="953953/10000s" duration="1001/30000s" value="Marker 22"/>
        
        struct MarkerData {
            let absTC: String // Absolute timecode, as seen in FCP
            let name: String
            let config: FinalCutPro.FCPXML.Marker.Configuration
            let occ: FinalCutPro.FCPXML.ElementOcclusion
        }
        
        // swiftformat:disable all
        let markerList: [MarkerData] = [
            MarkerData(absTC: "00:00:16:33.51", name: "Shot_01", config: .toDo(completed: false), occ: .notOccluded),
            MarkerData(absTC: "00:00:52:14.43", name: "Shot_02", config: .toDo(completed: false), occ: .notOccluded),
            MarkerData(absTC: "00:01:26:34.00", name: "Shot_03", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:01:53:36.31", name: "Shot_04", config: .toDo(completed: false), occ: .notOccluded),
            MarkerData(absTC: "00:02:10:36.40", name: "Shot_05", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:02:18:21.08", name: "Shot_06", config: .toDo(completed: false), occ: .notOccluded),
            // MarkerData(absTC: "00:02:18:21.08", name: "Shot_06", config: .toDo(completed: false), occ: .notOccluded),
            MarkerData(absTC: "00:02:24:03.78", name: "Shot_07", config: .toDo(completed: false), occ: .notOccluded),
            MarkerData(absTC: "00:03:17:00.68", name: "Shot_08", config: .chapter(posterOffset: Fraction(11, 24)), occ: .notOccluded),
            MarkerData(absTC: "00:03:36:06.09", name: "Shot_09", config: .toDo(completed: false), occ: .notOccluded),
            MarkerData(absTC: "00:03:44:42.43", name: "Shot_10", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:03:55:02.07", name: "Marker 2", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:03:57:52.04", name: "Marker 3", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:03:59:28.12", name: "Marker 4", config: .standard, occ: .notOccluded),
            
            // r8 media markers
            MarkerData(absTC: "00:04:01:56.06", name: "INSIDE 1", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:03:34.14", name: "INSIDE 2", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:05:04.21", name: "INSIDE 3", config: .standard, occ: .fullyOccluded),
            
            MarkerData(absTC: "00:04:05:22.46", name: "Marker 8", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:06:38.52", name: "Marker 9", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:07:46.01", name: "Marker 1", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:07:56.02", name: "Marker 10", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:08:10.03", name: "Marker 11", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:08:24.04", name: "Marker 12", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:08:26.00", name: "Marker 13", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:08:36.00", name: "Marker 14", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:08:44.00", name: "Marker 15", config: .standard, occ: .notOccluded), // 00:04:08:44.01 in FCP, off by 1 subframe
            MarkerData(absTC: "00:04:09:02.07", name: "Marker 16", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:09:18.00", name: "Marker 17", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:13:26.16", name: "Marker 18", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:15:18.25", name: "Marker 19", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:17:52.04", name: "Marker 23", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:17:54.08", name: "Marker 20", config: .standard, occ: .notOccluded),
            
            // r8 media markers
            MarkerData(absTC: "00:04:18:22.06", name: "INSIDE 1", config: .standard, occ: .notOccluded),
            MarkerData(absTC: "00:04:20:00.14", name: "INSIDE 2", config: .standard, occ: .fullyOccluded),
            
            MarkerData(absTC: "00:04:20:36.21", name: "Marker 21", config: .standard, occ: .notOccluded),
            
            // r8 media markers
            MarkerData(absTC: "00:04:21:30.21", name: "INSIDE 3", config: .standard, occ: .fullyOccluded),
            
            MarkerData(absTC: "00:04:22:24.30", name: "Marker 22", config: .standard, occ: .notOccluded)
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
    
    func testEdgeCase() async throws {
        // load file
        let rawData = try fileContents
        
        // load
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let events = fcpxml.allEvents()
        let event = try XCTUnwrap(events[safe: 0])
        
        // project
        let projects = event.projects.zeroIndexed
        let project = try XCTUnwrap(projects[safe: 0])
        
        // sequence
        let sequence = project.sequence
        
        // spine
        let spine = try XCTUnwrap(sequence.spine)
        
        let storyElements = spine.storyElements.zeroIndexed
        
        // asset-clip @ 00:03:30:34 absolute timecode
        let assetClip1 = try XCTUnwrap(storyElements[safe: 8]?.fcpAsAssetClip)
        XCTAssertEqual(
            assetClip1.offset?.doubleValue,
            Fraction(75804000, 360000).doubleValue // NOT scaled
        )
        XCTAssertEqual(
            assetClip1.start?.doubleValue,
            Fraction(143286143, 375000).doubleValue / 1.001 // scaled
        )
        
        let ac1StoryElements = assetClip1.storyElements.zeroIndexed
        
        // asset-clip @ 00:03:37:38 absolute timecode
        let assetClip2 = try XCTUnwrap(ac1StoryElements[safe: 0]?.fcpAsAssetClip)
        XCTAssertEqual(
            assetClip2.offset?.doubleValue,
            Fraction(145938793, 375000).doubleValue / 1.001 // scaled
        )
        XCTAssertEqual(
            assetClip2.start?.doubleValue,
            Fraction(299890591, 1000000).doubleValue / 1.001 // scaled
        )
        
        XCTAssertEqual(
            assetClip2.element
                .fcpAncestorTimeline(includingSelf: true, withLaneZero: false)?
                .timeline,
            assetClip2.element
        )
        XCTAssertEqual(
            assetClip2.element
                ._fcpConformRateScalingFactor(timelineFrameRate: nil,
                                              includingSelf: true),
            1 / 1.001
        )
    }
}

#endif
