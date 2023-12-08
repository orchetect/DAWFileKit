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
    public struct Library: FCPXMLElement {
        public let element: XMLElement
        public let elementName: String = "library"
        
        // Element-Specific Attributes
        
        /// Specifies the URL of a library on export; Final Cut Pro ignores this option during the
        /// XML import. To specify the target library for the XML import, see the `library` location
        /// key listed under the `[import-options`](
        /// https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/import-options
        /// ) attributes.
        public var location: URL? {
            get { element.fcpLibraryLocation }
            set { element.fcpLibraryLocation = newValue }
        }
        
        /// Specifies whether the library supports `standard`, `wide`, or `wide-hdr` color gamut.
        /// The default is `standard`.
        public var colorProcessing: String? {
            get {
                element.stringValue(forAttributeNamed: Attributes.colorProcessing.rawValue)
            }
            set {
                element.addAttribute(withName: Attributes.colorProcessing.rawValue, value: newValue)
            }
        }
        
        // Children
        
        /// Multiple `event` elements may exist within the `library` element.
        public var events: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
            element.fcpEvents
        }
        
        // TODO: add smart-collection iterator
        
        // MARK: FCPXMLElement inits
        
        public init() {
            element = XMLElement(name: elementName)
        }
        
        public init?(element: XMLElement) {
            self.element = element
            guard _isElementValid(element: element) else { return nil }
        }
        
        // Custom inits
        
        /// Initialize an empty library with a location URL.
        public init(location: URL) {
            self.init()
            self.location = location
        }
    }
}

extension FinalCutPro.FCPXML.Library {
    public static let structureElementType: FinalCutPro.FCPXML.StructureElementType = .library
    
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

extension FinalCutPro.FCPXML.Library {
    /// Returns the library name, derived from the `location` URL.
    public var name: String? {
        element.fcpLibraryName
    }
}

extension XMLElement { // Library
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/Library`` model object.
    /// Call this on a `library` element only.
    public var fcpAsLibrary: FinalCutPro.FCPXML.Library? {
        .init(element: self)
    }
}

extension XMLElement { // Library
    /// FCPXML: Returns the library name, derived from the `location` URL.
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
    
    /// FCPXML: Get or set the library `location` URL.
    /// Call on a `library` element.
    public var fcpLibraryLocation: URL? {
        get { getURL(forAttribute: "location") }
        set { set(url: newValue, forAttribute: "location") }
    }
}

#endif
