//
//  FCPXML Library.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
@_implementationOnly import OTCore

extension FinalCutPro.FCPXML {
    /// Represents a library location on disk.
    public enum Library { }
}

extension FinalCutPro.FCPXML.Library {
    public var structureElementType: FinalCutPro.FCPXML.StructureElementType {
        .library
    }
    
    public enum Attributes: String, XMLParsableAttributesKey {
        case location
    }
}

extension XMLElement { // Library
    /// Returns the library name.
    public var libraryName: String? {
        guard let libraryLocation = libraryLocation else { return nil }
        
        // will be a file URL that is URL encoded
        let libName = libraryLocation
            .deletingPathExtension()
            .lastPathComponent
        
        // decode URL encoding
        let libNameDecoded = libName.removingPercentEncoding ?? libName
        
        return libNameDecoded
    }
    
    /// Returns the library location URL.
    public var libraryLocation: URL? {
        guard let location = stringValue(
            forAttributeNamed: FinalCutPro.FCPXML.Library.Attributes.location.rawValue
        ) else { return nil }
        return URL(string: location)
    }
}

#endif
