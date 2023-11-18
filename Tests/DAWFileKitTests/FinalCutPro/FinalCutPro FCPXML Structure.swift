//
//  FinalCutPro FCPXML Structure.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
/* @testable */ import DAWFileKit
import OTCore
import TimecodeKit

class FinalCutPro_FCPXML_Structure: XCTestCase {
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
        
        // TODO: test sequences? not sure if they can show up in more than one location in the hierarchy.
    }
}

#endif
