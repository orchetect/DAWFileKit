//
//  FCPXML MCClip.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

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
    public struct MCClip: FCPXMLClipAttributes {
        public var ref: String // resource ID, required
        public var clips: [AnyClip]
        public var markers: [FinalCutPro.FCPXML.Marker] // TODO: refactor as AnyAnnotation?
        
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
            clips: [AnyClip],
            markers: [FinalCutPro.FCPXML.Marker],
            // FCPXMLAnchorableAttributes
            lane: Int?,
            offset: Timecode?,
            // FCPXMLClipAttributes
            name: String?,
            start: Timecode?,
            duration: Timecode?,
            enabled: Bool
        ) {
            self.ref = ref
            self.clips = clips
            self.markers = markers
            
            // FCPXMLAnchorableAttributes
            self.lane = lane
            self.offset = offset
            
            // FCPXMLClipAttributes
            self.name = name
            self.start = start
            self.duration = duration
            self.enabled = enabled
        }
    }
}

extension FinalCutPro.FCPXML.MCClip: FCPXMLClip {
    /// Attributes unique to ``MCClip`` clip.
    public enum Attributes: String {
        case ref // resource ID
    }
    
    public init?(
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) {
        guard let ref = FinalCutPro.FCPXML.getRefAttribute(from: xmlLeaf) else { return nil }
        self.ref = ref
        
        clips = FinalCutPro.FCPXML.parseClips(in: xmlLeaf, resources: resources)
        markers = FinalCutPro.FCPXML.parseMarkers(in: xmlLeaf, resources: resources)
        
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
    
    public var clipType: FinalCutPro.FCPXML.ClipType { .mcClip }
    public func asAnyClip() -> FinalCutPro.FCPXML.AnyClip { .mcClip(self) }
}

extension FinalCutPro.FCPXML.MCClip: _FCPXMLExtractableElement {
    var extractableStart: Timecode? { start }
    var extractableName: String? { name }
}

extension FinalCutPro.FCPXML.MCClip: FCPXMLMarkersExtractable {
    public func extractMarkers(
        settings: FinalCutPro.FCPXML.ExtractionSettings,
        ancestorsOfParent: [FinalCutPro.FCPXML.AnyStoryElement]
    ) -> [FinalCutPro.FCPXML.ExtractedMarker] {
        extractMarkers(
            settings: settings,
            ancestorsOfParent: ancestorsOfParent,
            children: clips.asAnyStoryElements()
        )
    }
}

#endif
