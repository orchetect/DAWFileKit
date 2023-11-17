//
//  FCPXML Gap.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    /// Gap element.
    ///
    /// > Final Cut Pro FCPXML 1.11 Reference:
    /// >
    /// > Defines a placeholder element that has no intrinsic audio or video data.
    public struct Gap {
        public var clips: [AnyClip]
        public var markers: [FinalCutPro.FCPXML.Marker] // TODO: refactor as AnyAnnotation?
        
        // FCPXMLAnchorableAttributes
        public var lane: Int? // TODO: Gap doesn't have lane attribute?
        public var offset: Timecode?
        
        // FCPXMLClipAttributes
        public var name: String?
        public var start: Timecode?
        public var duration: Timecode?
        public var enabled: Bool
        
        // TODO: add missing attributes and protocols
        
        public init(
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

extension FinalCutPro.FCPXML.Gap: FCPXMLClipAttributes {
    // no ref, no role
    // no lane
    init(
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) {
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
}

extension FinalCutPro.FCPXML.Gap: FCPXMLClip {
    public var clipType: FinalCutPro.FCPXML.ClipType { .gap }
    
    public func asAnyClip() -> FinalCutPro.FCPXML.AnyClip {
        .gap(self)
    }
}

extension FinalCutPro.FCPXML.Gap: _FCPXMLExtractableElement {
    var extractableStart: Timecode? { start }
    var extractableName: String? { name }
}

extension FinalCutPro.FCPXML.Gap: FCPXMLMarkersExtractable {
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
