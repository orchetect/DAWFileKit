//
//  FinalCutPro FCPXML MulticamMarkers.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
@testable import DAWFileKit
import OTCore
import TimecodeKit

final class FinalCutPro_FCPXML_MulticamMarkers: FCPXMLTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try XCTUnwrap(loadFileContents(
            forResource: "MulticamMarkers",
            withExtension: "fcpxml",
            subFolder: .fcpxmlExports
        ))
    } }
    
    func testParse() async throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // resources
        // let resources = fcpxml.resources()
        
        // events
        let events = fcpxml.allEvents()
        XCTAssertEqual(events.count, 1)
        
        let event = try XCTUnwrap(events[safe: 0])
        XCTAssertEqual(event.name, "Test Event")
        XCTAssertEqual(event.element._fcpEffectiveOcclusion(), .notOccluded)
        
        // projects
        let projects = event.projects
        XCTAssertEqual(projects.count, 1)
        
        let project = try XCTUnwrap(projects[safe: 0])
        XCTAssertEqual(project.element._fcpEffectiveOcclusion(), .notOccluded)
        
        // sequence
        let sequence = try XCTUnwrap(project.sequence)
        XCTAssertEqual(sequence.element._fcpEffectiveOcclusion(), .notOccluded)
        
        // spine
        let spine = try XCTUnwrap(sequence.spine)
        
        let storyElements = spine.storyElements.zeroIndexed
        XCTAssertEqual(storyElements.count, 2)
        
        // mc-clip 1
        
        let mcClip1 = try XCTUnwrap(storyElements[safe: 0]?.fcpAsMCClip)
        XCTAssertEqual(mcClip1.ref, "r2")
        XCTAssertEqual(mcClip1.lane, nil)
        XCTAssertEqual(mcClip1.offsetAsTimecode(), Self.tc("01:00:00:00", .fps23_976))
        XCTAssertEqual(mcClip1.offsetAsTimecode()?.frameRate, .fps23_976)
        XCTAssertEqual(mcClip1.name, "MC")
        XCTAssertEqual(mcClip1.startAsTimecode(), Self.tc("00:00:10:01", .fps23_976))
        XCTAssertEqual(mcClip1.durationAsTimecode(), Self.tc("00:00:40:00", .fps23_976))
        XCTAssertEqual(mcClip1.durationAsTimecode()?.frameRate, .fps23_976)
        XCTAssertEqual(mcClip1.enabled, true)
        let extractedMCClip1 = await mcClip1.element.fcpExtract()
        XCTAssertEqual(
            extractedMCClip1.value(forContext: .absoluteStartAsTimecode()),
            Self.tc("01:00:00:00", .fps23_976)
        )
        XCTAssertEqual(extractedMCClip1.value(forContext: .occlusion), .notOccluded)
        XCTAssertEqual(extractedMCClip1.value(forContext: .effectiveOcclusion), .notOccluded)
        XCTAssertEqual(extractedMCClip1.value(forContext: .localRoles), [
            FinalCutPro.FCPXML.defaultVideoRole,
            FinalCutPro.FCPXML.defaultAudioRole.lowercased(derivedOnly: true)
        ])
        XCTAssertEqual(extractedMCClip1.value(forContext: .inheritedRoles), [
            .defaulted(FinalCutPro.FCPXML.defaultVideoRole),
            .inherited(FinalCutPro.FCPXML.defaultAudioRole.lowercased(derivedOnly: true))
        ])
        
        // mc-clip 1 multicam media (same media used for mc-clip 2)
        
        let mc = try XCTUnwrap(mcClip1.multicamResource)
        
        XCTAssertEqual(mc.format, "r1")
        XCTAssertEqual(mc.tcStartAsTimecode(), Self.tc("00:00:00:00", .fps23_976))
        XCTAssertEqual(mc.angles.count, 5)
        
        // multicam media angles
        
        let mcAngle1 = try XCTUnwrap(mc.angles[safe: 0])
        XCTAssertEqual(mcAngle1.name, "A")
        XCTAssertEqual(mcAngle1.angleID, "+L5xmXXnRXOGdjFq1Eo7EQ")
        XCTAssertEqual(mcAngle1.contents.count, 2)
        
        let mcAngle2 = try XCTUnwrap(mc.angles[safe: 1])
        XCTAssertEqual(mcAngle2.name, "B")
        XCTAssertEqual(mcAngle2.angleID, "FCw5EnkUQcOHu8fwK2TiQQ")
        XCTAssertEqual(mcAngle2.contents.count, 2)
        
        let mcAngle3 = try XCTUnwrap(mc.angles[safe: 2])
        XCTAssertEqual(mcAngle3.name, "C")
        XCTAssertEqual(mcAngle3.angleID, "LphqqelgRX6/pXqi35MoGA")
        XCTAssertEqual(mcAngle3.contents.count, 2)
        
        let mcAngle4 = try XCTUnwrap(mc.angles[safe: 3])
        XCTAssertEqual(mcAngle4.name, "D")
        XCTAssertEqual(mcAngle4.angleID, "gA31yYbYRRSetqQyxAwC8g")
        XCTAssertEqual(mcAngle4.contents.count, 2)
        
        let mcAngle5 = try XCTUnwrap(mc.angles[safe: 4])
        XCTAssertEqual(mcAngle5.name, "Music Angle")
        XCTAssertEqual(mcAngle5.angleID, "9jilYFZRQZ+GI27X4ckxpQ")
        XCTAssertEqual(mcAngle5.contents.count, 1)
        
        // mc-clip 1 marker on main timeline
        
        let mc1Markers = mcClip1.storyElements
            .filter(whereFCPElement: .marker)
            .zeroIndexed
        XCTAssertEqual(mc1Markers.count, 1)
        
        let mc1Marker = try XCTUnwrap(mc1Markers[safe: 0])
        XCTAssertEqual(mc1Marker.name, "Marker on Multicam Clip 1")
        let extractedMC1Marker = await mc1Marker.element.fcpExtract()
        XCTAssertEqual(
            extractedMC1Marker.value(forContext: .absoluteStartAsTimecode()),
            Self.tc("01:00:01:09", .fps23_976)
        )
        XCTAssertEqual(extractedMC1Marker.value(forContext: .occlusion), .notOccluded) // within mc-clip 1
        XCTAssertEqual(extractedMC1Marker.value(forContext: .effectiveOcclusion), .notOccluded) // main timeline
        XCTAssertEqual(extractedMC1Marker.value(forContext: .localRoles), []) // markers never contain roles
        XCTAssertEqual(extractedMC1Marker.value(forContext: .inheritedRoles), [
            .defaulted(FinalCutPro.FCPXML.defaultVideoRole),
            .inherited(FinalCutPro.FCPXML.defaultAudioRole.lowercased(derivedOnly: true))
        ])
        
        // mc-clip 2
        
        let mcClip2 = try XCTUnwrap(storyElements[safe: 1]?.fcpAsMCClip)
        XCTAssertEqual(mcClip2.ref, "r2")
        XCTAssertEqual(mcClip2.lane, nil)
        XCTAssertEqual(mcClip2.offsetAsTimecode(), Self.tc("01:00:40:00", .fps23_976))
        XCTAssertEqual(mcClip2.offsetAsTimecode()?.frameRate, .fps23_976)
        XCTAssertEqual(mcClip2.name, "MC")
        XCTAssertEqual(mcClip2.startAsTimecode(), Self.tc("00:00:13:01", .fps23_976))
        XCTAssertEqual(mcClip2.durationAsTimecode(), Self.tc("00:00:10:00", .fps23_976))
        XCTAssertEqual(mcClip2.durationAsTimecode()?.frameRate, .fps23_976)
        XCTAssertEqual(mcClip2.enabled, true)
        let extractedMCClip2 = await mcClip2.element.fcpExtract()
        XCTAssertEqual(
            extractedMCClip2.value(forContext: .absoluteStartAsTimecode()),
            Self.tc("01:00:40:00", .fps23_976)
        )
        XCTAssertEqual(extractedMCClip2.value(forContext: .occlusion), .notOccluded)
        XCTAssertEqual(extractedMCClip2.value(forContext: .effectiveOcclusion), .notOccluded)
        XCTAssertEqual(extractedMCClip2.value(forContext: .localRoles), [
            FinalCutPro.FCPXML.defaultVideoRole,
            FinalCutPro.FCPXML.defaultAudioRole.lowercased(derivedOnly: true)
        ])
        XCTAssertEqual(extractedMCClip2.value(forContext: .inheritedRoles), [
            .defaulted(FinalCutPro.FCPXML.defaultVideoRole),
            .inherited(FinalCutPro.FCPXML.defaultAudioRole.lowercased(derivedOnly: true))
        ])
        
        // mc-clip 2 marker on main timeline
        
        let mc2Markers = mcClip2.storyElements
            .filter(whereFCPElement: .marker)
            .zeroIndexed
        XCTAssertEqual(mc2Markers.count, 1)
        
        let mc2Marker = try XCTUnwrap(mc2Markers[safe: 0])
        XCTAssertEqual(mc2Marker.name, "Marker on Multicam Clip 2")
        let extractedMC2Marker = await mc2Marker.element.fcpExtract()
        XCTAssertEqual(
            extractedMC2Marker.value(forContext: .absoluteStartAsTimecode()),
            Self.tc("01:00:44:08", .fps23_976)
        )
        XCTAssertEqual(extractedMC2Marker.value(forContext: .occlusion), .notOccluded) // within mc-clip 2
        XCTAssertEqual(extractedMC2Marker.value(forContext: .effectiveOcclusion), .notOccluded) // main timeline
        XCTAssertEqual(extractedMC2Marker.value(forContext: .localRoles), []) // markers never contain roles
        XCTAssertEqual(extractedMC2Marker.value(forContext: .inheritedRoles), [
            .defaulted(FinalCutPro.FCPXML.defaultVideoRole),
            .inherited(FinalCutPro.FCPXML.defaultAudioRole.lowercased(derivedOnly: true))
        ])
    }
    
    /// Test main timeline markers extraction with limited occlusion conditions.
    func testExtractMarkers_MainTimeline_LimitedOcclusions() async throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try XCTUnwrap(fcpxml.allEvents().first)
        
        // extract markers
        let extractedMarkers = await event.extract(preset: .markers, scope: .mainTimeline)
        XCTAssertEqual(extractedMarkers.count, 2)
        
        XCTAssertEqual(
            extractedMarkers.map(\.name),
            ["Marker on Multicam Clip 1", "Marker on Multicam Clip 2"]
        )
    }
    
    /// Test main timeline markers extraction with all occlusion conditions and active MC angles.
    func testExtractMarkers_MainTimeline_AllOcclusions_ActiveAngles() async throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try XCTUnwrap(fcpxml.allEvents().first)
        
        // extract markers
        var scope = FinalCutPro.FCPXML.ExtractionScope.mainTimeline
        scope.mcClipAngles = .active
        scope.occlusions = .allCases
        let extractedMarkers = await event.extract(preset: .markers, scope: scope)
        XCTAssertEqual(extractedMarkers.count, 2)
        
        XCTAssertEqual(
            extractedMarkers.map(\.name),
            ["Marker on Multicam Clip 1", "Marker on Multicam Clip 2"]
        )
    }
    
    /// Test main timeline markers extraction with all occlusion conditions and all MC angles.
    /// NOTE: The auditions rule and the mcClipAngles rule have slightly different effects
    /// since audition clips are peer elements, but mc-clip angles are nested elements.
    /// This means that applying the `mainTimeline` extraction scope prevents any angles
    /// from being extracted.
    func testExtractMarkers_MainTimeline_AllOcclusions_AllAngles() async throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try XCTUnwrap(fcpxml.allEvents().first)
        
        // extract markers
        var scope = FinalCutPro.FCPXML.ExtractionScope.mainTimeline
        scope.mcClipAngles = .all
        scope.occlusions = .allCases
        let extractedMarkers = await event.extract(preset: .markers, scope: scope)
        XCTAssertEqual(extractedMarkers.count, 2)
        
        XCTAssertEqual(
            extractedMarkers.map(\.name),
            ["Marker on Multicam Clip 1", "Marker on Multicam Clip 2"]
        )
    }
    
    /// Test deep markers extraction with all occlusion conditions with active MC angles.
    func testExtractMarkers_Deep_AllOcclusions_ActiveAngles() async throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try XCTUnwrap(fcpxml.allEvents().first)
        
        // extract markers
        let extractedMarkers = await event.extract(
            preset: .markers,
            scope: .deep(mcClipAngles: .active)
        )
        // 1 on each mc-clip, and 5 within each mc-clip
        XCTAssertEqual(extractedMarkers.count, 4)
        
        // note these are not sorted chronologically; they're in parsing order
        XCTAssertEqual(extractedMarkers.map(\.name), [
            "Marker on Multicam Clip 1", // on mc-clip 1
            "Marker in Multicam Clip on Angle D", // within mc-clip 1
            "Marker on Multicam Clip 2", // on mc-clip 2
            "Marker in Multicam Clip on Angle B", // within mc-clip 2
        ])
    }
    
    /// Test deep markers extraction with all occlusion conditions and all MC angles.
    func testExtractMarkers_Deep_AllOcclusions_AllAngles() async throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try XCTUnwrap(fcpxml.allEvents().first)
        
        // extract markers
        let extractedMarkers = await event.extract(
            preset: .markers,
            scope: .deep(mcClipAngles: .all)
        )
        XCTAssertEqual(extractedMarkers.count, 2 + (2 * 5))
        
        XCTAssertEqual(
            extractedMarkers.map(\.name),
            [
                "Marker on Multicam Clip 1", // on mc-clip 1
                "Marker in Multicam Clip on Angle A", // within mc-clip 1
                "Marker in Multicam Clip on Angle B", // within mc-clip 1
                "Marker in Multicam Clip on Angle C", // within mc-clip 1
                "Marker in Multicam Clip on Angle D", // within mc-clip 1
                "Marker in Multicam Clip on Music Angle", // within mc-clip 1
                "Marker on Multicam Clip 2", // on mc-clip 2
                "Marker in Multicam Clip on Angle A", // within mc-clip 2
                "Marker in Multicam Clip on Angle B", // within mc-clip 2
                "Marker in Multicam Clip on Angle C", // within mc-clip 2
                "Marker in Multicam Clip on Angle D", // within mc-clip 2
                "Marker in Multicam Clip on Music Angle" // within mc-clip 2
            ]
        )
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
        
        let expectedMarkerCount = 2
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
        
        // marker 1
        do {
            let marker = try XCTUnwrap(markers[safe: 0])
            let mtdm = marker.value(forContext: .metadata)
            XCTAssertEqual(mtdm.count, 9)
            
            // metadata from media
            XCTAssertEqual(md(in: mtdm, key: .cameraName)?.value, "Cam 4 Camera Name")
            XCTAssertEqual(md(in: mtdm, key: .rawToLogConversion)?.value, "0")
            XCTAssertEqual(md(in: mtdm, key: .colorProfile)?.value, nil)
            XCTAssertEqual(md(in: mtdm, key: .cameraISO)?.value, "0")
            XCTAssertEqual(md(in: mtdm, key: .cameraColorTemperature)?.value, "0")
            XCTAssertEqual(md(in: mtdm, key: .codecs)?.valueArray, nil)
            XCTAssertEqual(md(in: mtdm, key: .ingestDate)?.value, "2022-09-13 17:57:24 -0700")
            // metadata from clip
            XCTAssertEqual(md(in: mtdm, key: .reel)?.value, "Cam 4 Reel")
            XCTAssertEqual(md(in: mtdm, key: .scene)?.value, "Cam 4 Scene")
            XCTAssertEqual(md(in: mtdm, key: .take)?.value, "Cam 4 Take")
            XCTAssertEqual(md(in: mtdm, key: .cameraAngle)?.value, "D")
        }
        
        // marker 2
        do {
            let marker = try XCTUnwrap(markers[safe: 1])
            let mtdm = marker.value(forContext: .metadata)
            XCTAssertEqual(mtdm.count, 9)
            
            // metadata from media
            XCTAssertEqual(md(in: mtdm, key: .cameraName)?.value, "Cam 2 Camera Name")
            XCTAssertEqual(md(in: mtdm, key: .rawToLogConversion)?.value, "0")
            XCTAssertEqual(md(in: mtdm, key: .colorProfile)?.value, nil)
            XCTAssertEqual(md(in: mtdm, key: .cameraISO)?.value, "0")
            XCTAssertEqual(md(in: mtdm, key: .cameraColorTemperature)?.value, "0")
            XCTAssertEqual(md(in: mtdm, key: .codecs)?.valueArray, nil)
            XCTAssertEqual(md(in: mtdm, key: .ingestDate)?.value, "2022-09-13 17:57:22 -0700")
            // metadata from clip
            XCTAssertEqual(md(in: mtdm, key: .reel)?.value, "Cam 2 Reel")
            XCTAssertEqual(md(in: mtdm, key: .scene)?.value, "Cam 2 Scene")
            XCTAssertEqual(md(in: mtdm, key: .take)?.value, "Cam 2 Take")
            XCTAssertEqual(md(in: mtdm, key: .cameraAngle)?.value, "B")
        }
    }
}

#endif
