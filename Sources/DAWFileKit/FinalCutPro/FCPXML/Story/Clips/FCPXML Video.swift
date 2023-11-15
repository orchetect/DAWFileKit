//
//  FCPXML Video.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    // <video ref="r7" offset="869600/2500s" name="Clouds" start="3600s" duration="250300/2500s" role="Sample Role.Sample Role-1">
    
    /// Video element.
    ///
    /// > Final Cut Pro FCPXML 1.11 Reference:
    /// >
    /// > References video data from an `asset` or `effect` element.
    public struct Video: FCPXMLStoryElement, FCPXMLClipAttributes {
        public let ref: String // resource ID, required
        public let role: String?
        public var auditions: [Audition]
        public var clips: [AnyClip]
        public var markers: [FinalCutPro.FCPXML.Marker] // TODO: refactor as attributes
        
        // FCPXMLAnchorableAttributes
        public let lane: Int?
        public let offset: Timecode?
        
        // FCPXMLClipAttributes
        public let name: String?
        public let start: Timecode?
        public let duration: Timecode?
        public let enabled: Bool
        
        // TODO: add missing attributes and protocols
        
        public init(
            ref: String,
            role: String?,
            auditions: [Audition],
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

extension FinalCutPro.FCPXML.Video {
    /// Attributes unique to ``Video`` clip.
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
        role = xmlLeaf.attributeStringValue(forName: Attributes.role.rawValue)
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
}

extension FinalCutPro.FCPXML.Video: FCPXMLMarkersExtractable {
    public func extractMarkers(
        settings: FCPXMLMarkersExtractionSettings
    ) -> [FinalCutPro.FCPXML.ExtractedMarker] {
        markers.convertToExtractedMarkers(settings: settings, parent: .video(self))
            + auditions.flatMap { $0.extractMarkers(settings: settings) }
            + clips.flatMap { $0.extractMarkers(settings: settings) }
    }
}

#endif
