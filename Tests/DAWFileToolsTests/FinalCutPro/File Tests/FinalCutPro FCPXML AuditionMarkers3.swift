//
//  FinalCutPro FCPXML AuditionMarkers3.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
@testable import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore

final class FinalCutPro_FCPXML_AuditionMarkers3: FCPXMLTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try XCTUnwrap(loadFileContents(
            forResource: "AuditionMarkers3",
            withExtension: "fcpxml",
            subFolder: .fcpxmlExports
        ))
    } }
    
    // MARK: Resources
    
    func testParse() throws {
        // load
        let rawData = try fileContents
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // version
        XCTAssertEqual(fcpxml.version, .ver1_11)
        
        // resources
        let resourcesDict = fcpxml.root.resourcesDict
        XCTAssertEqual(resourcesDict.count, 7)
        
        // library
        let library = try XCTUnwrap(fcpxml.root.library)
        let libraryURL = URL(string: "file:///Users/user/Movies/FCPXMLTest.fcpbundle/")
        XCTAssertEqual(library.location, libraryURL)
        
        // event
        let events = fcpxml.allEvents()
        XCTAssertEqual(events.count, 1)
        
        let event = try XCTUnwrap(events[safe: 0])
        XCTAssertEqual(event.name, "Test Event")
        
        // project
        let projects = event.projects.zeroIndexed
        XCTAssertEqual(projects.count, 1)
        
        let project = try XCTUnwrap(projects[safe: 0])
        XCTAssertEqual(project.name, "Test Project")
        XCTAssertEqual(project.startTimecode(), Self.tc("00:00:00:00", .fps23_976))
        
        // sequence
        let sequence = try XCTUnwrap(projects[safe: 0]).sequence
        XCTAssertEqual(sequence.format, "r1")
        XCTAssertEqual(sequence.tcStartAsTimecode(), Self.tc("00:00:00:00", .fps23_976))
        XCTAssertEqual(sequence.tcStartAsTimecode()?.frameRate, .fps23_976)
        XCTAssertEqual(sequence.tcStartAsTimecode()?.subFramesBase, .max80SubFrames)
        XCTAssertEqual(sequence.durationAsTimecode(), Self.tc("00:00:59:17", .fps23_976))
        XCTAssertEqual(sequence.audioLayout, .stereo)
        XCTAssertEqual(sequence.audioRate, .rate48kHz)
        
        // spine
        let spine = try XCTUnwrap(sequence.spine)
        
        let contents = spine.contents.zeroIndexed
        XCTAssertEqual(contents.count, 3)
        
        // story elements
        let audition = try XCTUnwrap(contents[safe: 2]?.fcpAsAudition)
        XCTAssertEqual(audition.lane, nil)
        XCTAssertEqual(audition.offsetAsTimecode(), Self.tc("00:00:31:16", .fps23_976))
        XCTAssertEqual(audition.offsetAsTimecode()?.frameRate, .fps23_976)
        
        let activeAudition = try XCTUnwrap(audition.activeClip)
        
        // markers
        let markers = activeAudition
            .children(whereFCPElement: .marker)
            .zeroIndexed
        XCTAssertEqual(markers.count, 3)
        
        let marker0 = try XCTUnwrap(markers[safe: 0])
        XCTAssertEqual(marker0.name, "Audition 1")
        XCTAssertEqual(marker0.configuration, .standard)
        XCTAssertEqual(
            marker0.startAsTimecode(frameRateSource: .mainTimeline), // local clip timeline is 25fps
            Self.tc("00:00:07:09", .fps23_976) // confirmed in FCP
        )
        XCTAssertEqual(
            marker0.durationAsTimecode(frameRateSource: .mainTimeline),
            Self.tc("00:00:00:01.03", .fps23_976) // 1 frame, scaled
        )
        XCTAssertEqual(marker0.note, nil)
        
        let marker1 = try XCTUnwrap(markers[safe: 1])
        XCTAssertEqual(marker1.name, "Audition 2")
        XCTAssertEqual(marker1.configuration, .standard)
        XCTAssertEqual(
            marker1.startAsTimecode(frameRateSource: .mainTimeline), // local clip timeline is 25fps
            Self.tc("00:00:14:08", .fps23_976) // confirmed in FCP
        )
        XCTAssertEqual(
            marker1.durationAsTimecode(frameRateSource: .mainTimeline),
            Self.tc("00:00:00:01.03", .fps23_976) // 1 frame, scaled
        )
        XCTAssertEqual(marker1.note, nil)
        
        let marker2 = try XCTUnwrap(markers[safe: 2])
        XCTAssertEqual(marker2.name, "Audition 3")
        XCTAssertEqual(marker2.configuration, .standard)
        XCTAssertEqual(
            marker2.startAsTimecode(frameRateSource: .mainTimeline), // local clip timeline is 25fps
            Self.tc("00:00:22:22", .fps23_976) // confirmed in FCP
        )
        XCTAssertEqual(
            marker2.durationAsTimecode(frameRateSource: .mainTimeline),
            Self.tc("00:00:00:01.03", .fps23_976) // 1 frame, scaled
        )
        XCTAssertEqual(marker2.note, nil)
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
        
        XCTAssertEqual(markers.count, 4)
        
        print("Markers sorted by absolute timecode:")
        print(Self.debugString(for: markers))
        
        // just test audition markers
        
        let marker0 = try XCTUnwrap(markers[safe: 1])
        XCTAssertEqual(marker0.name, "Audition 1") // just to identify marker
        XCTAssertEqual(marker0.timecode(), Self.tc("00:00:39:01", .fps23_976))
        
        let marker1 = try XCTUnwrap(markers[safe: 2])
        XCTAssertEqual(marker1.name, "Audition 2") // just to identify marker
        XCTAssertEqual(marker1.timecode(), Self.tc("00:00:46:00", .fps23_976))
        
        let marker2 = try XCTUnwrap(markers[safe: 3])
        XCTAssertEqual(marker2.name, "Audition 3") // just to identify marker
        XCTAssertEqual(marker2.timecode(), Self.tc("00:00:54:14", .fps23_976))
    }
    
    /// Test metadata that applies to marker(s).
    func testExtractMarkersMetadata_MainTimeline() async throws {
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
        
        let markers = extractedMarkers
        
        let expectedMarkerCount = 4
        XCTAssertEqual(markers.count, expectedMarkerCount)
        
        print("Markers sorted by absolute timecode:")
        print(Self.debugString(for: markers))
        
        // markers
        
        func md(
            in mdtm: [FinalCutPro.FCPXML.Metadata.Metadatum],
            key: FinalCutPro.FCPXML.Metadata.Key
        ) -> FinalCutPro.FCPXML.Metadata.Metadatum? {
            let matches = mdtm.filter { $0.key == key }
            XCTAssertLessThan(matches.count, 2)
            return matches.first
        }
        
        // skip testing marker 1, it's not on an audition clip
        
        // marker 2
        do {
            let marker = try XCTUnwrap(markers[safe: 1])
            let mtdm = marker.value(forContext: .metadata)
            XCTAssertEqual(mtdm.count, 11)
            
            XCTAssertEqual(marker.name, "Audition 1")
            
            // metadata from active audition clip
            XCTAssertEqual(md(in: mtdm, key: .reel)?.value, "TestVideo2 Reel")
            XCTAssertEqual(md(in: mtdm, key: .scene)?.value, "TestVideo2 Scene")
            XCTAssertEqual(md(in: mtdm, key: .take)?.value, "TestVideo2 Take")
            XCTAssertEqual(md(in: mtdm, key: .cameraAngle)?.value, "TestVideo2 Camera Angle")
            
            // metadata from active clip's resource
            XCTAssertEqual(md(in: mtdm, key: .rawToLogConversion)?.value, "0")
            XCTAssertEqual(md(in: mtdm, key: .colorProfile)?.value, "HD (1-1-1)")
            XCTAssertEqual(md(in: mtdm, key: .cameraISO)?.value, "0")
            XCTAssertEqual(md(in: mtdm, key: .cameraColorTemperature)?.value, "0")
            XCTAssertEqual(md(in: mtdm, key: .codecs)?.valueArray, ["'avc1'", "MPEG-4 AAC"])
            XCTAssertEqual(md(in: mtdm, key: .ingestDate)?.value, "2023-11-22 04:01:31 -0800")
            XCTAssertEqual(md(in: mtdm, key: .cameraName)?.value, "TestVideo2 Camera Name")
        }
    }
}

#endif
