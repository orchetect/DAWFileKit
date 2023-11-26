//
//  DAWFileKitTests Constants.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import XCTest

// MARK: - Constants

enum ResourcesFolder: String {
    case cubaseTrackArchiveXML = "Cubase TrackArchive XML Exports"
    case ptSessionTextExports = "PT Session Text Exports"
    case fcpxmlExports = "FCPXML Exports"
}

// MARK: - Utilities

func loadFileContents(
    forResource: String,
    withExtension: String,
    subFolder: ResourcesFolder?
) -> Data? {
    guard let url = Bundle.module.url(
        forResource: forResource,
        withExtension: withExtension,
        subdirectory: subFolder?.rawValue
    )
    else {
        XCTFail("Could not form URL, possibly could not find file.")
        return nil
    }
    
    guard let data = try? Data(contentsOf: url)
    else { XCTFail("Could not read file at URL \(url.absoluteString.quoted)."); return nil }
    
    return data
}
