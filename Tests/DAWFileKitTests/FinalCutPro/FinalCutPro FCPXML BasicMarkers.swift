//
//  FinalCutPro FCPXML BasicMarkers.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

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
        
        // resources
        
        let resources = fcpxml.parseResources()
        
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
        
        let events = fcpxml.parseEvents(resources: resources)
        
        XCTAssertEqual(events.count, 1)
        
        // projects
        
        let projects = events[0].projects
        
        XCTAssertEqual(projects.count, 1)
        
        // sequences
        
        let sequences = projects[0].sequences
        
        XCTAssertEqual(sequences.count, 1)
        
        let sequence = sequences[0]
        
        // <sequence format="r1" duration="1920919/30000s" tcStart="0s" tcFormat="NDF" audioLayout="stereo" audioRate="48k">
        XCTAssertEqual(sequence.format, "r1")
        XCTAssertEqual(sequence.startTimecode, try TCC().toTimecode(at: ._29_97))
        XCTAssertEqual(sequence.startTimecode.frameRate, ._29_97)
        XCTAssertEqual(sequence.duration, try TCC(h: 00, m: 01, s: 03, f: 29).toTimecode(at: ._29_97))
        XCTAssertEqual(sequence.audioLayout, .stereo)
        XCTAssertEqual(sequence.audioRate, .rate48kHz)
        
        // clips
        
        #warning("> finish this test")
        
        // markers
        
        #warning("> finish this test")
    }
}
