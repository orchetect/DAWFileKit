//
//  FCPXML Clip.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    /// Represents a basic unit of editing.
    ///
    /// > Final Cut Pro FCPXML 1.11 Reference:
    /// >
    /// > Use a `clip` element to describe a timeline sequence created from a source media file. A
    /// > `clip` contains video and/or audio elements, each of which represents a media component
    /// > (usually a track) in media. Specify the timing of the edit through the
    /// > [Timing Attributes](
    /// > https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/story_elements/clip
    /// > ).
    /// >
    /// > You can also use a `clip` element as an immediate child element of an event element to
    /// > represent a browser clip. In this case, use the [Timeline Attributes](
    /// > https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/story_elements/clip
    /// > ) to specify its format, etc.
    public struct Clip: FCPXMLStoryElement {
        public var xml: XMLElement // TODO: placeholder. finish building this.
        
        public var clips: [AnyClip]
        public var markers: [FinalCutPro.FCPXML.Marker] // TODO: refactor as attributes
        
        public init(
            clips: [AnyClip],
            markers: [FinalCutPro.FCPXML.Marker]
        ) {
            xml = XMLElement() // TODO: temporary
            
            self.clips = clips
            self.markers = markers
        }
    }
}

extension FinalCutPro.FCPXML.Clip {
    init(
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) {
        xml = xmlLeaf
        clips = FinalCutPro.FCPXML.parseClips(in: xmlLeaf, resources: resources)
        markers = FinalCutPro.FCPXML.parseMarkers(in: xmlLeaf, resources: resources)
    }
}

#endif
