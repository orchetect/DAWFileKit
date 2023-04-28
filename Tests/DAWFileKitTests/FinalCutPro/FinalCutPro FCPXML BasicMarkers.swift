//
//  FinalCutPro FCPXML BasicMarkers.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
@testable import DAWFileKit
import OTCore
import TimecodeKit

class FinalCutPro_FCPXML_BasicMarkers: XCTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    func testFCPXML_BasicMarkers() throws {
        // load file
        
        let filename = "BasicMarkers"
        guard let rawData = loadFileContents(
            forResource: filename,
            withExtension: "fcpxml",
            subFolder: .fcpxmlExports
        )
        else { XCTFail("Could not form URL, possibly could not find file."); return }
        
        // load
        
        let fcpxml = try FinalCutPro.FCPXML(
            fileContent: rawData
        )
        
        // version
        
        XCTAssertEqual(fcpxml.version, .ver1_9)
        
        // resources
        
        let resources = fcpxml.resources()
        
        XCTAssertEqual(resources.count, 2)
        
        // <format id="r1" name="FFVideoFormat1080p2997" frameDuration="1001/30000s" width="1920" height="1080" colorSpace="1-1-1 (Rec. 709)"/>
        let r1 = FinalCutPro.FCPXML.Resource.Format(
            name: "FFVideoFormat1080p2997",
            frameDuration: "1001/30000s",
            fieldOrder: nil,
            width: 1920,
            height: 1080,
            colorSpace: "1-1-1 (Rec. 709)"
        )
        XCTAssertEqual(resources["r1"], .format(r1))
        
        // <effect id="r2" name="Basic Title" uid=".../Titles.localized/Bumper:Opener.localized/Basic Title.localized/Basic Title.moti"/>
        let r2 = FinalCutPro.FCPXML.Resource.Effect(
            name: "Basic Title",
            uid: ".../Titles.localized/Bumper:Opener.localized/Basic Title.localized/Basic Title.moti"
        )
        XCTAssertEqual(resources["r2"], .effect(r2))
        
        // events
        
        let events = fcpxml.events()
        
        XCTAssertEqual(events.count, 1)
        
        // projects
        
        let projects = events[0].projects
        
        XCTAssertEqual(projects.count, 1)
        
        let project = projects[0]
        XCTAssertEqual(project.startTimecode, try Timecode(Fraction(0, 1), at: ._29_97, base: ._80SubFrames))
        
        // sequences
        
        let sequences = projects[0].sequences
        
        XCTAssertEqual(sequences.count, 1)
        
        let sequence = sequences[0]
        
        // <sequence format="r1" duration="1920919/30000s" tcStart="0s" tcFormat="NDF" audioLayout="stereo" audioRate="48k">
        XCTAssertEqual(sequence.format, "r1")
        XCTAssertEqual(sequence.startTimecode, try TCC().toTimecode(at: ._29_97, base: ._80SubFrames))
        XCTAssertEqual(sequence.startTimecode.frameRate, ._29_97)
        XCTAssertEqual(sequence.startTimecode.subFramesBase, ._80SubFrames)
        XCTAssertEqual(sequence.duration, try TCC(h: 00, m: 01, s: 03, f: 29).toTimecode(at: ._29_97, base: ._80SubFrames))
        XCTAssertEqual(sequence.audioLayout, .stereo)
        XCTAssertEqual(sequence.audioRate, .rate48kHz)
        
        // clips
        
        let clips = sequence.clips
        
        XCTAssertEqual(clips.count, 1)
        
        guard case let .title(clip) = clips[0] else { XCTFail("Clip was not expected type.") ; return }
        
        // <title ref="r2" offset="0s" name="Basic Title" start="108108000/30000s" duration="1920919/30000s">
        XCTAssertEqual(clip.ref, "r2")
        XCTAssertEqual(clip.offset, try TCC().toTimecode(at: ._29_97, base: ._80SubFrames))
        XCTAssertEqual(clip.offset.frameRate, ._29_97)
        XCTAssertEqual(clip.name, "Basic Title")
        XCTAssertEqual(clip.start, try TCC(h: 1).toTimecode(at: ._29_97, base: ._80SubFrames))
        XCTAssertEqual(clip.start.frameRate, ._29_97)
        XCTAssertEqual(clip.duration, try TCC(h: 00, m: 01, s: 03, f: 29).toTimecode(at: ._29_97, base: ._80SubFrames))
        XCTAssertEqual(clip.duration.frameRate, ._29_97)
        
        // markers
        
        let markers = clip.markers
        
        XCTAssertEqual(markers.count, 4)
        
        // <marker start="27248221/7500s" duration="1001/30000s" value="Standard Marker" note="some notes here"/>
        let expectedMarker0 = FinalCutPro.FCPXML.Marker(
            name: "Standard Marker",
            start: try TCC(h: 01, m: 00, s: 29, f: 14).toTimecode(at: ._29_97, base: ._80SubFrames),
            duration: try TCC(f: 1).toTimecode(at: ._29_97, base: ._80SubFrames),
            note: "some notes here",
            metaData: .standard
        )
        XCTAssertEqual(markers[0], expectedMarker0)
        
        // <marker start="7266259/2000s" duration="1001/30000s" value="To Do Marker, Incomplete" completed="0" note="more notes here"/>
        let expectedMarker1 = FinalCutPro.FCPXML.Marker(
            name: "To Do Marker, Incomplete",
            start: try TCC(h: 01, m: 00, s: 29, f: 15).toTimecode(at: ._29_97, base: ._80SubFrames),
            duration: try TCC(f: 1).toTimecode(at: ._29_97, base: ._80SubFrames),
            note: "more notes here",
            metaData: .toDo(completed: false)
        )
        XCTAssertEqual(markers[1], expectedMarker1)
        
        // <marker start="54497443/15000s" duration="1001/30000s" value="To Do Marker, Completed" completed="1" note="notes yay"/>
        let expectedMarker2 = FinalCutPro.FCPXML.Marker(
            name: "To Do Marker, Completed",
            start: try TCC(h: 01, m: 00, s: 29, f: 16).toTimecode(at: ._29_97, base: ._80SubFrames),
            duration: try TCC(f: 1).toTimecode(at: ._29_97, base: ._80SubFrames),
            note: "notes yay",
            metaData: .toDo(completed: true)
        )
        XCTAssertEqual(markers[2], expectedMarker2)
        
        // <chapter-marker start="108995887/30000s" duration="1001/30000s" value="Chapter Marker" posterOffset="11/30s"/>
        let expectedMarker3 = FinalCutPro.FCPXML.Marker(
            name: "Chapter Marker",
            start: try TCC(h: 01, m: 00, s: 29, f: 17).toTimecode(at: ._29_97, base: ._80SubFrames),
            duration: try TCC(f: 1).toTimecode(at: ._29_97),
            note: "",
            metaData: .chapter(posterOffset: .init(try TCC(f: 10, sf: 79).toTimecode(at: ._29_97, base: ._80SubFrames)))
        )
        XCTAssertEqual(markers[3], expectedMarker3)
    }
}

#endif
