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
    
    // MARK: Resources
    
    let r1 = FinalCutPro.FCPXML.Format(
        id: "r1",
        name: "FFVideoFormat1080p25",
        frameDuration: "100/2500s",
        fieldOrder: nil,
        width: 1920,
        height: 1080,
        paspH: nil,
        paspV: nil,
        colorSpace: "1-1-1 (Rec. 709)",
        projection: nil,
        stereoscopic: nil
    )
    
    let r2MediaRep = FinalCutPro.FCPXML.MediaRep(
        kind: "original-media",
        sig: "30C3729DCEE936129873D803DC13B623",
        src: URL(string: "file:///Users/user/Movies/MyLibrary.fcpbundle/Test%20Event/Original%20Media/TestVideo.m4v")!,
        bookmark: nil
    )
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
    lazy var r2Metadata = FinalCutPro.FCPXML.Metadata(fromMetadataElement: r2MetadataXML)
    lazy var r2 = FinalCutPro.FCPXML.Asset(
        id: "r2",
        name: "TestVideo",
        start: "0s",
        duration: "738000/25000s",
        format: "r3",
        uid: "30C3729DCEE936129873D803DC13B623",
        hasVideo: true,
        hasAudio: true,
        audioSources: 1,
        audioChannels: 2,
        audioRate: 44100,
        videoSources: 1,
        auxVideoFlags: nil,
        mediaRep: r2MediaRep,
        metadata: r2Metadata
    )
    
    let r3 = FinalCutPro.FCPXML.Format(
        id: "r3",
        name: "FFVideoFormat640x480p25",
        frameDuration: "100/2500s",
        fieldOrder: nil,
        width: 640,
        height: 480,
        paspH: nil,
        paspV: nil,
        colorSpace: "6-1-6 (Rec. 601 (NTSC))",
        projection: nil,
        stereoscopic: nil
    )
    
    lazy var resources: [String: FinalCutPro.FCPXML.AnyResource] = [
        r1.id: r1.asAnyResource(),
        r2.id: r2.asAnyResource(),
        r3.id: r3.asAnyResource()
    ]
    
    // MARK: - Tests
    
    func testParse() throws {
        // load file
        
        let rawData = try fileContents
        
        // parse file
        
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // version
        
        XCTAssertEqual(fcpxml.version, .ver1_11)
        
        // resources
        
        let resources = fcpxml.resources()
        
        XCTAssertEqual(resources.count, 3)
        
        XCTAssertEqual(resources["r1"], .format(r1))
        
        XCTAssertEqual(resources["r2"], .asset(r2))
        
        XCTAssertEqual(resources["r3"], .format(r3))
        
        // library
        
        let library = try XCTUnwrap(fcpxml.library())
        
        let libraryURL = URL(string: "file:///Users/user/Movies/MyLibrary.fcpbundle/")
        XCTAssertEqual(library.location, libraryURL)
        
        // events
        
        let events = fcpxml.allEvents()
        XCTAssertEqual(events.count, 1)
        
        let event = try XCTUnwrap(events[safe: 0])
        XCTAssertEqual(event.name, "Test Event")
        
        // projects
        
        let projects = try XCTUnwrap(events[safe: 0]).projects
        XCTAssertEqual(projects.count, 1)
        
        let project = try XCTUnwrap(projects[safe: 0])
        XCTAssertEqual(project.name, "Annotations")
        XCTAssertEqual(project.startTimecode, Self.tc("01:00:00:00", .fps25))
        
        // sequence
        
        let sequence = try XCTUnwrap(projects[safe: 0]).sequence
        XCTAssertEqual(sequence.formatID, "r1")
        XCTAssertEqual(sequence.startTimecode, Self.tc("01:00:00:00", .fps25))
        XCTAssertEqual(sequence.startTimecode?.frameRate, .fps25)
        XCTAssertEqual(sequence.startTimecode?.subFramesBase, .max80SubFrames)
        XCTAssertEqual(sequence.duration, Self.tc("00:00:29:13", .fps25))
        XCTAssertEqual(sequence.audioLayout, .stereo)
        XCTAssertEqual(sequence.audioRate, .rate48kHz)
        
        // story elements (clips etc.)
        
        let spine = sequence.spine
        XCTAssertEqual(spine.contents.count, 1)
                
        guard case let .anyClip(.assetClip(element1)) = spine.contents[0] 
        else { XCTFail("Clip was not expected type.") ; return }
        XCTAssertEqual(element1.ref, "r2")
        XCTAssertEqual(element1.offset, Self.tc("01:00:00:00", .fps25))
        XCTAssertEqual(element1.offset?.frameRate, .fps25)
        XCTAssertEqual(element1.name, "TestVideo Clip")
        XCTAssertEqual(element1.start, nil)
        XCTAssertEqual(element1.duration, Self.tc("00:00:29:13", .fps25))
        XCTAssertEqual(element1.duration?.frameRate, .fps25)
        XCTAssertEqual(element1.audioRole?.rawValue, "dialogue")
        
        // markers
        
        let element1Markers = element1.contents.annotations().markers()
        XCTAssertEqual(element1Markers.count, 1)
        
        let expectedE1Marker0 = FinalCutPro.FCPXML.Marker(
            start: Self.tc("00:00:27:10", .fps25),
            duration: Self.tc("00:00:00:01", .fps25),
            name: "marker1",
            metaData: .standard,
            note: "m1 notes"
        )
        XCTAssertEqual(element1Markers[safe: 0], expectedE1Marker0)
        
        // keywords
        
        let element1Keywords = element1.contents.annotations().keywords()
        XCTAssertEqual(element1Keywords.count, 2)
        
        // this keyword applies to entire video clip
        let expectedE1Keyword0 = FinalCutPro.FCPXML.Keyword(
            name: "keyword1",
            start: Self.tc("00:00:00:00", .fps25),
            duration: Self.tc("00:00:29:13", .fps25),
            note: "k1 notes"
        )
        XCTAssertEqual(element1Keywords[safe: 0], expectedE1Keyword0)
        
        let expectedE1Keyword1 = FinalCutPro.FCPXML.Keyword(
            name: "keyword2",
            start: Self.tc("00:00:15:20", .fps25),
            duration: Self.tc("00:00:08:11", .fps25),
            note: "k2 notes"
        )
        XCTAssertEqual(element1Keywords[safe: 1], expectedE1Keyword1)
        
        // captions
        
        let element1Captions = element1.contents.annotations().captions()
        XCTAssertEqual(element1Captions.count, 2)
        
        let element1Caption0 = try XCTUnwrap(element1Captions[safe: 0])
        XCTAssertEqual(element1Caption0.note, nil)
        XCTAssertEqual(element1Caption0.role?.rawValue, "iTT?captionFormat=ITT.en")
        XCTAssertEqual(element1Caption0.texts, [
            FinalCutPro.FCPXML.Text(
                rollUpHeight: nil,
                position: nil,
                placement: "bottom",
                alignment: nil,
                textStrings: [
                    FinalCutPro.FCPXML.Text.TextString(ref: "ts1", string: "caption1 text")
                ]
            )
        ])
        XCTAssertEqual(element1Caption0.textStyleDefinitions, [
            try! XMLElement(xmlString: """
                <text-style-def id="ts1">
                    <text-style font=".AppleSystemUIFont" fontSize="13" fontFace="Regular" fontColor="1 1 1 1" backgroundColor="0 0 0 1" tabStops="28L 56L 84L 112L 140L 168L 196L 224L 252L 280L 308L 336L"/>
                </text-style-def>
                """)
        ])
        XCTAssertEqual(element1Caption0.lane, 1)
        XCTAssertEqual(element1Caption0.offset, Self.tc("00:00:03:00", .fps25))
        XCTAssertEqual(element1Caption0.name, "caption1")
        XCTAssertEqual(element1Caption0.start, Self.tc("01:00:00:00", .fps25))
        XCTAssertEqual(element1Caption0.duration, Self.tc("00:00:04:00", .fps25))
        XCTAssertEqual(element1Caption0.enabled, false)
        XCTAssertEqual(element1Caption0.context[.absoluteStart], Self.tc("01:00:03:00", .fps25))
        XCTAssertEqual(
            element1Caption0.context[.localRoles],
            [FinalCutPro.FCPXML.CaptionRole(rawValue: "iTT?captionFormat=ITT.en")!.asAnyRole()]
        )
        XCTAssertEqual(
            element1Caption0.context[.inheritedRoles],
            [
                .inherited(.audio(raw: "dialogue")!),
                .defaulted(.video(raw: "Video")!),
                .assigned(.caption(raw: "iTT?captionFormat=ITT.en")!)
            ]
        )
        
        let element1Caption1 = try XCTUnwrap(element1Captions[safe: 1])
        XCTAssertEqual(element1Caption1.note, nil)
        XCTAssertEqual(element1Caption1.role?.rawValue, "iTT?captionFormat=ITT.en")
        XCTAssertEqual(element1Caption1.texts, [
            FinalCutPro.FCPXML.Text(
                rollUpHeight: nil,
                position: nil,
                placement: "bottom",
                alignment: nil,
                textStrings: [
                    FinalCutPro.FCPXML.Text.TextString(ref: "ts2", string: "caption2 text")
                ]
            )
        ])
        XCTAssertEqual(element1Caption1.textStyleDefinitions, [
            try! XMLElement(xmlString: """
                <text-style-def id="ts2">
                    <text-style font=".AppleSystemUIFont" fontSize="13" fontFace="Regular" fontColor="1 1 1 1" backgroundColor="0 0 0 1" tabStops="28L 56L 84L 112L 140L 168L 196L 224L 252L 280L 308L 336L"/>
                </text-style-def>
                """)
        ])
        XCTAssertEqual(element1Caption1.lane, 1)
        XCTAssertEqual(element1Caption1.offset, Self.tc("00:00:09:10", .fps25))
        XCTAssertEqual(element1Caption1.name, "caption2")
        XCTAssertEqual(element1Caption1.start, Self.tc("01:00:00:00", .fps25))
        XCTAssertEqual(element1Caption1.duration, Self.tc("00:00:02:00", .fps25))
        XCTAssertEqual(element1Caption1.enabled, true)
        XCTAssertEqual(element1Caption1.context[.absoluteStart], Self.tc("01:00:09:10", .fps25))
        XCTAssertEqual(
            element1Caption1.context[.localRoles],
            [FinalCutPro.FCPXML.CaptionRole(rawValue: "iTT?captionFormat=ITT.en")!.asAnyRole()]
        )
        XCTAssertEqual(
            element1Caption1.context[.inheritedRoles],
            [
                .inherited(.audio(raw: "dialogue")!),
                .defaulted(.video(raw: "Video")!),
                .assigned(.caption(raw: "iTT?captionFormat=ITT.en")!)
            ]
        )
    }
}

#endif
