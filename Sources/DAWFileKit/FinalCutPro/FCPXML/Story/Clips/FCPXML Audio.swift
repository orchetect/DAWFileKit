//
//  FCPXML Audio.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    /// Audio element.
    ///
    /// > Final Cut Pro FCPXML 1.11 Reference:
    /// >
    /// > References audio data from an `asset` or `effect` element.
    public struct Audio: FCPXMLStoryElement {
        public var ref: String // resource ID, required
        public var role: String?
        public var auditions: [Audition]
        public var clips: [AnyClip]
        public var markers: [FinalCutPro.FCPXML.Marker] // TODO: refactor as attributes
        
        // FCPXMLAnchorableAttributes
        public var lane: Int?
        public var offset: Timecode?
        
        // FCPXMLClipAttributes
        public var name: String?
        public var start: Timecode?
        public var duration: Timecode?
        public var enabled: Bool
        
        // TODO: add missing attributes and protocols
        
        public init(
            ref: String,
            role: String?,
            auditions: [Audition],
            clips: [AnyClip],
            markers: [FinalCutPro.FCPXML.Marker],
            // FCPXMLAnchorableAttributes
            lane: Int?,
            offset: Timecode,
            // FCPXMLClipAttributes
            name: String,
            start: Timecode, // TODO: not used?
            duration: Timecode,
            enabled: Bool
        ) {
            self.ref = ref
            self.role = role
            self.auditions = auditions
            self.clips = clips
            self.markers = markers
            
            // FCPXMLAnchorableAttributes
            self.lane = lane
            self.offset = offset
            
            // FCPXMLClipAttributes
            self.name = name
            self.start = start // TODO: not used?
            self.duration = duration
            self.enabled = enabled
        }
    }
}

extension FinalCutPro.FCPXML.Audio: FCPXMLClipAttributes {
    /// Attributes unique to ``Audio``.
    public enum Attributes: String {
        case ref // resource ID
        case role
    }
    
    init?(
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) {
        guard let ref = FinalCutPro.FCPXML.getRefAttribute(from: xmlLeaf) else { return nil }
        self.ref = ref
        
        auditions = FinalCutPro.FCPXML.parseAuditions(in: xmlLeaf, resources: resources)
        clips = FinalCutPro.FCPXML.parseClips(in: xmlLeaf, resources: resources)
        markers = FinalCutPro.FCPXML.parseMarkers(in: xmlLeaf, resources: resources)
        role = xmlLeaf.attributeStringValue(forName: Attributes.role.rawValue)
        
        let clipAttributes = Self.parseClipAttributes(
            from: xmlLeaf,
            resources: resources
        )
        
        // FCPXMLAnchorableAttributes
        lane = clipAttributes.lane
        offset = clipAttributes.offset
        
        // FCPXMLClipAttributes
        name = FinalCutPro.FCPXML.getNameAttribute(from: xmlLeaf)
        start = clipAttributes.start
        duration = clipAttributes.duration
        enabled = clipAttributes.enabled
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
