//
//  FinalCutPro FCPXML Calculations.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
@testable import DAWFileKit
import OTCore
import TimecodeKit

final class FinalCutPro_FCPXML_Calculations: FCPXMLTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try XCTUnwrap(loadFileContents(
            forResource: "BasicMarkers_1HourProjectStart",
            withExtension: "fcpxml",
            subFolder: .fcpxmlExports
        ))
    } }
    
    func testStart() throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        let resources = fcpxml.resources()
        
        // root
        let xmlRoot = try XCTUnwrap(fcpxml.xmlRoot)
        XCTAssertEqual(FinalCutPro.FCPXML.start(of: xmlRoot, resources: resources), nil)
        
        // library
        let library = try XCTUnwrap(xmlRoot.first(childNamed: "library"))
        XCTAssertEqual(FinalCutPro.FCPXML.start(of: library, resources: resources), nil)
        
        // event
        let event = try XCTUnwrap(library.first(childNamed: "event"))
        XCTAssertEqual(FinalCutPro.FCPXML.start(of: event, resources: resources), nil)
        
        // project
        let project = try XCTUnwrap(event.first(childNamed: "project"))
        XCTAssertEqual(FinalCutPro.FCPXML.start(of: project, resources: resources), nil)
        
        // sequence
        let sequence = try XCTUnwrap(project.first(childNamed: "sequence"))
        XCTAssertEqual(FinalCutPro.FCPXML.start(of: sequence, resources: resources), nil)
        
        // spine
        let spine = try XCTUnwrap(sequence.first(childNamed: "spine"))
        XCTAssertEqual(FinalCutPro.FCPXML.start(of: spine, resources: resources), nil)
        
        // title
        let title = try XCTUnwrap(spine.first(childNamed: "title"))
        XCTAssertEqual(
            FinalCutPro.FCPXML.start(of: title, resources: resources),
            try Timecode(.components(m: 10), at: .fps29_97, base: .max80SubFrames)
        )
        
        // marker
        let marker = try XCTUnwrap(title.first(childNamed: "marker"))
        XCTAssertEqual(
            FinalCutPro.FCPXML.start(of: marker, resources: resources),
            try Timecode(.components(h: 01, m: 00, s: 29, f: 14), at: .fps29_97, base: .max80SubFrames)
        )
    }
    
    func testNearestStart() throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        let resources = fcpxml.resources()
        
        // root
        let xmlRoot = try XCTUnwrap(fcpxml.xmlRoot)
        XCTAssertEqual(FinalCutPro.FCPXML.nearestStart(of: xmlRoot, resources: resources), nil)
        
        // library
        let library = try XCTUnwrap(xmlRoot.first(childNamed: "library"))
        XCTAssertEqual(FinalCutPro.FCPXML.nearestStart(of: library, resources: resources), nil)
        
        // event
        let event = try XCTUnwrap(library.first(childNamed: "event"))
        XCTAssertEqual(FinalCutPro.FCPXML.nearestStart(of: event, resources: resources), nil)
        
        // project
        let project = try XCTUnwrap(event.first(childNamed: "project"))
        XCTAssertEqual(FinalCutPro.FCPXML.nearestStart(of: project, resources: resources), nil)
        
        // sequence
        let sequence = try XCTUnwrap(project.first(childNamed: "sequence"))
        XCTAssertEqual(FinalCutPro.FCPXML.nearestStart(of: sequence, resources: resources), nil)
        
        // spine
        let spine = try XCTUnwrap(sequence.first(childNamed: "spine"))
        XCTAssertEqual(FinalCutPro.FCPXML.nearestStart(of: spine, resources: resources), nil)
        
        // title
        let title = try XCTUnwrap(spine.first(childNamed: "title"))
        XCTAssertEqual(
            FinalCutPro.FCPXML.nearestStart(of: title, resources: resources),
            try Timecode(.components(m: 10), at: .fps29_97, base: .max80SubFrames)
        )
        
        // marker
        let marker = try XCTUnwrap(title.first(childNamed: "marker"))
        XCTAssertEqual(
            FinalCutPro.FCPXML.nearestStart(of: marker, resources: resources),
            try Timecode(.components(h: 01, m: 00, s: 29, f: 14), at: .fps29_97, base: .max80SubFrames)
        )
    }
    
    func testTCStart() throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        let resources = fcpxml.resources()
        
        // root
        let xmlRoot = try XCTUnwrap(fcpxml.xmlRoot)
        XCTAssertEqual(FinalCutPro.FCPXML.tcStart(of: xmlRoot, resources: resources), nil)
        
        // library
        let library = try XCTUnwrap(xmlRoot.first(childNamed: "library"))
        XCTAssertEqual(FinalCutPro.FCPXML.tcStart(of: library, resources: resources), nil)
        
        // event
        let event = try XCTUnwrap(library.first(childNamed: "event"))
        XCTAssertEqual(FinalCutPro.FCPXML.tcStart(of: event, resources: resources), nil)
        
        // project
        let project = try XCTUnwrap(event.first(childNamed: "project"))
        XCTAssertEqual(FinalCutPro.FCPXML.tcStart(of: project, resources: resources), nil)
        
        // sequence
        let sequence = try XCTUnwrap(project.first(childNamed: "sequence"))
        XCTAssertEqual(
            FinalCutPro.FCPXML.tcStart(of: sequence, resources: resources),
            try Timecode(.components(h: 01, m: 00, s: 00, f: 00), at: .fps29_97, base: .max80SubFrames)
        )
        
        // spine
        let spine = try XCTUnwrap(sequence.first(childNamed: "spine"))
        XCTAssertEqual(FinalCutPro.FCPXML.tcStart(of: spine, resources: resources), nil)
        
        // title
        let title = try XCTUnwrap(spine.first(childNamed: "title"))
        XCTAssertEqual(FinalCutPro.FCPXML.tcStart(of: title, resources: resources), nil)
        
        // marker
        let marker = try XCTUnwrap(title.first(childNamed: "marker"))
        XCTAssertEqual(FinalCutPro.FCPXML.tcStart(of: marker, resources: resources), nil)
    }
    
    func testNearestTCStart() throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        let resources = fcpxml.resources()
        
        // root
        let xmlRoot = try XCTUnwrap(fcpxml.xmlRoot)
        XCTAssertEqual(FinalCutPro.FCPXML.nearestTCStart(of: xmlRoot, resources: resources), nil)
        
        // library
        let library = try XCTUnwrap(xmlRoot.first(childNamed: "library"))
        XCTAssertEqual(FinalCutPro.FCPXML.nearestTCStart(of: library, resources: resources), nil)
        
        // event
        let event = try XCTUnwrap(library.first(childNamed: "event"))
        XCTAssertEqual(FinalCutPro.FCPXML.nearestTCStart(of: event, resources: resources), nil)
        
        // project
        let project = try XCTUnwrap(event.first(childNamed: "project"))
        XCTAssertEqual(FinalCutPro.FCPXML.nearestTCStart(of: project, resources: resources), nil)
        
        // sequence
        let sequence = try XCTUnwrap(project.first(childNamed: "sequence"))
        XCTAssertEqual(
            FinalCutPro.FCPXML.nearestTCStart(of: sequence, resources: resources),
            try Timecode(.components(h: 01, m: 00, s: 00, f: 00), at: .fps29_97, base: .max80SubFrames)
        )
        
        // spine
        let spine = try XCTUnwrap(sequence.first(childNamed: "spine"))
        XCTAssertEqual(
            FinalCutPro.FCPXML.nearestTCStart(of: spine, resources: resources),
            try Timecode(.components(h: 01, m: 00, s: 00, f: 00), at: .fps29_97, base: .max80SubFrames)
        )
        
        // title
        let title = try XCTUnwrap(spine.first(childNamed: "title"))
        XCTAssertEqual(
            FinalCutPro.FCPXML.nearestTCStart(of: title, resources: resources),
            try Timecode(.components(h: 01, m: 00, s: 00, f: 00), at: .fps29_97, base: .max80SubFrames)
        )
        
        // marker
        let marker = try XCTUnwrap(title.first(childNamed: "marker"))
        XCTAssertEqual(
            FinalCutPro.FCPXML.nearestTCStart(of: marker, resources: resources),
            try Timecode(.components(h: 01, m: 00, s: 00, f: 00), at: .fps29_97, base: .max80SubFrames)
        )
    }
}

#endif
