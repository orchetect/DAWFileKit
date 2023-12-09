//
//  FCPXML Media.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    /// Media shared resource.
    ///
    /// > Final Cut Pro FCPXML 1.11 Reference:
    /// >
    /// > Describe a compound clip or a multi-camera media definition.
    /// >
    /// > A `media` element describes the construction of a compound clip media or a multicam media.
    /// > Use the `sequence` element to describe a compound clip media, and the `multicam` element
    /// > to describe a multicam media.
    /// >
    /// > See [`media`](
    /// > https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/media
    /// > ).
    public struct Media: FCPXMLElement {
        public let element: XMLElement
        public let elementName: String = "media"
        
        // shared resource attributes
        
        public var id: String {
            get { element.fcpID ?? "" }
            set { element.fcpID = newValue }
        }
        
        public var name: String? {
            get { element.fcpName }
            set { element.fcpName = newValue }
        }
        
        public var projectRef: String? {
            get { element.stringValue(forAttributeNamed: Attributes.projectRef.rawValue) }
            set { element.addAttribute(withName: Attributes.projectRef.rawValue, value: newValue) }
        }
        
        // asset attributes
        
        public var uid: String? {
            get { element.fcpUID }
            set { element.fcpUID = newValue }
        }
        
        // Children
        
        /// Returns the `multicam` child element if one exists.
        public var multicam: Multicam? {
            element
                .firstChildElement(named: Children.multicam.rawValue)?
                .fcpAsMulticam
        }
        
        /// Returns the `sequence` child element if one exists.
        public var sequence: Sequence? {
            element
                .firstChildElement(named: Children.sequence.rawValue)?
                .fcpAsSequence
        }
        
        // MARK: FCPXMLElement inits
        
        public init() {
            element = XMLElement(name: elementName)
        }
        
        public init?(element: XMLElement) {
            self.element = element
            guard _isElementValid(element: element) else { return nil }
        }
    }
}

extension FinalCutPro.FCPXML.Media: FCPXMLElementOptionalModDate { }

extension FinalCutPro.FCPXML.Media {
    public static let resourceType: FinalCutPro.FCPXML.ResourceType = .media
    
    public enum Attributes: String {
        // shared resource attributes
        case id
        case name
        
        // asset attributes
        case uid
        case projectRef
    }
    
    public enum Children: String {
        case multicam
        case sequence
    }
}

extension FinalCutPro.FCPXML.Media {
    public enum MediaType: Equatable, Hashable {
        case multicam
        case sequence
    }
}

extension XMLElement { // Media
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/Media`` model object.
    /// Call this on a `media` element only.
    public var fcpAsMedia: FinalCutPro.FCPXML.Media? {
        .init(element: self)
    }
}

#endif
