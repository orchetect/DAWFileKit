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
    public struct Audio: FCPXMLClipAttributes {
        public var ref: String // resource ID, required
        public var role: String?
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
            role: String?,
            clips: [AnyClip],
            markers: [FinalCutPro.FCPXML.Marker],
            // FCPXMLAnchorableAttributes
            lane: Int?,
            offset: Timecode,
            // FCPXMLClipAttributes
            name: String,
            start: Timecode,
            duration: Timecode,
            enabled: Bool
        ) {
            self.ref = ref
            self.role = role
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

extension FinalCutPro.FCPXML.Audio {
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
}

extension FinalCutPro.FCPXML.Audio: FCPXMLClip {
    public var clipType: FinalCutPro.FCPXML.ClipType { .audio }
    
    public func asAnyClip() -> FinalCutPro.FCPXML.AnyClip {
        .audio(self)
    }
}

extension FinalCutPro.FCPXML.Audio: _FCPXMLExtractableElement {
    var extractableStart: Timecode? { start }
    var extractableName: String? { name }
}

extension FinalCutPro.FCPXML.Audio: FCPXMLMarkersExtractable {
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
