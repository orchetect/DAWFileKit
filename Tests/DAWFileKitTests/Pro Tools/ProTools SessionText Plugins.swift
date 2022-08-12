//
//  ProTools SessionText Plugins.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//

import XCTest
@testable import DAWFileKit
import OTCore
import TimecodeKit

class DAWFileKit_ProTools_SessionText_Plugins: XCTestCase {
    override func setUp() { }
    override func tearDown() { }
    
    func testSessionText_Plugins() throws {
        // load file
        
        let filename = "SessionText_Plugins_23-976fps_DefaultExportOptions_PT2020.3"
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
        
        // plug-ins
        
        let plugins = sessionInfo.plugins
        
        XCTAssertEqual(plugins?.count, 15)
        
        XCTAssertEqual(plugins?[0].manufacturer, "AIR Music Technology")
        XCTAssertEqual(plugins?[0].name,         "AIR Kill EQ")
        
        XCTAssertEqual(plugins?[1].manufacturer, "AIR Music Technology")
        XCTAssertEqual(plugins?[1].name,         "AIR Non-Linear Reverb")
        
        XCTAssertEqual(plugins?[2].manufacturer, "Avid")
        XCTAssertEqual(plugins?[2].name,         "Dither")
        
        XCTAssertEqual(plugins?[3].manufacturer, "Blue Cat Audio")
        XCTAssertEqual(plugins?[3].name,         "BCPatchWorkSynth")
        
        XCTAssertEqual(plugins?[4].manufacturer, "FabFilter")
        XCTAssertEqual(plugins?[4].name,         "FabFilter Saturn")
        
        XCTAssertEqual(plugins?[5].manufacturer, "FabFilter")
        XCTAssertEqual(plugins?[5].name,         "FabFilter Timeless 2")
        
        XCTAssertEqual(plugins?[6].manufacturer, "Native Instruments")
        XCTAssertEqual(plugins?[6].name,         "Kontakt")
        
        XCTAssertEqual(plugins?[7].manufacturer, "Plogue Art et Technologie, Inc")
        XCTAssertEqual(plugins?[7].name,         "chipsounds")
        
        XCTAssertEqual(plugins?[8].manufacturer, "Plugin Alliance")
        XCTAssertEqual(plugins?[8].name,         "Schoeps Mono Upmix 1to2")
        
        XCTAssertEqual(plugins?[9].manufacturer, "Plugin Alliance")
        XCTAssertEqual(plugins?[9].name,         "Unfiltered Audio Byome")
        
        XCTAssertEqual(plugins?[10].manufacturer, "Plugin Alliance")
        XCTAssertEqual(plugins?[10].name,         "Vertigo VSM-3")
        
        XCTAssertEqual(plugins?[11].manufacturer, "Plugin Alliance")
        XCTAssertEqual(plugins?[11].name,         "bx_boom")
        
        XCTAssertEqual(plugins?[12].manufacturer, "Plugin Alliance")
        XCTAssertEqual(plugins?[12].name,         "bx_rooMS")
        
        XCTAssertEqual(plugins?[13].manufacturer, "accusonus")
        XCTAssertEqual(plugins?[13].name,         "ERA 4 Voice Leveler")
        
        XCTAssertEqual(plugins?[14].manufacturer, "oeksound")
        XCTAssertEqual(plugins?[14].name,         "soothe2")
    }
}
