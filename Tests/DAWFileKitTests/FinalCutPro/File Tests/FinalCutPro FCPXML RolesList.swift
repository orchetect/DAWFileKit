//
//  FinalCutPro FCPXML RolesList.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import XCTest
@testable import DAWFileKit
import SwiftExtensions
import TimecodeKitCore

final class FinalCutPro_FCPXML_RolesList: FCPXMLTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try XCTUnwrap(loadFileContents(
            forResource: "RolesList",
            withExtension: "fcpxml",
            subFolder: .fcpxmlExports
        ))
    } }
    
    /// Project @ 24fps.
    let projectFrameRate: TimecodeFrameRate = .fps24
    
    func testParse() throws {
        // load
        let rawData = try fileContents
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // version
        XCTAssertEqual(fcpxml.version, .ver1_11)
        
        // skip testing file contents, we only care about roles extraction
    }
    
    func testExtractRoles() async throws {
        // load file
        let rawData = try fileContents
        
        // load
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // project
        let project = try XCTUnwrap(fcpxml.allProjects().first)
        
        let roles = await project.extract(
            preset: .roles(roleTypes: .allCases),
            scope: .deep(auditions: .active, mcClipAngles: .active)
        )
        
        // dump(roles)
        
        XCTAssertEqual(roles.count, 4)
        XCTAssertTrue(roles.contains(.video(raw: "Video")!))
        XCTAssertTrue(roles.contains(.video(raw: "FIXING.FIXING-1")!))
        XCTAssertTrue(roles.contains(.video(raw: "TO-DO.TO-DO-1")!))
        XCTAssertTrue(roles.contains(.video(raw: "VFX.VFX-1")!))
    }
}

#endif
