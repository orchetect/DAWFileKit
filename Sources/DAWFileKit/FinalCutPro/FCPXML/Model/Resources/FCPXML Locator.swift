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
    public enum Locator { }
}

extension FinalCutPro.FCPXML.Locator {
    public static let resourceType: FinalCutPro.FCPXML.ResourceType = .locator
    
    public enum Attributes: String, XMLParsableAttributesKey {
        /// Required.
        case id
        
        /// Required.
        /// Absolute or relative URL to library path.
        case url
    }
}

#endif
