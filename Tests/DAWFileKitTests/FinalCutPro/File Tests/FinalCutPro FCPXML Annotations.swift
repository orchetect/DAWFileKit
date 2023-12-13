//
//  FinalCutPro FCPXML Annotations.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
@testable import DAWFileKit
import OTCore
import TimecodeKit

final class FinalCutPro_FCPXML_Annotations: FCPXMLTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try XCTUnwrap(loadFileContents(
            forResource: "Annotations",
            withExtension: "fcpxml",
            subFolder: .fcpxmlExports
        ))
    } }
    
    // MARK: - Tests
    
    func testParse() throws {
        // load file
        
        let rawData = try fileContents
        
        // parse file
        
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // version
        
        XCTAssertEqual(fcpxml.version, .ver1_11)
        
        // resources
        
        let resources = fcpxml.root.resources
        
        XCTAssertEqual(resources.childElements.count, 3)
        
        let r1 = try XCTUnwrap(resources.childElements[safe: 0]?.fcpAsFormat)
        XCTAssertEqual(r1.id, "r1")
        XCTAssertEqual(r1.name, "FFVideoFormat1080p25")
        XCTAssertEqual(r1.frameDuration, Fraction(100,2500))
        XCTAssertEqual(r1.fieldOrder, nil)
        XCTAssertEqual(r1.width, 1920)
        XCTAssertEqual(r1.height, 1080)
        XCTAssertEqual(r1.paspH, nil)
        XCTAssertEqual(r1.paspV, nil)
        XCTAssertEqual(r1.colorSpace, "1-1-1 (Rec. 709)")
        XCTAssertEqual(r1.projection, nil)
        XCTAssertEqual(r1.stereoscopic, nil)
        
        let r2 = try XCTUnwrap(resources.childElements[safe: 1]?.fcpAsAsset)
        XCTAssertEqual(r2.id, "r2")
        XCTAssertEqual(r2.name, "TestVideo")
        XCTAssertEqual(r2.start, .zero)
        XCTAssertEqual(r2.duration, Fraction(738000, 25000))
        XCTAssertEqual(r2.format, "r3")
        XCTAssertEqual(r2.uid, "30C3729DCEE936129873D803DC13B623")
        XCTAssertEqual(r2.hasVideo, true)
        XCTAssertEqual(r2.hasAudio, true)
        XCTAssertEqual(r2.audioSources, 1)
        XCTAssertEqual(r2.audioChannels, 2)
        XCTAssertEqual(r2.audioRate, .rate44_1kHz)
        XCTAssertEqual(r2.videoSources, 1)
        XCTAssertEqual(r2.auxVideoFlags, nil)
        
        let r2MediaRep = try XCTUnwrap(r2.mediaRep)
        XCTAssertEqual(r2MediaRep.kind, .originalMedia)
        XCTAssertEqual(r2MediaRep.sig, "30C3729DCEE936129873D803DC13B623")
        XCTAssertEqual(r2MediaRep.src, URL(string: "file:///Users/user/Movies/MyLibrary.fcpbundle/Test%20Event/Original%20Media/TestVideo.m4v")!)
        XCTAssertEqual(r2MediaRep.bookmark, nil)
        
        let r2MetadataXML = try! XMLElement(xmlString: """
            <metadata>
                <md key="com.apple.proapps.studio.rawToLogConversion" value="0"/>
                <md key="com.apple.proapps.spotlight.kMDItemProfileName" value="SD (6-1-6)"/>
                <md key="com.apple.proapps.studio.cameraISO" value="0"/>
                <md key="com.apple.proapps.studio.cameraColorTemperature" value="0"/>
                <md key="com.apple.proapps.spotlight.kMDItemCodecs">
                    <array>
                        <string>'avc1'</string>
                        <string>MPEG-4 AAC</string>
                    </array>
                </md>
                <md key="com.apple.proapps.mio.ingestDate" value="2023-01-01 19:46:28 -0800"/>
            </metadata>
            """
        )
        let r2Metadata = FinalCutPro.FCPXML.Metadata(element: r2MetadataXML)
        XCTAssertEqual(r2.metadata, r2Metadata)
        
        let r3 = try XCTUnwrap(resources.childElements[safe: 2]?.fcpAsFormat)
        XCTAssertEqual(r3.id, "r3")
        XCTAssertEqual(r3.name, "FFVideoFormat640x480p25")
        XCTAssertEqual(r3.frameDuration, Fraction(100,2500))
        XCTAssertEqual(r3.fieldOrder, nil)
        XCTAssertEqual(r3.width, 640)
        XCTAssertEqual(r3.height, 480)
        XCTAssertEqual(r3.paspH, nil)
        XCTAssertEqual(r3.paspV, nil)
        XCTAssertEqual(r3.colorSpace, "6-1-6 (Rec. 601 (NTSC))")
        XCTAssertEqual(r3.projection, nil)
        XCTAssertEqual(r3.stereoscopic, nil)
        
        // library
        
        let library = try XCTUnwrap(fcpxml.root.library)
        
        let libraryURL = URL(string: "file:///Users/user/Movies/MyLibrary.fcpbundle/")
        XCTAssertEqual(library.location, libraryURL)
        
        // events
        
        let events = fcpxml.allEvents()
        XCTAssertEqual(events.count, 1)
        
        let event = try XCTUnwrap(events[safe: 0])
        XCTAssertEqual(event.name, "Test Event")
        
        // projects
        
        let projects = try XCTUnwrap(events[safe: 0]).projects.zeroIndexed
        XCTAssertEqual(projects.count, 1)

        let project = try XCTUnwrap(projects[safe: 0])
        XCTAssertEqual(project.name, "Annotations")
        XCTAssertEqual(project.startTimecode(), Self.tc("01:00:00:00", .fps25))
        
        // sequence
        
        let sequence = try XCTUnwrap(projects[safe: 0]?.sequence)
        XCTAssertEqual(sequence.format, "r1")
        XCTAssertEqual(sequence.tcStartAsTimecode(), Self.tc("01:00:00:00", .fps25))
        XCTAssertEqual(sequence.tcStartAsTimecode()?.frameRate, .fps25)
        XCTAssertEqual(sequence.tcStartAsTimecode()?.subFramesBase, .max80SubFrames)
        XCTAssertEqual(sequence.durationAsTimecode(), Self.tc("00:00:29:13", .fps25))
        XCTAssertEqual(sequence.audioLayout, .stereo)
        XCTAssertEqual(sequence.audioRate, .rate48kHz)
        
        // story elements (clips etc.)
        
        let spine = try XCTUnwrap(sequence.spine)
        XCTAssertEqual(spine.storyElements.count, 1)
        
        let storyElements = spine.storyElements.zeroIndexed
        
        let element1 = try XCTUnwrap(storyElements[safe: 0]?.fcpAsAssetClip)
        XCTAssertEqual(element1.ref, "r2")
        XCTAssertEqual(element1.offsetAsTimecode(), Self.tc("01:00:00:00", .fps25))
        XCTAssertEqual(element1.offsetAsTimecode()?.frameRate, .fps25)
        XCTAssertEqual(element1.name, "TestVideo Clip")
        XCTAssertEqual(element1.start, nil)
        XCTAssertEqual(element1.durationAsTimecode(), Self.tc("00:00:29:13", .fps25))
        XCTAssertEqual(element1.durationAsTimecode()?.frameRate, .fps25)
        XCTAssertEqual(element1.audioRole?.rawValue, "dialogue")
        
        #warning("> TODO: finish this - but can't test absolute timecodes without running element extraction")
        // markers
        
        let element1Markers = element1.contents.filter(whereFCPElement: .marker)
        XCTAssertEqual(element1Markers.count, 1)
        
//        let expectedE1Marker0 = FinalCutPro.FCPXML.Marker(
//            start: Self.tc("00:00:27:10", .fps25),
//            duration: Self.tc("00:00:00:01", .fps25),
//            name: "marker1",
//            state: .standard,
//            note: "m1 notes"
//        )
//        XCTAssertEqual(element1Markers[safe: 0], expectedE1Marker0)
        
        // keywords
        
//        let element1Keywords = element1.contents.annotations().keywords()
//        XCTAssertEqual(element1Keywords.count, 2)
//        
//        // this keyword applies to entire video clip
//        let expectedE1Keyword0 = FinalCutPro.FCPXML.Keyword(
//            name: "keyword1",
//            start: Self.tc("00:00:00:00", .fps25),
//            duration: Self.tc("00:00:29:13", .fps25),
//            note: "k1 notes"
//        )
//        XCTAssertEqual(element1Keywords[safe: 0], expectedE1Keyword0)
//        
//        let expectedE1Keyword1 = FinalCutPro.FCPXML.Keyword(
//            name: "keyword2",
//            start: Self.tc("00:00:15:20", .fps25),
//            duration: Self.tc("00:00:08:11", .fps25),
//            note: "k2 notes"
//        )
//        XCTAssertEqual(element1Keywords[safe: 1], expectedE1Keyword1)
//        
//        // captions
//        
//        let element1Captions = element1.contents.annotations().captions()
//        XCTAssertEqual(element1Captions.count, 2)
//        
//        let element1Caption0 = try XCTUnwrap(element1Captions[safe: 0])
//        XCTAssertEqual(element1Caption0.note, nil)
//        XCTAssertEqual(element1Caption0.role?.rawValue, "iTT?captionFormat=ITT.en")
//        XCTAssertEqual(element1Caption0.texts, [
//            FinalCutPro.FCPXML.Text(
//                rollUpHeight: nil,
//                position: nil,
//                placement: "bottom",
//                alignment: nil,
//                textStrings: [
//                    FinalCutPro.FCPXML.Text.TextString(ref: "ts1", string: "caption1 text")
//                ]
//            )
//        ])
//        XCTAssertEqual(element1Caption0.textStyleDefinitions, [
//            try! XMLElement(xmlString: """
//                <text-style-def id="ts1">
//                    <text-style font=".AppleSystemUIFont" fontSize="13" fontFace="Regular" fontColor="1 1 1 1" backgroundColor="0 0 0 1" tabStops="28L 56L 84L 112L 140L 168L 196L 224L 252L 280L 308L 336L"/>
//                </text-style-def>
//                """)
//        ])
//        XCTAssertEqual(element1Caption0.lane, 1)
//        XCTAssertEqual(element1Caption0.offset, Self.tc("00:00:03:00", .fps25))
//        XCTAssertEqual(element1Caption0.name, "caption1")
//        XCTAssertEqual(element1Caption0.start, Self.tc("01:00:00:00", .fps25))
//        XCTAssertEqual(element1Caption0.duration, Self.tc("00:00:04:00", .fps25))
//        XCTAssertEqual(element1Caption0.enabled, false)
//        XCTAssertEqual(element1Caption0.context[.absoluteStart], Self.tc("01:00:03:00", .fps25))
//        XCTAssertEqual(
//            element1Caption0.context[.localRoles],
//            [FinalCutPro.FCPXML.CaptionRole(rawValue: "iTT?captionFormat=ITT.en")!.asAnyRole()]
//        )
//        XCTAssertEqual(
//            element1Caption0.context[.inheritedRoles],
//            [
//                .inherited(.audio(raw: "dialogue")!),
//                .defaulted(.video(raw: "Video")!),
//                .assigned(.caption(raw: "iTT?captionFormat=ITT.en")!)
//            ]
//        )
//        
//        let element1Caption1 = try XCTUnwrap(element1Captions[safe: 1])
//        XCTAssertEqual(element1Caption1.note, nil)
//        XCTAssertEqual(element1Caption1.role?.rawValue, "iTT?captionFormat=ITT.en")
//        XCTAssertEqual(element1Caption1.texts, [
//            FinalCutPro.FCPXML.Text(
//                rollUpHeight: nil,
//                position: nil,
//                placement: "bottom",
//                alignment: nil,
//                textStrings: [
//                    FinalCutPro.FCPXML.Text.TextString(ref: "ts2", string: "caption2 text")
//                ]
//            )
//        ])
//        XCTAssertEqual(element1Caption1.textStyleDefinitions, [
//            try! XMLElement(xmlString: """
//                <text-style-def id="ts2">
//                    <text-style font=".AppleSystemUIFont" fontSize="13" fontFace="Regular" fontColor="1 1 1 1" backgroundColor="0 0 0 1" tabStops="28L 56L 84L 112L 140L 168L 196L 224L 252L 280L 308L 336L"/>
//                </text-style-def>
//                """)
//        ])
//        XCTAssertEqual(element1Caption1.lane, 1)
//        XCTAssertEqual(element1Caption1.offset, Self.tc("00:00:09:10", .fps25))
//        XCTAssertEqual(element1Caption1.name, "caption2")
//        XCTAssertEqual(element1Caption1.start, Self.tc("01:00:00:00", .fps25))
//        XCTAssertEqual(element1Caption1.duration, Self.tc("00:00:02:00", .fps25))
//        XCTAssertEqual(element1Caption1.enabled, true)
//        XCTAssertEqual(element1Caption1.context[.absoluteStart], Self.tc("01:00:09:10", .fps25))
//        XCTAssertEqual(
//            element1Caption1.context[.localRoles],
//            [FinalCutPro.FCPXML.CaptionRole(rawValue: "iTT?captionFormat=ITT.en")!.asAnyRole()]
//        )
//        XCTAssertEqual(
//            element1Caption1.context[.inheritedRoles],
//            [
//                .inherited(.audio(raw: "dialogue")!),
//                .defaulted(.video(raw: "Video")!),
//                .assigned(.caption(raw: "iTT?captionFormat=ITT.en")!)
//            ]
//        )
    }
}

#endif
