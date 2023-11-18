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
        public var xml: XMLElement
    }
}

extension FinalCutPro.FCPXML.Locator: FCPXMLResource {
    // /// Attributes unique to ``Locator``.
    // public enum Attributes: String {
    //     // ...
    // }
    
    public init?(from xmlLeaf: XMLElement) {
        xml = xmlLeaf
        
        // validate element name
        // (we have to do this last, after all properties are initialized in order to access self)
        guard xmlLeaf.name == resourceType.rawValue else { return nil }
    }
    
    public var resourceType: FinalCutPro.FCPXML.ResourceType { .locator }
    public func asAnyResource() -> FinalCutPro.FCPXML.AnyResource { .locator(self) }
}

#endif
