//
//  FCPXML Media.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    // TODO: xml variable is temporary; finish parsing the xml
    
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
    /// > See [`media`](https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/media).
    public struct Media: Equatable, Hashable {
        public var xml: XMLElement
        
        public init(xml: XMLElement) {
            self.xml = xml
        }
    }
}

extension FinalCutPro.FCPXML.Media {
    // /// Attributes unique to ``Media``.
    // public enum Attributes: String {
    //     // ...
    // }
    
    init(from xmlLeaf: XMLElement) {
        xml = xmlLeaf
    }
}

#endif
