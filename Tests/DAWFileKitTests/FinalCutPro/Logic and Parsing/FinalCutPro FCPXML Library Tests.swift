//
//  FinalCutPro FCPXML Library Tests.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
@testable import DAWFileKit
import OTCore
import TimecodeKit

final class FinalCutPro_FCPXML_Library: FCPXMLTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    func testLocation() throws {
        let url = try XCTUnwrap(URL(string: "file:///Users/user/Movies/MyLibrary.fcpbundle/"))
        let library = FinalCutPro.FCPXML.Library(location: url)
        
        XCTAssertEqual(library.location, url)
    }
    
    func testName() throws {
        let url = try XCTUnwrap(URL(string: "file:///Users/user/Movies/MyLibrary.fcpbundle/"))
        let library = FinalCutPro.FCPXML.Library(location: url)
        
        XCTAssertEqual(library.name, "MyLibrary")
    }
}

#endif
