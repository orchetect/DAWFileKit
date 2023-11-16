//
//  FinalCutPro FCPXML Format Info.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
@testable import DAWFileKit
import OTCore
import TimecodeKit

class FinalCutPro_FCPXML_FormatInfo: XCTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    /// Ensure `format` and `tcFormat` information can be found by traversing XML parents.
    func testFirstFormatAndTCFormat() throws {
        // load file
        
        let rawData = try XCTUnwrap(loadFileContents(
            forResource: "BasicMarkers",
            withExtension: "fcpxml",
            subFolder: .fcpxmlExports
        ))
        
        // load
        
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // resources
        
        let resources = fcpxml.resources()
        
        XCTAssertEqual(resources.count, 2)
        
        let r1 = FinalCutPro.FCPXML.Format(
            id: "r1",
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
        
        // make sure resource exists in parsed resources
        XCTAssert(resources.contains(r1))
        
        // format and tcFormat
        
        let xmlRoot = try XCTUnwrap(fcpxml.xmlRoot)
        
        // `fcpxml` element will never have `format` or `tcFormat` attributes
        do {
            let format = FinalCutPro.FCPXML.firstFormat(forElementOrAncestors: xmlRoot, in: resources)
            XCTAssertNil(format)
            
            let tcFormat = FinalCutPro.FCPXML.tcFormat(forElementOrAncestors: xmlRoot)
            XCTAssertNil(tcFormat)
        }
        
        let xmlLibrary = try XCTUnwrap(fcpxml.xmlLibrary)
        
        // `library` element will never have `format` or `tcFormat` attributes
        do {
            let format = FinalCutPro.FCPXML.firstFormat(forElementOrAncestors: xmlLibrary, in: resources)
            XCTAssertNil(format)
            
            let tcFormat = FinalCutPro.FCPXML.tcFormat(forElementOrAncestors: xmlLibrary)
            XCTAssertNil(tcFormat)
        }
        
        let xmlEvent = try XCTUnwrap(xmlLibrary.first(childNamed: "event"))
        
        // `event` element will never have `format` or `tcFormat` attributes
        do {
            let format = FinalCutPro.FCPXML.firstFormat(forElementOrAncestors: xmlEvent, in: resources)
            XCTAssertNil(format)
            
            let tcFormat = FinalCutPro.FCPXML.tcFormat(forElementOrAncestors: xmlEvent)
            XCTAssertNil(tcFormat)
        }
        
        let xmlProject = try XCTUnwrap(xmlEvent.first(childNamed: "project"))
        
        // `project` element will never have `format` or `tcFormat` attributes
        do {
            let format = FinalCutPro.FCPXML.firstFormat(forElementOrAncestors: xmlProject, in: resources)
            XCTAssertNil(format)
            
            let tcFormat = FinalCutPro.FCPXML.tcFormat(forElementOrAncestors: xmlProject)
            XCTAssertNil(tcFormat)
        }
        
        let xmlSequence = try XCTUnwrap(xmlProject.first(childNamed: "sequence"))
        
        // `sequence` element will usually have `format` and `tcFormat` attributes
        do {
            let format = try XCTUnwrap(FinalCutPro.FCPXML.firstFormat(forElementOrAncestors: xmlSequence, in: resources))
            XCTAssertEqual(format, r1)
            
            let tcFormat = try XCTUnwrap(FinalCutPro.FCPXML.tcFormat(forElementOrAncestors: xmlSequence))
            XCTAssertEqual(tcFormat, .nonDropFrame)
        }
        
        let xmlSpine = try XCTUnwrap(xmlSequence.first(childNamed: "spine"))
        
        // `spine` element will usually have `format` and `tcFormat` attributes in its immediate `sequence` parent
        do {
            let format = try XCTUnwrap(FinalCutPro.FCPXML.firstFormat(forElementOrAncestors: xmlSpine, in: resources))
            XCTAssertEqual(format, r1)
            
            let tcFormat = try XCTUnwrap(FinalCutPro.FCPXML.tcFormat(forElementOrAncestors: xmlSpine))
            XCTAssertEqual(tcFormat, .nonDropFrame)
        }
        
        let xmlTitle = try XCTUnwrap(xmlSpine.first(childNamed: "title"))
        
        // `title` element in this case inherits `format` and `tcFormat` attributes from its `sequence` ancestor
        do {
            let format = try XCTUnwrap(FinalCutPro.FCPXML.firstFormat(forElementOrAncestors: xmlTitle, in: resources))
            XCTAssertEqual(format, r1)
            
            let tcFormat = try XCTUnwrap(FinalCutPro.FCPXML.tcFormat(forElementOrAncestors: xmlTitle))
            XCTAssertEqual(tcFormat, .nonDropFrame)
        }
        
        let xmlMarker1 = try XCTUnwrap(xmlTitle.first(childNamed: "marker"))
        
        // `marker` element in this case inherits `format` and `tcFormat` attributes from its `sequence` ancestor
        do {
            let format = try XCTUnwrap(FinalCutPro.FCPXML.firstFormat(forElementOrAncestors: xmlMarker1, in: resources))
            XCTAssertEqual(format, r1)
            
            let tcFormat = try XCTUnwrap(FinalCutPro.FCPXML.tcFormat(forElementOrAncestors: xmlMarker1))
            XCTAssertEqual(tcFormat, .nonDropFrame)
        }
    }
}

#endif
