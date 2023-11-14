//
//  FCPXML RefClip.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    /// References a compound clip media.
    ///
    /// > Final Cut Pro FCPXML 1.11 Reference:
    /// >
    /// > Use a `ref-clip` element to describe a timeline sequence created from a
    /// > [Compound Clip Media](
    /// > https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/story_elements/ref-clip
    /// > ).
    /// > The edit uses the entire set of media components in the compound clip media. Specify the
    /// > timing of the edit through the [Timing Attributes](
    /// > https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/story_elements/timing_attributes
    /// > ).
    /// >
    /// > You can also use a ref-clip element as an immediate child element of an event element to
    /// > represent a browser clip. In this case, use the [Timeline Attributes](
    /// > https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/story_elements/ref-clip
    /// > ) to specify its format and other attributes.
    public struct RefClip: FCPXMLStoryElement {
        public var xml: XMLElement
        
        // TODO: placeholder. finish building this.
        
        public init(
            xml: XMLElement
        ) {
            self.xml = xml
        }
    }
}

extension FinalCutPro.FCPXML.RefClip {
    init(
        from xmlLeaf: XMLElement
    ) {
        xml = xmlLeaf
    }
}

#endif
