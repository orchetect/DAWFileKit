//
//  FCPXML Library.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import CoreMedia
@_implementationOnly import OTCore

extension FinalCutPro.FCPXML {
    /// Represents a library location on disk.
    public struct Library {
        public let location: URL
        
        public init(location: URL) {
            self.location = location
        }
    }
}

extension FinalCutPro.FCPXML.Library {
    /// Attributes unique to ``Library``.
    public enum Attributes: String {
        case location
    }
    
    /// Extract library element (if present) from the passed root-level `fcpxml` element.
    init?(fcpxmlXMLLeaf xmlLeaf: XMLElement) {
        guard let xmlLibrary = xmlLeaf
            .elements(forName: FinalCutPro.FCPXML.FoundationElementType.library.rawValue)
            .first
        else { return nil }
        
        let locationString = xmlLibrary.attributeStringValue(
            forName: Attributes.location.rawValue
        ) ?? ""
        
        guard let locationURL = URL(string: locationString) else {
            print("Invalid fcpxml library URL: \(locationString.quoted)")
            return nil
        }
        location = locationURL
    }
}

extension FinalCutPro.FCPXML.Library: FCPXMLStructureElement {
    public var structureElementType: FinalCutPro.FCPXML.StructureElementType {
        .library
    }
}

extension FinalCutPro.FCPXML.Library {
    /// Returns the library name.
    public var name: String {
        // will be a file URL that is URL encoded
        let libName = location
            .deletingPathExtension()
            .lastPathComponent
        
        // decode URL encoding
        let libNameDecoded = libName.removingPercentEncoding ?? libName
        
        return libNameDecoded
    }
}

#endif
