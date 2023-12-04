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
    public struct Media: Equatable, Hashable {
        public let element: XMLElement
        
        // shared resource attributes
        
        public var id: String {
            get { element.fcpID ?? "" }
            set { element.fcpID = newValue }
        }
        
        public var name: String? {
            get { element.fcpName }
            set { element.fcpName = newValue }
        }
        
        public init(element: XMLElement) {
            self.element = element
        }
    }
}

extension FinalCutPro.FCPXML.Media {
    public static let resourceType: FinalCutPro.FCPXML.ResourceType = .media
    
    public enum Attributes: String, XMLParsableAttributesKey {
        // shared resource attributes
        case id
        case name
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
    /// Returns the element wrapped in a ``/FinalCutPro/FCPXML/Media`` model object.
    /// Call this on a `media` element only.
    public var asMedia: FinalCutPro.FCPXML.Media {
        .init(element: self)
    }
}

#endif
