//
//  FinalCutPro FCPXML Format Info.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
import Foundation
@testable import DAWFileKit
import SwiftExtensions
import TimecodeKitCore

final class FinalCutPro_FCPXML_FormatInfo: FCPXMLTestCase {
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
        
        let resources = fcpxml.root.resources
        
        XCTAssertEqual(resources.childElements.count, 2)
        
        let r1 = try XCTUnwrap(resources.childElements[safe: 0]?.fcpAsFormat)
        XCTAssertEqual(r1.id, "r1")
        XCTAssertEqual(r1.name, "FFVideoFormat1080p2997")
        XCTAssertEqual(r1.frameDuration, Fraction(1001,30000))
        XCTAssertEqual(r1.fieldOrder, nil)
        XCTAssertEqual(r1.width, 1920)
        XCTAssertEqual(r1.height, 1080)
        XCTAssertEqual(r1.paspH, nil)
        XCTAssertEqual(r1.paspV, nil)
        XCTAssertEqual(r1.colorSpace, "1-1-1 (Rec. 709)")
        XCTAssertEqual(r1.projection, nil)
        XCTAssertEqual(r1.stereoscopic, nil)
        
        // format and tcFormat
        
        let xmlRoot = fcpxml.root.element
        
        // `fcpxml` element will never have `format` or `tcFormat` attributes
        do {
            let format = xmlRoot._fcpFirstFormatResourceForElementOrAncestors()
            XCTAssertNil(format)
            
            let tcFormat = xmlRoot._fcpTCFormatForElementOrAncestors()
            XCTAssertNil(tcFormat)
        }
        
        let libraryElement = try XCTUnwrap(xmlRoot.firstChildElement(named: "library"))
        
        // `library` element will never have `format` or `tcFormat` attributes
        do {
            let format = libraryElement._fcpFirstFormatResourceForElementOrAncestors()
            XCTAssertNil(format)
            
            let tcFormat = libraryElement._fcpTCFormatForElementOrAncestors()
            XCTAssertNil(tcFormat)
        }
        
        let xmlEvent = try XCTUnwrap(libraryElement.firstChildElement(named: "event"))
        
        // `event` element will never have `format` or `tcFormat` attributes
        do {
            let format = xmlEvent._fcpFirstFormatResourceForElementOrAncestors()
            XCTAssertNil(format)
            
            let tcFormat = xmlEvent._fcpTCFormatForElementOrAncestors()
            XCTAssertNil(tcFormat)
        }
        
        let xmlProject = try XCTUnwrap(xmlEvent.firstChildElement(named: "project"))
        
        // `project` element will never have `format` or `tcFormat` attributes
        do {
            let format = xmlProject._fcpFirstFormatResourceForElementOrAncestors()
            XCTAssertNil(format)
            
            let tcFormat = xmlProject._fcpTCFormatForElementOrAncestors()
            XCTAssertNil(tcFormat)
        }
        
        let xmlSequence = try XCTUnwrap(xmlProject.firstChildElement(named: "sequence"))
        
        // `sequence` element will usually have `format` and `tcFormat` attributes
        do {
            let format = try XCTUnwrap(xmlSequence._fcpFirstFormatResourceForElementOrAncestors())
            XCTAssert(format == r1)
            
            let tcFormat = try XCTUnwrap(xmlSequence._fcpTCFormatForElementOrAncestors())
            XCTAssertEqual(tcFormat, .nonDropFrame)
        }
        
        let xmlSpine = try XCTUnwrap(xmlSequence.firstChildElement(named: "spine"))
        
        // `spine` element will usually have `format` and `tcFormat` attributes in its immediate `sequence` parent
        do {
            let format = try XCTUnwrap(xmlSpine._fcpFirstFormatResourceForElementOrAncestors())
            XCTAssert(format == r1)
            
            let tcFormat = try XCTUnwrap(xmlSpine._fcpTCFormatForElementOrAncestors())
            XCTAssertEqual(tcFormat, .nonDropFrame)
        }
        
        let xmlTitle = try XCTUnwrap(xmlSpine.firstChildElement(named: "title"))
        
        // `title` element in this case inherits `format` and `tcFormat` attributes from its `sequence` ancestor
        do {
            let format = try XCTUnwrap(xmlTitle._fcpFirstFormatResourceForElementOrAncestors())
            XCTAssert(format == r1)
            
            let tcFormat = try XCTUnwrap(xmlTitle._fcpTCFormatForElementOrAncestors())
            XCTAssertEqual(tcFormat, .nonDropFrame)
        }
        
        let xmlMarker1 = try XCTUnwrap(xmlTitle.firstChildElement(named: "marker"))
        
        // `marker` element in this case inherits `format` and `tcFormat` attributes from its `sequence` ancestor
        do {
            let format = try XCTUnwrap(xmlMarker1._fcpFirstFormatResourceForElementOrAncestors())
            XCTAssert(format == r1)
            
            let tcFormat = try XCTUnwrap(xmlMarker1._fcpTCFormatForElementOrAncestors())
            XCTAssertEqual(tcFormat, .nonDropFrame)
        }
    }
}

#endif
