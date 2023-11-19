//
//  FinalCutPro FCPXML 25i.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
@testable import DAWFileKit
import OTCore
import TimecodeKit

class FinalCutPro_FCPXML_25i: XCTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    /// Tests:
    /// - `media` resources
    /// - `ref-clip` clips
    /// - mixed frame rates
    /// - that fraction time values that have subframes correctly convert to Timecode.
    func testParse() throws {
        // load file
        
        let rawData = try XCTUnwrap(loadFileContents(
            forResource: "25i",
            withExtension: "fcpxml",
            subFolder: .fcpxmlExports
        ))
        
        // load
        
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // version
        
        XCTAssertEqual(fcpxml.version, .ver1_10)
        
        // resources
        
        let resources = fcpxml.resources()
        
        XCTAssertEqual(resources.count, 6)
        
        let r1 = FinalCutPro.FCPXML.Format(
            id: "r1",
            name: "FFVideoFormatDV720x576i50",
            frameDuration: "200/5000s",
            fieldOrder: "lower first",
            width: 720,
            height: 576,
            paspH: "59",
            paspV: "54",
            colorSpace: "5-1-6 (Rec. 601 (PAL))",
            projection: nil,
            stereoscopic: nil
        )
        XCTAssertEqual(resources["r1"], .format(r1))
        
        let r2Child1 = try XMLElement(xmlString: """
            <media-rep kind="original-media" sig="554B59605B289ECE8057E7FECBC3D3D0" src="file:///Users/user/Desktop/Marker_Interlaced.fcpbundle/11-9-22/Original%20Media/Test%20Video%20(29.97%20fps).mp4">
            </media-rep>
            """
        )
        let r2Child2 = try XMLElement(xmlString: """
            <metadata>
                <md key="com.apple.proapps.studio.rawToLogConversion" value="0"/>
                <md key="com.apple.proapps.spotlight.kMDItemProfileName" value="HD (1-1-1)"/>
                <md key="com.apple.proapps.studio.cameraISO" value="0"/>
                <md key="com.apple.proapps.studio.cameraColorTemperature" value="0"/>
                <md key="com.apple.proapps.spotlight.kMDItemCodecs">
                    <array>
                        <string>'avc1'</string>
                        <string>MPEG-4 AAC</string>
                    </array>
                </md>
                <md key="com.apple.proapps.mio.ingestDate" value="2022-09-10 19:25:11 -0700"/>
            </metadata>
            """
        )
        let r2 = FinalCutPro.FCPXML.Asset(
            id: "r2",
            name: "Test Video (29.97 fps)",
            start: "0s",
            duration: "101869/1000s",
            format: "r3",
            uid: "554B59605B289ECE8057E7FECBC3D3D0",
            hasVideo: true,
            hasAudio: true,
            audioSources: 1,
            audioChannels: 2,
            audioRate: 48000,
            videoSources: 1,
            auxVideoFlags: nil,
            xmlChildren: [r2Child1, r2Child2]
        )
        XCTAssertEqual(resources["r2"], .asset(r2))
        
        let r3 = FinalCutPro.FCPXML.Format(
            id: "r3",
            name: "FFVideoFormat1080p2997",
            frameDuration: "1001/30000s",
            fieldOrder: nil,
            width: 1920,
            height: 1080,
            paspH: nil,
            paspV: nil,
            colorSpace: "1-1-1 (Rec. 709)",
            projection: nil,
            stereoscopic: nil
        )
        XCTAssertEqual(resources["r3"], .format(r3))
        
        #warning("> TODO: implement media resource")
//        let r4 = FinalCutPro.FCPXML.Media
//        XCTAssertEqual(resources["r4"], .format(r4))
        
        let r5 = FinalCutPro.FCPXML.Effect(
            id: "r5",
            name: "Black & White",
            uid: ".../Effects.localized/Color.localized/Black & White.localized/Black & White.moef",
            src: nil
        )
        XCTAssertEqual(resources["r5"], .effect(r5))
        
        let r6 = FinalCutPro.FCPXML.Effect(
            id: "r6",
            name: "Colorize",
            uid: ".../Effects.localized/Color.localized/Colorize.localized/Colorize.moef",
            src: nil
        )
        XCTAssertEqual(resources["r6"], .effect(r6))
        
        // library
        
        let library = try XCTUnwrap(fcpxml.library(contextBuilder: .default))
        
        let libraryURL = URL(string: "file:///Users/user/Desktop/Marker_Interlaced.fcpbundle/")
        XCTAssertEqual(library.location, libraryURL)
        
        // events
        
        let events = fcpxml.allEvents(contextBuilder: .ancestors)
        
        XCTAssertEqual(events.count, 1)
        
        let event = try XCTUnwrap(events[safe: 0])
        XCTAssertEqual(event.name, "11-9-22")
        
        // projects
        
        let projects = try XCTUnwrap(events[safe: 0]).projects
        
        XCTAssertEqual(projects.count, 1)
        
        let project = try XCTUnwrap(projects[safe: 0])
        XCTAssertEqual(project.name, "25i_V1")
        XCTAssertEqual(project.startTimecode, try Timecode(.rational(0, 1), at: .fps29_97, base: .max80SubFrames))
        
        // sequence
        
        let sequence = try XCTUnwrap(projects[safe: 0]).sequence
        
        XCTAssertEqual(sequence.formatID, "r1")
        XCTAssertEqual(sequence.startTimecode, Timecode(.zero, at: .fps29_97, base: .max80SubFrames))
        XCTAssertEqual(sequence.startTimecode?.frameRate, .fps25)
        XCTAssertEqual(sequence.startTimecode?.subFramesBase, .max80SubFrames)
        XCTAssertEqual(sequence.duration, try Timecode(.components(h: 00, m: 00, s: 29, f: 13), at: .fps25, base: .max80SubFrames))
        XCTAssertEqual(sequence.audioLayout, .stereo)
        XCTAssertEqual(sequence.audioRate, .rate48kHz)
        
        // story elements (clips etc.)
        
        let spine = sequence.spine
        
        XCTAssertEqual(spine.elements.count, 7)
        
        guard case let .anyClip(.assetClip(element1)) = spine.elements[0] else { XCTFail("Clip was not expected type.") ; return }
        // TODO: contains a `conform-rate` child - do we need to do math based on its attributes?
        
        XCTAssertEqual(element1.ref, "r2")
        XCTAssertEqual(element1.offset, Timecode(.zero, at: .fps29_97, base: .max80SubFrames))
        XCTAssertEqual(element1.offset?.frameRate, .fps29_97)
        XCTAssertEqual(element1.name, "Test Video (29.97 fps)")
        XCTAssertEqual(element1.start, nil)
        XCTAssertEqual(element1.duration, try Timecode(.components(h: 00, m: 00, s: 03, f: 11, sf: 71), at: .fps29_97, base: .max80SubFrames))
        XCTAssertEqual(element1.duration?.frameRate, .fps29_97)
        XCTAssertEqual( // compare to parent's frame rate
            try element1.duration?.converted(to: .fps25).adding(.frames(0, subFrames: 1)), // FCP rounds up to next subframe
            try Timecode(.components(h: 00, m: 00, s: 03, f: 10), at: .fps25, base: .max80SubFrames) // confirmed in FCP
        )
        XCTAssertEqual(element1.audioRole, "dialogue")
        
        // markers
        
        let markers = element1.contents.annotations().markers()
        
        XCTAssertEqual(markers.count, 1)
        
        let expectedMarker0 = FinalCutPro.FCPXML.Marker(
            start: try Timecode(.components(h: 00, m: 00, s: 01, f: 11, sf: 56), at: .fps25, base: .max80SubFrames) // confirmed in FCP
                .converted(to: .fps29_97)
                .adding(.frames(0, subFrames: 1)), // FCP rounds up to next subframe
            duration: try Timecode(.components(f: 1), at: .fps29_97, base: .max80SubFrames),
            name: "Marker 2",
            metaData: .standard,
            note: nil
        )
        XCTAssertEqual(markers[safe: 0], expectedMarker0)
        
        #warning("> TODO: finish unit test to check ref-clip contents")
    }
}

#endif
