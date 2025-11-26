//
//  FinalCutPro FCPXML Structure.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
/* @testable */ import DAWFileTools
import SwiftExtensions
import TimecodeKitCore

final class FinalCutPro_FCPXML_Structure: FCPXMLTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    /// Ensure that elements that can appear in various locations in the XML hierarchy are all found.
    func testParse() throws {
        // load file
        
        let rawData = try XCTUnwrap(loadFileContents(
            forResource: "Structure",
            withExtension: "fcpxml",
            subFolder: .fcpxmlExports
        ))
        
        // load
        
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // events
        
        let events = Set(fcpxml.allEvents().map(\.name))
        XCTAssertEqual(events, ["Test Event", "Test Event 2"])
                
        // projects
        
        let projects = Set(fcpxml.allProjects().map(\.name))
        XCTAssertEqual(projects, ["Test Project", "Test Project 2", "Test Project 3"])
        
        // TODO: it may be possible for story elements (sequence, clips, etc.) to be in the root `fcpxml` element
        // the docs say that they can be there as browser elements
        // test parsing them? might need a new method to get them specifically like `FinalCutPro.FCPXML.parseStoryElementsInRoot()`
    }
}

#endif
