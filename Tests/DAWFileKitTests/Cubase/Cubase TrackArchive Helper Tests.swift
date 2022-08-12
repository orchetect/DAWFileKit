//
//  Cubase TrackArchive Helper Tests.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
@testable import DAWFileKit
import OTCore
import TimecodeKit

class DAWFileKit_Cubase_Helper_Tests: XCTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    func testCollection_XMLNode_FilterAttribute() throws {
        // prep
        
        let nodes = [
            try XMLElement(xmlString: "<obj class='classA' name='name1'/>"),
            try XMLElement(xmlString: "<obj class='classA' name='name2'/>"),
            try XMLElement(xmlString: "<obj class='classB' name='name3'/>"),
            try XMLElement(xmlString: "<obj class='classB' name='name4'/>")
        ]
        
        // test
        
        var filtered = nodes.filter(nameAttribute: "name2")
        XCTAssertEqual(filtered[0], nodes[1])
        
        filtered = nodes.filter(classAttribute: "classA")
        XCTAssertEqual(filtered, [nodes[0], nodes[1]])
    }
}

#endif
