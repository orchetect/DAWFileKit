//
//  FCPXML Library.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import OTCore

extension FinalCutPro.FCPXML {
    /// Represents a library location on disk.
    public struct Library: Equatable, Hashable {
        public let element: XMLElement
        
        /// Returns the library name, derived from the `location` URL.
        public var name: String? {
            element.fcpLibraryName
        }
        
        public var location: URL? {
            get { element.fcpLibraryLocation }
            set { element.fcpLibraryLocation = newValue }
        }
        
        public var events: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
            element.fcpEvents
        }
        
        // TODO: add smart-collection iterator
        
        public init(element: XMLElement) {
            self.element = element
        }
    }
}

extension FinalCutPro.FCPXML.Library {
    public var structureElementType: FinalCutPro.FCPXML.StructureElementType {
        .library
    }
    
    public enum Attributes: String, XMLParsableAttributesKey {
        /// Specifies the URL of a library on export; Final Cut Pro ignores this option during the
        /// XML import. To specify the target library for the XML import, see the `library` location
        /// key listed under the `[import-options`](
        /// https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/import-options
        /// ) attributes.
        case location
        
        /// Specifies whether the library supports `standard`, `wide`, or `wide-hdr` color gamut.
        /// The default is `standard`.
        case colorProcessing
    }
    
    public enum Children: String {
        case event
        case smartCollection = "smart-collection"
    }
    
    // can contain `event`s
    // can contain `smart-collection`s
}

extension XMLElement { // Library
    /// Returns the library name, derived from the `location` URL.
    /// Call on a `library` element.
    public var fcpLibraryName: String? {
        guard let libraryLocation = fcpLibraryLocation else { return nil }
        
        // will be a file URL that is URL encoded
        let libName = libraryLocation
            .deletingPathExtension()
            .lastPathComponent
        
        // decode URL encoding
        let libNameDecoded = libName.removingPercentEncoding ?? libName
        
        return libNameDecoded
    }
    
    /// Get or set the library `location` URL.
    /// Call on a `library` element.
    public var fcpLibraryLocation: URL? {
        get { getURL(forAttribute: "location") }
        set { set(url: newValue, forAttribute: "location") }
    }
}

#endif
