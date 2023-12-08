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
        
        // root
        let fcpxmlElement = try XCTUnwrap(fcpxml.fcpxmlElement)
        XCTAssertEqual(fcpxmlElement.fcpStart, nil)
        
        // library
        let library = try XCTUnwrap(fcpxmlElement.firstChildElement(named: "library"))
        XCTAssertEqual(library.fcpStart, nil)
        
        // event
        let event = try XCTUnwrap(library.firstChildElement(named: "event"))
        XCTAssertEqual(event.fcpStart, nil)
        
        // project
        let project = try XCTUnwrap(event.firstChildElement(named: "project"))
        XCTAssertEqual(project.fcpStart, nil)
        
        // sequence
        let sequence = try XCTUnwrap(project.firstChildElement(named: "sequence"))
        XCTAssertEqual(sequence.fcpStart, nil)
        
        // spine
        let spine = try XCTUnwrap(sequence.firstChildElement(named: "spine"))
        XCTAssertEqual(spine.fcpStart, nil)
        
        // title
        let title = try XCTUnwrap(spine.firstChildElement(named: "title"))
        XCTAssertEqual(title.fcpStart, Fraction(1441440000, 2400000))
        XCTAssertEqual(
            title.fcpAsTitle?.startAsTimecode,
            Self.tc("00:10:00:00", .fps29_97)
        )
        
        // marker
        let marker = try XCTUnwrap(title.firstChildElement(named: "marker"))
        XCTAssertEqual(marker.fcpStart, Fraction(27248221, 7500))
        XCTAssertEqual(
            marker.fcpAsMarker?.startAsTimecode,
            Self.tc("01:00:29:14", .fps29_97)
        )
    }
    
    func testNearestStart() throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // root
        let fcpxmlElement = try XCTUnwrap(fcpxml.fcpxmlElement)
        XCTAssertEqual(fcpxmlElement._fcpNearestStart(includingSelf: true), nil)
        
        // library
        let library = try XCTUnwrap(fcpxmlElement.firstChildElement(named: "library"))
        XCTAssertEqual(library._fcpNearestStart(includingSelf: true), nil)
        
        // event
        let event = try XCTUnwrap(library.firstChildElement(named: "event"))
        XCTAssertEqual(event._fcpNearestStart(includingSelf: true), nil)
        
        // project
        let project = try XCTUnwrap(event.firstChildElement(named: "project"))
        XCTAssertEqual(project._fcpNearestStart(includingSelf: true), nil)
        
        // sequence
        let sequence = try XCTUnwrap(project.firstChildElement(named: "sequence"))
        XCTAssertEqual(sequence._fcpNearestStart(includingSelf: true), nil)
        
        // spine
        let spine = try XCTUnwrap(sequence.firstChildElement(named: "spine"))
        XCTAssertEqual(spine._fcpNearestStart(includingSelf: true), nil)
        
        // title
        let title = try XCTUnwrap(spine.firstChildElement(named: "title"))
        XCTAssertEqual(
            title._fcpNearestStart(includingSelf: true),
            Fraction(1441440000, 2400000)
        )
        
        // marker
        let marker = try XCTUnwrap(title.firstChildElement(named: "marker"))
        XCTAssertEqual(
            marker._fcpNearestStart(includingSelf: true),
            Fraction(27248221, 7500)
        )
    }
    
    func testTCStart() throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // root
        let fcpxmlElement = try XCTUnwrap(fcpxml.fcpxmlElement)
        XCTAssertEqual(fcpxmlElement.fcpTCStart, nil)
        
        // library
        let library = try XCTUnwrap(fcpxmlElement.firstChildElement(named: "library"))
        XCTAssertEqual(library.fcpTCStart, nil)
        
        // event
        let event = try XCTUnwrap(library.firstChildElement(named: "event"))
        XCTAssertEqual(event.fcpTCStart, nil)
        
        // project
        let project = try XCTUnwrap(event.firstChildElement(named: "project"))
        XCTAssertEqual(project.fcpTCStart, nil)
        
        // sequence
        let sequence = try XCTUnwrap(project.firstChildElement(named: "sequence"))
        XCTAssertEqual(sequence.fcpTCStart, Fraction(8648640000, 2400000))
        XCTAssertEqual(
            sequence.fcpAsSequence?.tcStartAsTimecode,
            Self.tc("01:00:00:00", .fps29_97)
        )
        
        // spine
        let spine = try XCTUnwrap(sequence.firstChildElement(named: "spine"))
        XCTAssertEqual(spine.fcpTCStart, nil)
        
        // title
        let title = try XCTUnwrap(spine.firstChildElement(named: "title"))
        XCTAssertEqual(title.fcpTCStart, nil)
        
        // marker
        let marker = try XCTUnwrap(title.firstChildElement(named: "marker"))
        XCTAssertEqual(marker.fcpTCStart, nil)
    }
    
    func testNearestTCStart() throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // root
        let fcpxmlElement = try XCTUnwrap(fcpxml.fcpxmlElement)
        XCTAssertEqual(fcpxmlElement._fcpNearestTCStart(includingSelf: true), nil)
        
        // library
        let library = try XCTUnwrap(fcpxmlElement.firstChildElement(named: "library"))
        XCTAssertEqual(library._fcpNearestTCStart(includingSelf: true), nil)
        
        // event
        let event = try XCTUnwrap(library.firstChildElement(named: "event"))
        XCTAssertEqual(event._fcpNearestTCStart(includingSelf: true), nil)
        
        // project
        let project = try XCTUnwrap(event.firstChildElement(named: "project"))
        XCTAssertEqual(project._fcpNearestTCStart(includingSelf: true), nil)
        
        // sequence
        let sequence = try XCTUnwrap(project.firstChildElement(named: "sequence"))
        XCTAssertEqual(
            sequence._fcpNearestTCStart(includingSelf: true),
            Fraction(8648640000, 2400000)
        )
        
        // spine
        let spine = try XCTUnwrap(sequence.firstChildElement(named: "spine"))
        XCTAssertEqual(
            spine._fcpNearestTCStart(includingSelf: true),
            Fraction(8648640000, 2400000)
        )
        
        // title
        let title = try XCTUnwrap(spine.firstChildElement(named: "title"))
        XCTAssertEqual(
            title._fcpNearestTCStart(includingSelf: true),
            Fraction(8648640000, 2400000)
        )
        
        // marker
        let marker = try XCTUnwrap(title.firstChildElement(named: "marker"))
        XCTAssertEqual(
            marker._fcpNearestTCStart(includingSelf: true),
            Fraction(8648640000, 2400000)
        )
    }
}

#endif
