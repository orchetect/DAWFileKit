//
//  FCPXML MCClip.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    /// References a multicam media.
    ///
    /// > Final Cut Pro FCPXML 1.11 Reference:
    /// >
    /// > Use an `mc-clip` element to describe a timeline sequence created from a multicam media. To
    /// > use multicam media as a clip, see [Using Multicam Media](
    /// > https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/story_elements/mc-clip
    /// > ). To specify the timing of the edit,
    /// > use the [Timing Attributes](
    /// > https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/story_elements/mc-clip
    /// > ).
    public struct MCClip: FCPXMLStoryElement {
        public var xml: XMLElement
        
        // TODO: placeholder. finish building this.
        
        public init(
            xml: XMLElement
        ) {
            self.xml = xml
        }
    }
}

extension FinalCutPro.FCPXML.MCClip {
    init(
        from xmlLeaf: XMLElement
    ) {
        xml = xmlLeaf
    }
}

#endif
