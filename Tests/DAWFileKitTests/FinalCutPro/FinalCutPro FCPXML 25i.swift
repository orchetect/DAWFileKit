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

final class FinalCutPro_FCPXML_25i: FCPXMLTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try XCTUnwrap(loadFileContents(
            forResource: "25i",
            withExtension: "fcpxml",
            subFolder: .fcpxmlExports
        ))
    } }
    
    // MARK: Resources
    
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
    
    let r2MediaRep = FinalCutPro.FCPXML.MediaRep(
        kind: "original-media",
        sig: "554B59605B289ECE8057E7FECBC3D3D0",
        src: URL(string: "file:///Users/user/Desktop/Marker_Interlaced.fcpbundle/11-9-22/Original%20Media/Test%20Video%20(29.97%20fps).mp4")!,
        bookmark: nil
    )
    lazy var r2MetadataXML = try! XMLElement(xmlString: """
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
    lazy var r2Metadata = FinalCutPro.FCPXML.Metadata(fromMetadataElement: r2MetadataXML)
    lazy var r2 = FinalCutPro.FCPXML.Asset(
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
        mediaRep: r2MediaRep,
        metadata: r2Metadata
    )
    
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
    
    let r4SequenceXML = try! XMLElement(xmlString: """
        <sequence format="r3" duration="174174/30000s" tcStart="0s" tcFormat="NDF" audioLayout="stereo" audioRate="48k">
        <spine>
            <asset-clip ref="r2" offset="0s" name="Media Clip" start="452452/30000s" duration="174174/30000s" tcFormat="NDF" audioRole="dialogue">
                <marker start="247247/15000s" duration="1001/30000s" value="Marker 5"/>
                <marker start="181181/10000s" duration="1001/30000s" value="Marker 6"/>
                <marker start="49049/2500s" duration="1001/30000s" value="Marker 7"/>
            </asset-clip>
        </spine>
        </sequence>
        """
    )
    lazy var r4MediaXML: XMLElement = {
        let m = try! XMLElement(xmlString: """
        <media id="r4" name="29.97_CC" uid="GYR/OKBAQ/2tErV+GGXCuA" modDate="2022-09-10 23:08:42 -0700">
        </media>
        """
        )
        m.addChild(r4SequenceXML)
        return m
    }()
    lazy var r4 = FinalCutPro.FCPXML.Media(
        id: "r4",
        name: "29.97_CC",
        contents: .sequence(fromXML: r4SequenceXML, parentMediaXML: r4MediaXML)
    )
    
    let r5 = FinalCutPro.FCPXML.Effect(
        id: "r5",
        name: "Black & White",
        uid: ".../Effects.localized/Color.localized/Black & White.localized/Black & White.moef",
        src: nil
    )
    
    let r6 = FinalCutPro.FCPXML.Effect(
        id: "r6",
        name: "Colorize",
        uid: ".../Effects.localized/Color.localized/Colorize.localized/Colorize.moef",
        src: nil
    )
    
    // MARK: - Tests
    
    /// Tests:
    /// - nested `spine`s
    /// - `media` resources containing a compound clip
    /// - `ref-clip` clips
    /// - mixed frame rates
    /// - that fraction time values that have subframes correctly convert to Timecode
    func testParse() throws {
        // load file
        
        let rawData = try fileContents
        
        // load
        
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // version
        
        XCTAssertEqual(fcpxml.version, .ver1_10)
        
        // resources
        
        let resources = fcpxml.resources()
        
        XCTAssertEqual(resources.count, 6)
        
        XCTAssertEqual(resources["r1"], .format(r1))
        
        XCTAssertEqual(resources["r2"], .asset(r2))
        
        XCTAssertEqual(resources["r3"], .format(r3))
        
        XCTAssertEqual(resources["r4"], .media(r4))
        
        XCTAssertEqual(resources["r5"], .effect(r5))
        
        XCTAssertEqual(resources["r6"], .effect(r6))
        
        // library
        
        let library = try XCTUnwrap(fcpxml.library())
        
        let libraryURL = URL(string: "file:///Users/user/Desktop/Marker_Interlaced.fcpbundle/")
        XCTAssertEqual(library.location, libraryURL)
        
        // events
        
        let events = fcpxml.allEvents()
        
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
        XCTAssertEqual(sequence.startTimecode, Self.tc("00:00:00:00", .fps29_97))
        XCTAssertEqual(sequence.startTimecode?.frameRate, .fps25)
        XCTAssertEqual(sequence.startTimecode?.subFramesBase, .max80SubFrames)
        XCTAssertEqual(sequence.duration, Self.tc("00:00:29:13", .fps25))
        XCTAssertEqual(sequence.audioLayout, .stereo)
        XCTAssertEqual(sequence.audioRate, .rate48kHz)
        
        // story elements (clips etc.)
        
        let spine = sequence.spine
        
        XCTAssertEqual(spine.elements.count, 7)
        
        guard case let .anyClip(.assetClip(element1)) = spine.elements[0] else { XCTFail("Clip was not expected type.") ; return }
        // TODO: contains a `conform-rate` child - do we need to do math based on its attributes?
        
        XCTAssertEqual(element1.ref, "r2")
        XCTAssertEqual(element1.offset, Self.tc("00:00:00:00", .fps29_97))
        XCTAssertEqual(element1.offset?.frameRate, .fps29_97)
        XCTAssertEqual(element1.name, "Clip 1")
        XCTAssertEqual(element1.start, nil)
        XCTAssertEqual(element1.duration, Self.tc("00:00:03:11.71", .fps29_97))
        XCTAssertEqual(element1.duration?.frameRate, .fps29_97)
        XCTAssertEqual( // compare to parent's frame rate
            try element1.duration?
                .converted(to: .fps25)
                .adding(.frames(0, subFrames: 1)), // for cumulative subframe aliasing
            Self.tc("00:00:03:10", .fps25) // confirmed in FCP
        )
        XCTAssertEqual(element1.audioRole, "dialogue")
        
        // markers
        
        let markers = element1.contents.annotations().markers()
        
        XCTAssertEqual(markers.count, 1)
        
        let expectedMarker0 = FinalCutPro.FCPXML.Marker(
            start: try Self.tc("00:00:01:11.56", .fps25) // confirmed in FCP
                .converted(to: .fps29_97)
                .adding(.frames(0, subFrames: 1)), // for cumulative subframe aliasing
            duration: Self.tc("00:00:00:01", .fps29_97),
            name: "Marker 2",
            metaData: .standard,
            note: nil
        )
        XCTAssertEqual(markers[safe: 0], expectedMarker0)
        
        #warning("> TODO: finish unit test to check ref-clip contents")
    }
    
    /// Check markers within `ref-clip`s.
    /// The clips within the `ref-clip` can contain markers but they don't show on the FCP timeline.
    func testExtractMarkers_IncludeMarkersWithinRefClips() throws {
        // load file
        let rawData = try fileContents
        
        // load
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // project
        let project = try XCTUnwrap(fcpxml.allProjects().first)
        
        let extractedMarkers = project
            .extractMarkers(settings: FinalCutPro.FCPXML.ExtractionSettings())
        
        let markers = try extractedMarkers
            .map { try Self.convert(absoluteStartOf: $0, to: .fps25) }
            .sortedByAbsoluteStart()
        
        XCTAssertEqual(markers.count, 18 + (2 * 3))
        
        print("Sorted by absolute timecode:")
        print(Self.debugString(for: markers))
        
        // print("Sorted by name:")
        // print(Self.debugString(for: markers.sortedByName()))
        
        // TODO: subframe rounding issues could be possibly eliminated if model used CMTime instead of Timecode for fractional time values, since the aggregate math involved between one or more Timecode instances could introduce very small amounts of cumulative subframes aliasing
        
        // Clip 1
        XCTAssertEqual(markers[0].name, "Marker 2")
        XCTAssertEqual(markers[0].context[.absoluteStart], Self.tc("00:00:01:11.56", .fps25))
        
        // Clip 2
        XCTAssertEqual(markers[1].name, "Marker 3")
        XCTAssertEqual(markers[1].context[.absoluteStart], Self.tc("00:00:04:05.68", .fps25))
        
        // Clip 2
        XCTAssertEqual(markers[2].name, "Marker 4")
        XCTAssertEqual(markers[2].context[.absoluteStart], Self.tc("00:00:05:20.71", .fps25))
        
        // Media Clip
        XCTAssertEqual(markers[3].name, "Marker 5")
        XCTAssertEqual(
            markers[3].context[.absoluteStart],
            Self.tc("00:00:06:23", .fps25) + Self.tc("00:00:01:12", .fps29_97)
        )
        
        // Media Clip
        XCTAssertEqual(markers[4].name, "Marker 6")
        XCTAssertEqual(
            markers[4].context[.absoluteStart],
            Self.tc("00:00:06:23", .fps25) + Self.tc("00:00:03:01", .fps29_97)
        )
        
        // Media Clip - technically out of bounds of the ref-clip
        XCTAssertEqual(markers[5].name, "Marker 7")
        XCTAssertEqual(
            markers[5].context[.absoluteStart],
            Self.tc("00:00:06:23", .fps25) + Self.tc("00:00:04:16", .fps29_97)
        )
        
        // Clip 4
        XCTAssertEqual(markers[6].name, "Marker 8")
        XCTAssertEqual(
            markers[6].context[.absoluteStart],
            try Self.tc("00:00:11:18.19", .fps25)
                .subtracting(.frames(0, subFrames: 1)) // for cumulative subframe aliasing
        )
        
        // Clip 4
        XCTAssertEqual(markers[7].name, "Marker 9")
        XCTAssertEqual(
            markers[7].context[.absoluteStart],
            try Self.tc("00:00:12:24.75", .fps25)
                .subtracting(.frames(0, subFrames: 2)) // for cumulative subframe aliasing
        )
        
        // Clip 5
        XCTAssertEqual(markers[8].name, "Marker 1")
        XCTAssertEqual(
            markers[8].context[.absoluteStart],
            try Self.tc("00:00:14:03.54", .fps25)
                .subtracting(.frames(0, subFrames: 1)) // for cumulative subframe aliasing
        )
        
        // Clip 5
        XCTAssertEqual(markers[9].name, "Marker 10")
        XCTAssertEqual(markers[9].context[.absoluteStart], Self.tc("00:00:14:07.67", .fps25))
        
        // Clip 5
        XCTAssertEqual(markers[10].name, "Marker 11")
        XCTAssertEqual(markers[10].context[.absoluteStart], Self.tc("00:00:14:13.54", .fps25))
        
        // Clip 5 - FCP shows 00:00:14:19.42
        XCTAssertEqual(markers[11].name, "Marker 12")
        XCTAssertEqual(
            markers[11].context[.absoluteStart],
            try Self.tc("00:00:14:19.42", .fps25)
                .subtracting(.frames(0, subFrames: 1)) // for cumulative subframe aliasing
        )
        
        // Clip 5.2
        XCTAssertEqual(markers[12].name, "Marker 14")
        XCTAssertEqual(
            markers[12].context[.absoluteStart],
            try Self.tc("00:00:14:23.53", .fps25)
                .subtracting(.frames(0, subFrames: 1)) // for cumulative subframe aliasing
        )
        
        // Clip 5.2
        XCTAssertEqual(markers[13].name, "Marker 15")
        XCTAssertEqual(
            markers[13].context[.absoluteStart],
            try Self.tc("00:00:15:02.00", .fps25)
                .subtracting(.frames(0, subFrames: 1)) // for cumulative subframe aliasing
        )
        
        // Clip 5
        XCTAssertEqual(markers[14].name, "Marker 16")
        XCTAssertEqual(markers[14].context[.absoluteStart], Self.tc("00:00:15:10.29", .fps25))
        
        // Clip 5.2
        XCTAssertEqual(markers[15].name, "Marker 17")
        XCTAssertEqual(
            markers[15].context[.absoluteStart],
            try Self.tc("00:00:15:14.27", .fps25)
                .subtracting(.frames(0, subFrames: 1)) // for cumulative subframe aliasing
        )
        
        // Clip 6
        XCTAssertEqual(markers[16].name, "Marker 18")
        XCTAssertEqual(markers[16].context[.absoluteStart], Self.tc("00:00:19:20.20", .fps25))
        
        // Clip 6
        XCTAssertEqual(markers[17].name, "Marker 19")
        XCTAssertEqual(markers[17].context[.absoluteStart], Self.tc("00:00:21:16.77", .fps25))
        
        // Clip 7
        XCTAssertEqual(markers[18].name, "Marker 20")
        XCTAssertEqual(markers[18].context[.absoluteStart], Self.tc("00:00:24:06.56", .fps25))
        
        // Media Clip - FCP shows 00:00:24:19.03 @ 25 fps
        XCTAssertEqual(markers[19].name, "Marker 5")
        XCTAssertEqual(
            markers[19].context[.absoluteStart],
            try (Self.tc("00:00:23:09", .fps25) + Self.tc("00:00:01:12", .fps29_97))
                .subtracting(.frames(0, subFrames: 1)) // for cumulative subframe aliasing
        )
        
        // Media Clip - FCP shows 00:00:26:09.90 @ 25 fps, technically out of bounds of the ref-clip
        XCTAssertEqual(markers[20].name, "Marker 6")
        XCTAssertEqual(
            markers[20].context[.absoluteStart],
            try Self.tc("00:00:23:09", .fps25) + Self.tc("00:00:03:01", .fps29_97)
                .subtracting(.frames(0, subFrames: 1)) // for cumulative subframe aliasing
        )
        
        // Clip 7
        XCTAssertEqual(markers[21].name, "Marker 21")
        XCTAssertEqual(
            markers[21].context[.absoluteStart],
            try Self.tc("00:00:26:24.22", .fps25)
                .subtracting(.frames(0, subFrames: 1)) // for cumulative subframe aliasing
        )
        
        // Media Clip - FCP shows 00:00:27:22.44 @ 25 fps, technically out of bounds of the ref-clip
        XCTAssertEqual(markers[22].name, "Marker 7")
        XCTAssertEqual(
            markers[22].context[.absoluteStart],
           try  Self.tc("00:00:23:09", .fps25) + Self.tc("00:00:04:16", .fps29_97)
                .subtracting(.frames(0, subFrames: 1)) // for cumulative subframe aliasing
        )
        
        // Clip 7
        XCTAssertEqual(markers[23].name, "Marker 22")
        XCTAssertEqual(markers[23].context[.absoluteStart], Self.tc("00:00:28:19.25", .fps25))
    }
    
    /// Check markers within `ref-clip`s.
    /// The clips within the `ref-clip` can contain markers but they don't show on the FCP timeline.
    func testExtractMarkers_ExcludeMarkersWithinRefClips() throws {
        // load file
        let rawData = try fileContents
        
        // load
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // project
        let project = try XCTUnwrap(fcpxml.allProjects().first)
        
        let settings = FinalCutPro.FCPXML.ExtractionSettings(
            excludeTypes: [.story(.anyClip(.refClip))], 
            auditionMask: .activeAudition
        )
        let markers = try project
            .extractMarkers(settings: settings)
            .map { try Self.convert(absoluteStartOf: $0, to: .fps25) }
            .sortedByAbsoluteStart()
        
        XCTAssertEqual(markers.count, 18)
        
        print("Sorted by absolute timecode:")
        print(Self.debugString(for: markers))
        
        // print("Sorted by name:")
        // print(Self.debugString(for: markers.sortedByName()))
    }
}

#endif
