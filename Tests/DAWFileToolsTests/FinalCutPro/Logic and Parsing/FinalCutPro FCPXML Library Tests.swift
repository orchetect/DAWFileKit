//
//  FinalCutPro FCPXML Library Tests.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
@testable import DAWFileTools
import SwiftExtensions
import TimecodeKitCore

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
