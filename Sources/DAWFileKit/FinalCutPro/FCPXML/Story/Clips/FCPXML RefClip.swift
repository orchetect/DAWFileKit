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
        public var xml: XMLElement // TODO: placeholder. finish building this.
        
        public var auditions: [Audition]
        public var clips: [AnyClip]
        public var markers: [FinalCutPro.FCPXML.Marker] // TODO: refactor as attributes
        
        public init(
            auditions: [Audition],
            clips: [AnyClip],
            markers: [FinalCutPro.FCPXML.Marker]
        ) {
            xml = XMLElement() // TODO: temporary
            
            self.auditions = auditions
            self.clips = clips
            self.markers = markers
        }
    }
}

extension FinalCutPro.FCPXML.RefClip {
    init(
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) {
        xml = xmlLeaf // TODO: temporary
        
        auditions = FinalCutPro.FCPXML.parseAuditions(in: xmlLeaf, resources: resources)
        clips = FinalCutPro.FCPXML.parseClips(in: xmlLeaf, resources: resources)
        markers = FinalCutPro.FCPXML.parseMarkers(in: xmlLeaf, resources: resources)
    }
    
    // TODO: refactor using protocol and generics?
    /// Convenience to return markers within the clip.
    /// Operation is recursive and returns markers for all nested clips and elements.
    public func markersDeep(
        auditions auditionMask: FinalCutPro.FCPXML.Audition.Mask
    ) -> [FinalCutPro.FCPXML.Marker] {
        markers
            + auditions.flatMap { $0.markersDeep(for: auditionMask) }
            + clips.flatMap { $0.markersDeep(auditions: auditionMask) }
    }
}

#endif