//
//  ProTools SessionText OrphanData.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import XCTest
@testable import DAWFileKit
import OTCore
import TimecodeKit

class ProTools_SessionText_OrphanData: XCTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    func testSessionText_OrphanData() throws {
        // load file
        
        let filename = "SessionText_UnrecognizedSection_23-976fps_DefaultExportOptions_PT2020.3"
        guard let rawData = loadFileContents(
            forResource: filename,
            withExtension: "txt",
            subFolder: .ptSessionTextExports
        )
        else { XCTFail("Could not form URL, possibly could not find file."); return }
        
        // parse
        
        var parseMessages: [ProTools.SessionInfo.ParseMessage] = []
        let sessionInfo = try ProTools.SessionInfo(data: rawData, messages: &parseMessages)
        
        // parse messages
        
        XCTAssertEqual(parseMessages.errors.count, 0)
        if !parseMessages.errors.isEmpty {
            dump(parseMessages.errors)
        }
        
        // orphan data
        // just test for orphan sections (unrecognized - a hypothetical in case new sections get
        // added to Pro Tools in the future)
        
        XCTAssertEqual(sessionInfo.orphanData?.count, 1)
        
        XCTAssertEqual(
            sessionInfo.orphanData?.first?.heading,
            "U N R E C O G N I Z E D  S E C T I O N"
        )
        XCTAssertEqual(sessionInfo.orphanData?.first?.content, [])
    }
}
