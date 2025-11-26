//
//  FinalCutPro FCPXML Frame Data Tests.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
@testable import DAWFileTools
import SwiftExtensions
import TimecodeKitCore

final class FinalCutPro_FCPXML_FrameData: FCPXMLTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try XCTUnwrap(loadFileContents(
            forResource: "ClipMetadata",
            withExtension: "fcpxml",
            subFolder: .fcpxmlExports
        ))
    } }
    
    func testFrameDataClips() async throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        let timeline = try XCTUnwrap(fcpxml.allTimelines().first)
        
        let fd = await timeline.extract(preset: .frameData, scope: .mainTimeline)
        
        // debug
        
        print(fd.timelineStart.stringValue() + "\n----")
        // dump(fd.clips)
        print(
            fd.clips
                .map { "\($0.start) ..< \($0.end) \($0.clip.element.fcpName ?? "<unknown clip name>")" }
                .joined(separator: "\n")
        )
        
        // check extracted clips
        
        guard fd.clips.count == 3 else { XCTFail() ; return }
        
        let clip1 = fd.clips[0]
        let clip2 = fd.clips[1]
        let clip3 = fd.clips[2]
        
        XCTAssertEqual(clip1.start.components, .init(h: 1, m: 00, s: 00, f: 00))
        XCTAssertEqual(clip1.end.components,   .init(h: 1, m: 01, s: 00, f: 00))
        
        XCTAssertEqual(clip2.start.components, .init(h: 1, m: 01, s: 00, f: 00))
        XCTAssertEqual(clip2.end.components,   .init(h: 1, m: 01, s: 10, f: 01))
        
        XCTAssertEqual(clip3.start.components, .init(h: 1, m: 01, s: 10, f: 01))
        XCTAssertEqual(clip3.end.components,   .init(h: 1, m: 01, s: 39, f: 14))
    }
    
    func testFrameDataFrames() async throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        let timeline = try XCTUnwrap(fcpxml.allTimelines().first)
        
        let fd = await timeline.extract(preset: .frameData, scope: .mainTimeline)
        
        // check individual timecodes (frames)
        
        do {
            let tc = Self.tc("01:00:00:00", .fps25)
            let _tcData = await fd.data(for: tc)
            let tcData = try XCTUnwrap(_tcData)
            
            XCTAssertEqual(tcData.timecode, tc)
            XCTAssertEqual(tcData.localTimecode, tc) // happens to align with main timeline
            XCTAssertEqual(tcData.clipName, "Clouds")
            XCTAssertEqual(tcData.keywords, [])
            XCTAssertEqual(tcData.markers.count, 0)
            XCTAssertEqual(tcData.metadata.count, 0) // generators don't have metadata in FCPXML
        }
        
        do {
            let tc = Self.tc("01:00:02:10", .fps25)
            let _tcData = await fd.data(for: tc)
            let tcData = try XCTUnwrap(_tcData)
            
            XCTAssertEqual(tcData.timecode, tc)
            XCTAssertEqual(tcData.localTimecode, tc) // happens to align with main timeline
            XCTAssertEqual(tcData.clipName, "Clouds")
            XCTAssertEqual(tcData.keywords, [])
            XCTAssertEqual(tcData.markers.count, 0)
            XCTAssertEqual(tcData.metadata.count, 0) // generators don't have metadata in FCPXML
        }
        
        do {
            let tc = Self.tc("01:00:59:24", .fps25)
            let _tcData = await fd.data(for: tc)
            let tcData = try XCTUnwrap(_tcData)
            
            XCTAssertEqual(tcData.timecode, tc)
            XCTAssertEqual(tcData.localTimecode, tc) // happens to align with main timeline
            XCTAssertEqual(tcData.clipName, "Clouds")
            XCTAssertEqual(tcData.keywords, [])
            XCTAssertEqual(tcData.markers.count, 0)
            XCTAssertEqual(tcData.metadata.count, 0) // generators don't have metadata in FCPXML
        }
        
        do {
            let tc = Self.tc("01:00:59:24.79", .fps25)
            let _tcData = await fd.data(for: tc)
            let tcData = try XCTUnwrap(_tcData)
            
            XCTAssertEqual(tcData.timecode, tc)
            XCTAssertEqual(tcData.localTimecode, tc) // happens to align with main timeline
            XCTAssertEqual(tcData.clipName, "Clouds")
            XCTAssertEqual(tcData.keywords, [])
            XCTAssertEqual(tcData.markers.count, 0)
            XCTAssertEqual(tcData.metadata.count, 0) // generators don't have metadata in FCPXML
        }
        
        do {
            let tc = Self.tc("01:01:00:00", .fps25)
            let _tcData = await fd.data(for: tc)
            let tcData = try XCTUnwrap(_tcData)
            
            XCTAssertEqual(tcData.timecode, tc)
            XCTAssertEqual(tcData.localTimecode, Self.tc("01:00:00:00", .fps25))
            XCTAssertEqual(tcData.clipName, "Basic Title")
            XCTAssertEqual(tcData.keywords, [])
            XCTAssertEqual(tcData.markers.count, 0)
            XCTAssertEqual(tcData.metadata.count, 0) // generators don't have metadata in FCPXML
        }
        
        do {
            let tc = Self.tc("01:01:10:00.79", .fps25)
            let _tcData = await fd.data(for: tc)
            let tcData = try XCTUnwrap(_tcData)
            
            XCTAssertEqual(tcData.timecode, tc)
            XCTAssertEqual(tcData.localTimecode, Self.tc("01:00:10:00.79", .fps25))
            XCTAssertEqual(tcData.clipName, "Basic Title")
            XCTAssertEqual(tcData.keywords, [])
            XCTAssertEqual(tcData.markers.count, 0)
            XCTAssertEqual(tcData.metadata.count, 0) // generators don't have metadata in FCPXML
        }
        
        do {
            let tc = Self.tc("01:01:10:01", .fps25)
            let _tcData = await fd.data(for: tc)
            let tcData = try XCTUnwrap(_tcData)
            
            XCTAssertEqual(tcData.timecode, tc)
            XCTAssertEqual(tcData.localTimecode, tc - Self.tc("01:01:10:01", .fps25))
            XCTAssertEqual(tcData.clipName, "TestVideo")
            XCTAssertEqual(tcData.keywords, ["keyword1"])
            XCTAssertEqual(tcData.markers.count, 0)
            XCTAssertEqual(tcData.metadata.count, 11)
        }
        
        do {
            let tc = Self.tc("01:01:25:20.79", .fps25)
            let _tcData = await fd.data(for: tc)
            let tcData = try XCTUnwrap(_tcData)
            
            XCTAssertEqual(tcData.timecode, tc)
            XCTAssertEqual(tcData.localTimecode, tc - Self.tc("01:01:10:01", .fps25))
            XCTAssertEqual(tcData.clipName, "TestVideo")
            XCTAssertEqual(tcData.keywords, ["keyword1"])
            XCTAssertEqual(tcData.markers.count, 0)
            XCTAssertEqual(tcData.metadata.count, 11)
        }
        
        do {
            let tc = Self.tc("01:01:25:21", .fps25)
            let _tcData = await fd.data(for: tc)
            let tcData = try XCTUnwrap(_tcData)
            
            XCTAssertEqual(tcData.timecode, tc)
            XCTAssertEqual(tcData.localTimecode, tc - Self.tc("01:01:10:01", .fps25))
            XCTAssertEqual(tcData.clipName, "TestVideo")
            XCTAssertEqual(tcData.keywords, ["keyword1", "keyword2"])
            XCTAssertEqual(tcData.markers.count, 0)
        }
        
        do {
            let tc = Self.tc("01:01:34:06.79", .fps25)
            let _tcData = await fd.data(for: tc)
            let tcData = try XCTUnwrap(_tcData)
            
            XCTAssertEqual(tcData.timecode, tc)
            XCTAssertEqual(tcData.localTimecode, tc - Self.tc("01:01:10:01", .fps25))
            XCTAssertEqual(tcData.clipName, "TestVideo")
            XCTAssertEqual(tcData.keywords, ["keyword1", "keyword2"])
            XCTAssertEqual(tcData.markers.count, 0)
            XCTAssertEqual(tcData.metadata.count, 11)
        }
        
        // TODO: should keyword range end timecode be included in its range?
        do {
            let tc = Self.tc("01:01:34:07", .fps25)
            let _tcData = await fd.data(for: tc)
            let tcData = try XCTUnwrap(_tcData)
            
            XCTAssertEqual(tcData.timecode, tc)
            XCTAssertEqual(tcData.localTimecode, tc - Self.tc("01:01:10:01", .fps25))
            XCTAssertEqual(tcData.clipName, "TestVideo")
            XCTAssertEqual(tcData.keywords, ["keyword1", "keyword2"])
            XCTAssertEqual(tcData.markers.count, 0)
            XCTAssertEqual(tcData.metadata.count, 11)
        }
        
        do {
            let tc = Self.tc("01:01:34:08", .fps25)
            let _tcData = await fd.data(for: tc)
            let tcData = try XCTUnwrap(_tcData)
            
            XCTAssertEqual(tcData.timecode, tc)
            XCTAssertEqual(tcData.localTimecode, tc - Self.tc("01:01:10:01", .fps25))
            XCTAssertEqual(tcData.clipName, "TestVideo")
            XCTAssertEqual(tcData.keywords, ["keyword1"])
            XCTAssertEqual(tcData.markers.count, 0)
            XCTAssertEqual(tcData.metadata.count, 11)
        }
        
        do {
            let tc = Self.tc("01:01:37:11", .fps25)
            let _tcData = await fd.data(for: tc)
            let tcData = try XCTUnwrap(_tcData)
            
            XCTAssertEqual(tcData.timecode, tc)
            XCTAssertEqual(tcData.localTimecode, tc - Self.tc("01:01:10:01", .fps25))
            XCTAssertEqual(tcData.clipName, "TestVideo")
            XCTAssertEqual(tcData.keywords, ["keyword1"])
            XCTAssertEqual(tcData.markers.count, 1)
            XCTAssertEqual(tcData.metadata.count, 11)
            
            let marker = try XCTUnwrap(tcData.markers.first)
            XCTAssertEqual(marker.name, "Marker 1")
        }
        
        do {
            let tc = Self.tc("01:01:37:11.79", .fps25)
            let _tcData = await fd.data(for: tc)
            let tcData = try XCTUnwrap(_tcData)
            
            XCTAssertEqual(tcData.timecode, tc)
            XCTAssertEqual(tcData.localTimecode, tc - Self.tc("01:01:10:01", .fps25))
            XCTAssertEqual(tcData.clipName, "TestVideo")
            XCTAssertEqual(tcData.keywords, ["keyword1"])
            XCTAssertEqual(tcData.markers.count, 1)
            XCTAssertEqual(tcData.metadata.count, 11)
            
            let marker = try XCTUnwrap(tcData.markers.first)
            XCTAssertEqual(marker.name, "Marker 1")
        }
        
        do {
            let tc = Self.tc("01:01:39:13.79", .fps25)
            let _tcData = await fd.data(for: tc)
            let tcData = try XCTUnwrap(_tcData)
            
            XCTAssertEqual(tcData.timecode, tc)
            XCTAssertEqual(tcData.localTimecode, tc - Self.tc("01:01:10:01", .fps25))
            XCTAssertEqual(tcData.clipName, "TestVideo")
            XCTAssertEqual(tcData.keywords, ["keyword1"])
            XCTAssertEqual(tcData.markers.count, 0)
            XCTAssertEqual(tcData.metadata.count, 11)
        }
        
        do {
            let tc = Self.tc("01:01:39:14", .fps25)
            let _tcData = await fd.data(for: tc)
            XCTAssertNil(_tcData)
        }
    }
}

#endif
