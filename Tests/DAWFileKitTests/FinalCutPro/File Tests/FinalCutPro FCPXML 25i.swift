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
    
    let projectFrameRate: TimecodeFrameRate = .fps25
    
    // MARK: Resources
    
    let r1 = FinalCutPro.FCPXML.Format(
        id: "r1",
        name: "FFVideoFormatDV720x576i50",
        frameDuration: Fraction(200, 5000),
        fieldOrder: "lower first",
        width: 720,
        height: 576,
        paspH: 59,
        paspV: 54,
        colorSpace: "5-1-6 (Rec. 601 (PAL))",
        projection: nil,
        stereoscopic: nil
    )
    
    let r2MediaRep = FinalCutPro.FCPXML.MediaRep(
        kind: .originalMedia,
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
    lazy var r2Metadata = FinalCutPro.FCPXML.Metadata(element: r2MetadataXML)
    lazy var r2 = FinalCutPro.FCPXML.Asset(
        id: "r2",
        name: "Test Video (29.97 fps)",
        start: .zero,
        duration: Fraction(101869, 1000),
        format: "r3",
        uid: "554B59605B289ECE8057E7FECBC3D3D0",
        hasAudio: true,
        hasVideo: true,
        audioSources: 1,
        audioChannels: 2,
        audioRate: .rate48kHz,
        videoSources: 1,
        auxVideoFlags: nil,
        mediaRep: r2MediaRep,
        metadata: r2Metadata
    )
    
    let r3 = FinalCutPro.FCPXML.Format(
        id: "r3",
        name: "FFVideoFormat1080p2997",
        frameDuration: Fraction(1001, 30000),
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
    lazy var r4Sequence = try! XCTUnwrap(FinalCutPro.FCPXML.Sequence(element: r4SequenceXML))
    lazy var r4 = FinalCutPro.FCPXML.Media(
        id: "r4",
        name: "29.97_CC",
        uid: "GYR/OKBAQ/2tErV+GGXCuA",
        modDate: "2022-09-10 23:08:42 -0700",
        sequence: r4Sequence
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
        // load
        let rawData = try fileContents
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // version
        XCTAssertEqual(fcpxml.version, .ver1_10)
        
        // resources
        let resourcesDict = fcpxml.root.resourcesDict
        XCTAssertEqual(resourcesDict.count, 6)
        XCTAssertEqual(try XCTUnwrap(resourcesDict["r1"]?.fcpAsFormat), r1)
        XCTAssertEqual(try XCTUnwrap(resourcesDict["r2"]?.fcpAsAsset), r2)
        XCTAssertEqual(try XCTUnwrap(resourcesDict["r3"]?.fcpAsFormat), r3)
        XCTAssertEqual(try XCTUnwrap(resourcesDict["r4"]?.fcpAsMedia), r4)
        XCTAssertEqual(try XCTUnwrap(resourcesDict["r5"]?.fcpAsEffect), r5)
        XCTAssertEqual(try XCTUnwrap(resourcesDict["r6"]?.fcpAsEffect), r6)
        
        // library
        let library = try XCTUnwrap(fcpxml.root.library)
        let libraryURL = URL(string: "file:///Users/user/Desktop/Marker_Interlaced.fcpbundle/")
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
        XCTAssertEqual(project.name, "25i_V1")
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
        XCTAssertEqual(sequence.durationAsTimecode(), Self.tc("00:00:29:13", projectFrameRate))
        XCTAssertEqual(sequence.audioLayout, .stereo)
        XCTAssertEqual(sequence.audioRate, .rate48kHz)
        
        // spine
        let spine = try XCTUnwrap(sequence.spine)
        
        let storyElements = spine.storyElements.zeroIndexed
        XCTAssertEqual(storyElements.count, 7)
        
        // story elements
        let element1 = try XCTUnwrap(storyElements[safe: 0]?.fcpAsAssetClip)
        XCTAssertEqual(element1.ref, "r2")
        XCTAssertEqual(element1.offsetAsTimecode(), Self.tc("00:00:00:00", .fps29_97))
        XCTAssertEqual(element1.offsetAsTimecode()?.frameRate, .fps29_97)
        XCTAssertEqual(element1.name, "Clip 1")
        XCTAssertEqual(element1.startAsTimecode(), nil)
        XCTAssertEqual(element1.durationAsTimecode(), Self.tc("00:00:03:11.71", .fps29_97))
        XCTAssertEqual(element1.durationAsTimecode()?.frameRate, .fps29_97)
        XCTAssertEqual( // compare to parent's frame rate
            element1.durationAsTimecode(frameRateSource: .rate(projectFrameRate)),
            Self.tc("00:00:03:10", projectFrameRate) // confirmed in FCP
        )
        XCTAssertEqual(element1.audioRole?.rawValue, "dialogue")
        
        // markers
        let markers = element1.element
            .children(whereFCPElement: .marker)
            .zeroIndexed
        XCTAssertEqual(markers.count, 1)
        
        let marker = try XCTUnwrap(markers[safe: 0])
        XCTAssertEqual(marker.name, "Marker 2")
        XCTAssertEqual(marker.configuration, .standard)
        XCTAssertEqual(
            marker.startAsTimecode(frameRateSource: .rate(projectFrameRate)), // (local timeline is 29.97)
            Self.tc("00:00:01:11.56", projectFrameRate) // confirmed in FCP
        )
        XCTAssertEqual(marker.durationAsTimecode(), Self.tc("00:00:00:01", .fps29_97))
        XCTAssertEqual(marker.note, nil)
    }
    
    /// Check markers within `ref-clip`s.
    /// The clips within the `ref-clip` can contain markers but they don't show on the FCP timeline.
    func testExtractMarkers_IncludeMarkersWithinRefClips() async throws {
        // load file
        let rawData = try fileContents
        
        // load
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // project
        let project = try XCTUnwrap(fcpxml.allProjects().first)
        
        let extractedMarkers = await project
            .extract(preset: .markers, scope: .deep())
            .zeroIndexed
        
        let markers = extractedMarkers.sortedByAbsoluteStartTimecode()
        
        XCTAssertEqual(markers.count, 18 + (2 * 3))
        
        print("Markers sorted by absolute timecode:")
        print(Self.debugString(for: markers))
        
        // check frame rate of Timecode from perspective of the main timeline
        XCTAssertTrue(markers.allSatisfy {
            $0.timecode(frameRateSource: .mainTimeline)?.frameRate == projectFrameRate
        })
        
        // Clip 1
        
        XCTAssertEqual(markers[safe: 0]?.name, "Marker 2")
        let marker2Timecode = try XCTUnwrap(markers[safe: 0]?.timecode())
        XCTAssertEqual(marker2Timecode, Self.tc("00:00:01:11.56", projectFrameRate))
        XCTAssertEqual(marker2Timecode.frameRate, projectFrameRate)
        
        // Clip 2
        XCTAssertEqual(markers[safe: 1]?.name, "Marker 3")
        let marker3Timecode = try XCTUnwrap(markers[safe: 1]?.timecode())
        XCTAssertEqual(marker3Timecode, Self.tc("00:00:04:05.68", projectFrameRate))
        XCTAssertEqual(marker3Timecode.frameRate, projectFrameRate)
        
        // Clip 2
        XCTAssertEqual(markers[safe: 2]?.name, "Marker 4")
        let marker4Timecode = try XCTUnwrap(markers[safe: 2]?.timecode())
        XCTAssertEqual(marker4Timecode, Self.tc("00:00:05:20.71", projectFrameRate))
        XCTAssertEqual(marker4Timecode.frameRate, projectFrameRate)
        
        // Media Clip
        XCTAssertEqual(markers[safe: 3]?.name, "Marker 5")
        let marker5Timecode = try XCTUnwrap(markers[safe: 3]?.timecode())
        XCTAssertEqual(
            marker5Timecode,
            Self.tc("00:00:06:23", projectFrameRate) + Self.tc("00:00:01:12", .fps29_97)
        )
        XCTAssertEqual(marker5Timecode.frameRate, projectFrameRate)
        
        // Media Clip
        XCTAssertEqual(markers[safe: 4]?.name, "Marker 6")
        let marker6Timecode = try XCTUnwrap(markers[safe: 4]?.timecode())
        XCTAssertEqual(
            marker6Timecode,
            Self.tc("00:00:06:23", projectFrameRate) + Self.tc("00:00:03:01", .fps29_97)
        )
        XCTAssertEqual(marker6Timecode.frameRate, projectFrameRate)
        
        // Media Clip - technically out of bounds of the ref-clip
        XCTAssertEqual(markers[safe: 5]?.name, "Marker 7")
        let marker7Timecode = try XCTUnwrap(markers[safe: 5]?.timecode())
        XCTAssertEqual(
            marker7Timecode,
            Self.tc("00:00:06:23", projectFrameRate) + Self.tc("00:00:04:16", .fps29_97)
        )
        XCTAssertEqual(marker7Timecode.frameRate, projectFrameRate)
        
        // Clip 4
        XCTAssertEqual(markers[safe: 6]?.name, "Marker 8")
        let marker8Timecode = try XCTUnwrap(markers[6].timecode())
        XCTAssertEqual(marker8Timecode, Self.tc("00:00:11:18.19", projectFrameRate))
        XCTAssertEqual(marker8Timecode.frameRate, projectFrameRate)
        
        // Clip 4
        XCTAssertEqual(markers[safe: 7]?.name, "Marker 9")
        let marker9Timecode = try XCTUnwrap(markers[7].timecode())
        XCTAssertEqual(marker9Timecode, Self.tc("00:00:12:24.75", projectFrameRate))
        XCTAssertEqual(marker9Timecode.frameRate, projectFrameRate)
        
        // Clip 5
        XCTAssertEqual(markers[safe: 8]?.name, "Marker 1")
        let marker1Timecode = try XCTUnwrap(markers[8].timecode())
        XCTAssertEqual(marker1Timecode, Self.tc("00:00:14:03.54", projectFrameRate))
        XCTAssertEqual(marker1Timecode.frameRate, projectFrameRate)
        
        // Clip 5
        XCTAssertEqual(markers[safe: 9]?.name, "Marker 10")
        let marker10Timecode = try XCTUnwrap(markers[9].timecode())
        XCTAssertEqual(marker10Timecode, Self.tc("00:00:14:07.67", projectFrameRate))
        XCTAssertEqual(marker10Timecode.frameRate, projectFrameRate)
        
        // Clip 5
        XCTAssertEqual(markers[safe: 10]?.name, "Marker 11")
        let marker11Timecode = try XCTUnwrap(markers[safe: 10]?.timecode())
        XCTAssertEqual(marker11Timecode, Self.tc("00:00:14:13.54", projectFrameRate))
        XCTAssertEqual(marker11Timecode.frameRate, projectFrameRate)
        
        // Clip 5 - FCP shows 00:00:14:19.42
        XCTAssertEqual(markers[safe: 11]?.name, "Marker 12")
        let marker12Timecode = try XCTUnwrap(markers[safe: 11]?.timecode())
        XCTAssertEqual(
            marker12Timecode,
            try Self.tc("00:00:14:19.42", projectFrameRate)
                .subtracting(.frames(0, subFrames: 1)) // TODO: subframe aliasing/rounding
        )
        XCTAssertEqual(marker12Timecode.frameRate, projectFrameRate)
        
        // Clip 5.2
        XCTAssertEqual(markers[safe: 12]?.name, "Marker 14")
        let marker14Timecode = try XCTUnwrap(markers[safe: 12]?.timecode())
        XCTAssertEqual(marker14Timecode, Self.tc("00:00:14:23.53", projectFrameRate))
        XCTAssertEqual(marker14Timecode.frameRate, projectFrameRate)
        
        // Clip 5.2
        XCTAssertEqual(markers[safe: 13]?.name, "Marker 15")
        let marker15Timecode = try XCTUnwrap(markers[safe: 13]?.timecode())
        XCTAssertEqual(marker15Timecode, Self.tc("00:00:15:02.00", projectFrameRate))
        XCTAssertEqual(marker15Timecode.frameRate, projectFrameRate)
        
        // Clip 5
        XCTAssertEqual(markers[safe: 14]?.name, "Marker 16")
        let marker16Timecode = try XCTUnwrap(markers[safe: 14]?.timecode())
        XCTAssertEqual(marker16Timecode, Self.tc("00:00:15:10.29", projectFrameRate))
        XCTAssertEqual(marker16Timecode.frameRate, projectFrameRate)
        
        // Clip 5.2
        XCTAssertEqual(markers[safe: 15]?.name, "Marker 17")
        let marker17Timecode = try XCTUnwrap(markers[safe: 15]?.timecode())
        XCTAssertEqual(marker17Timecode, Self.tc("00:00:15:14.27", projectFrameRate))
        XCTAssertEqual(marker17Timecode.frameRate, projectFrameRate)
        
        // Clip 6
        XCTAssertEqual(markers[safe: 16]?.name, "Marker 18")
        let marker18Timecode = try XCTUnwrap(markers[safe: 16]?.timecode())
        XCTAssertEqual(marker18Timecode, Self.tc("00:00:19:20.20", projectFrameRate))
        XCTAssertEqual(marker18Timecode.frameRate, projectFrameRate)
        
        // Clip 6
        XCTAssertEqual(markers[safe: 17]?.name, "Marker 19")
        let marker19Timecode = try XCTUnwrap(markers[safe: 17]?.timecode())
        XCTAssertEqual(marker19Timecode, Self.tc("00:00:21:16.77", projectFrameRate))
        XCTAssertEqual(marker19Timecode.frameRate, projectFrameRate)
        
        // Clip 7
        XCTAssertEqual(markers[safe: 18]?.name, "Marker 20")
        let marker20Timecode = try XCTUnwrap(markers[safe: 18]?.timecode())
        XCTAssertEqual(marker20Timecode, Self.tc("00:00:24:06.56", projectFrameRate))
        XCTAssertEqual(marker20Timecode.frameRate, projectFrameRate)
        
        // Media Clip - FCP shows 00:00:24:19.03 @ 25 fps
        XCTAssertEqual(markers[safe: 19]?.name, "Marker 5")
        let marker5BTimecode = try XCTUnwrap(markers[safe: 19]?.timecode())
        XCTAssertEqual(
            marker5BTimecode,
            Self.tc("00:00:23:09", projectFrameRate) + Self.tc("00:00:01:12", .fps29_97)
        )
        XCTAssertEqual(marker5BTimecode.frameRate, projectFrameRate)
        
        // Media Clip - FCP shows 00:00:26:09.90 @ 25 fps, technically out of bounds of the ref-clip
        XCTAssertEqual(markers[safe: 20]?.name, "Marker 6")
        let marker6BTimecode = try XCTUnwrap(markers[safe: 20]?.timecode())
        XCTAssertEqual(
            marker6BTimecode,
            Self.tc("00:00:23:09", projectFrameRate) + Self.tc("00:00:03:01", .fps29_97)
        )
        XCTAssertEqual(marker6BTimecode.frameRate, projectFrameRate)
        
        // Clip 7
        XCTAssertEqual(markers[safe: 21]?.name, "Marker 21")
        let marker21Timecode = try XCTUnwrap(markers[safe: 21]?.timecode())
        XCTAssertEqual(marker21Timecode, Self.tc("00:00:26:24.22", projectFrameRate))
        XCTAssertEqual(marker21Timecode.frameRate, projectFrameRate)
        
        // Media Clip - FCP shows 00:00:27:22.44 @ 25 fps, technically out of bounds of the ref-clip
        XCTAssertEqual(markers[safe: 22]?.name, "Marker 7")
        let marker7BTimecode = try XCTUnwrap(markers[safe: 22]?.timecode())
        XCTAssertEqual(
            marker7BTimecode,
            Self.tc("00:00:23:09", projectFrameRate) + Self.tc("00:00:04:16", .fps29_97)
        )
        XCTAssertEqual(marker7BTimecode.frameRate, projectFrameRate)
        
        // Clip 7
        XCTAssertEqual(markers[safe: 23]?.name, "Marker 22")
        let marker22Timecode = try XCTUnwrap(markers[safe: 23]?.timecode())
        XCTAssertEqual(marker22Timecode, Self.tc("00:00:28:19.25", projectFrameRate))
        XCTAssertEqual(marker22Timecode.frameRate, projectFrameRate)
    }
    
    func testExtractMarkers() async throws {
        // load file
        let rawData = try fileContents
        
        // load
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // project
        let project = try XCTUnwrap(fcpxml.allProjects().first)
        
        let markers = await project
            .extract(preset: .markers, scope: .mainTimeline)
            .sortedByAbsoluteStartTimecode()
        
        XCTAssertEqual(markers.count, 18)
        
        print("Markers sorted by absolute timecode:")
        print(Self.debugString(for: markers))
        
        // print("Sorted by name:")
        // print(Self.debugString(for: markers.sortedByName()))
    }
    
    /// Check markers within `ref-clip`s.
    /// The clips within the `ref-clip` can contain markers but they don't show on the FCP timeline.
    func testExtractMarkers_ExcludeMarkersWithinRefClips() async throws {
        // load file
        let rawData = try fileContents
        
        // load
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // project
        let project = try XCTUnwrap(fcpxml.allProjects().first)
        
        let scope = FinalCutPro.FCPXML.ExtractionScope(
            excludedTraversalTypes: [.refClip]
        )
        let markers = await project
            .extract(preset: .markers, scope: scope)
            .sortedByAbsoluteStartTimecode()
        
        XCTAssertEqual(markers.count, 18)
        
        print("Markers sorted by absolute timecode:")
        print(Self.debugString(for: markers))
        
        // print("Sorted by name:")
        // print(Self.debugString(for: markers.sortedByName()))
    }
}

#endif
