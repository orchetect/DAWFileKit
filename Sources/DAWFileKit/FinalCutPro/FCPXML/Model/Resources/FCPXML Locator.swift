//
//  FCPXML Locator.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    /// Locator shared resource.
    ///
    /// > Final Cut Pro FCPXML 1.11 Reference:
    /// >
    /// > Describe a URL-based resource.
    /// >
    /// > Use the `locator` element to describe the location of data files associated with another
    /// > FCPXML element.
    /// >
    /// > See [`locator`](https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/locator).
    public struct Locator: FCPXMLElement {
        public let element: XMLElement
        public let elementName: String = "locator"
        
        /// Required.
        /// Identifier.
        public var id: String {
            get { element.fcpID ?? "" }
            set { element.fcpID = newValue }
        }
        
        /// Required.
        /// Absolute URL or relative URL to library path.
        public var url: URL? {
            get { element.getURL(forAttribute: Attributes.url.rawValue) }
            set { element.set(url: newValue, forAttribute: Attributes.url.rawValue) }
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

extension FinalCutPro.FCPXML.Locator: FCPXMLElementBookmarkChild { }

extension FinalCutPro.FCPXML.Locator {
    public static let resourceType: FinalCutPro.FCPXML.ResourceType = .locator
    
    public enum Attributes: String {
        /// Required.
        /// Identifier.
        case id
        
        /// Required.
        /// Absolute URL or relative URL to library path.
        case url
    }
}

extension XMLElement { // Locator
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/Locator`` model object.
    /// Call this on a `locator` element only.
    public var fcpAsLocator: FinalCutPro.FCPXML.Locator? {
        .init(element: self)
    }
}

#endif
