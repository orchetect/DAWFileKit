//
//  FCPXML Locator.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    // TODO: xml variable is temporary; finish parsing the xml
    
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
    public struct Locator: Equatable, Hashable {
        public var id: String
        
        /// A string that specifies the location of the resource as an absolute or relative URL. For
        /// details about the URL, see the Location of Media Files section of `media-rep`.
        public var url: URL
        
        public init(id: String, url: URL) {
            self.id = id
            self.url = url
        }
    }
}

extension FinalCutPro.FCPXML.Locator: FCPXMLResource {
    /// Attributes unique to ``Locator``.
    public enum Attributes: String {
        case url
    }
    
    public init?(from xmlLeaf: XMLElement) {
        guard let id = FinalCutPro.FCPXML.getIDAttribute(from: xmlLeaf)
        else { return nil }
        self.id = id
        
        // TODO: handle relative file URLs - probably needs library path passed into this init.
        guard let urlString = xmlLeaf.attributeStringValue(forName: Attributes.url.rawValue),
              let url = URL(string: urlString)
        else { return nil }
        self.url = url
        
        // validate element name
        // (we have to do this last, after all properties are initialized in order to access self)
        guard xmlLeaf.name == resourceType.rawValue else { return nil }
    }
    
    public var resourceType: FinalCutPro.FCPXML.ResourceType { .locator }
    public func asAnyResource() -> FinalCutPro.FCPXML.AnyResource { .locator(self) }
}

#endif
