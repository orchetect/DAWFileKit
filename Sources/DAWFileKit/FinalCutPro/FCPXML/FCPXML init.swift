//
//  FCPXML init.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    /// Parse FCPXML/FCPXMLD file contents exported from Final Cut Pro.
    public init(fileContent data: Data) throws {
        let xmlDocument = try XMLDocument(data: data)
        self.init(fileContent: xmlDocument)
    }
    
    /// Initialize from FCPXML file that has been loaded into an `XMLDocument`.
    ///
    /// For fcpxml v1.10+ .fcpxmld bundles, load the .fcpxml file that is inside the bundle.
    public init(fileContent xml: XMLDocument) {
        self.xml = xml
    }
    
    // TODO: Add init for a new empty FCPXML file.
}

#endif
