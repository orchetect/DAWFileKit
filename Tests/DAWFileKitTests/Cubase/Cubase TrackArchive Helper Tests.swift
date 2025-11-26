//
//  Cubase TrackArchive Helper Tests.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
@testable import DAWFileKit
import SwiftExtensions
import TimecodeKit

class Cubase_Helper_Tests: XCTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    func testCollection_XMLElement_FilterAttribute() throws {
        // prep
        
        let nodes = [
            try XMLElement(xmlString: "<obj class='classA' name='name1'/>"),
            try XMLElement(xmlString: "<obj class='classA' name='name2'/>"),
            try XMLElement(xmlString: "<obj class='classB' name='name3'/>"),
            try XMLElement(xmlString: "<obj class='classB' name='name4'/>")
        ]
        
        // test
        
        let filteredA = nodes.filter(whereNameAttributeValue: "name2").zeroIndexed
        XCTAssertEqual(filteredA[0], nodes[1])
        
        let filteredB = nodes.filter(whereClassAttributeValue: "classA").zeroIndexed
        XCTAssertEqual(filteredB[0], nodes[0])
        XCTAssertEqual(filteredB[1], nodes[1])
    }
    
    func testCollection_XMLElement_FirstAttribute() throws {
        // prep
        
        let nodes = [
            try XMLElement(xmlString: "<obj class='classA' name='name1'/>"),
            try XMLElement(xmlString: "<obj class='classA' name='name2'/>"),
            try XMLElement(xmlString: "<obj class='classB' name='name3'/>"),
            try XMLElement(xmlString: "<obj class='classB' name='name4'/>")
        ]
        
        // test
        
        let firstA = nodes.first(whereNameAttributeValue: "name2")
        XCTAssertEqual(firstA, nodes[1])
        
        let firstB = nodes.first(whereClassAttributeValue: "classA")
        XCTAssertEqual(firstB, nodes[0])
    }
}

#endif
