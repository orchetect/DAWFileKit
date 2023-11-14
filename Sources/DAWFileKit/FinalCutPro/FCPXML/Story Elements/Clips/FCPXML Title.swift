//
//  FCPXML Title.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    // <title ref="r2" offset="0s" name="Basic Title" start="0s" duration="1920919/30000s">
    
    /// Title clip.
    ///
    /// This is a FCP meta type and video is generated.
    /// Its frame rate is inferred from the sequence.
    /// Therefore, "tcFormat" (NDF/DF) attribute is not stored in `title` XML itself.
    public struct Title: FCPXMLStoryElement {
        public var ref: String // resource ID, required
        public var role: String?
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

extension FinalCutPro.FCPXML.Title: FCPXMLClipAttributes {
    /// Title clip XML Attributes.
    public enum Attributes: String {
        case ref // resource ID
        case role
    }
    
    /// Note: `frameDuration` and `tcFormat` is not stored in `<title>`,
    /// it's inferred from the parent sequence.
    internal init?(
        from xmlLeaf: XMLElement,
        frameRate: TimecodeFrameRate
    ) {
        guard let ref = FinalCutPro.FCPXML.getRefAttribute(from: xmlLeaf) else { return nil }
        self.ref = ref
        markers = FinalCutPro.FCPXML.parseMarkers(in: xmlLeaf, frameRate: frameRate)
        role = xmlLeaf.attributeStringValue(forName: Attributes.role.rawValue)
        
        let clipAttributes = Self.parseClipAttributes(
            frameRate: frameRate,
            from: xmlLeaf
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
    
    init?<C: FCPXMLTimelineAttributes>(
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource],
        timelineContext: C.Type,
        timelineContextInstance: C
    ) {
        guard let frameRate = FinalCutPro.FCPXML.parseTimecodeFrameRate(
            from: xmlLeaf,
            resources: resources,
            timelineContext: timelineContext,
            timelineContextInstance: timelineContextInstance
        ) else { return nil }
        self.init(from: xmlLeaf, frameRate: frameRate)
    }
}

#endif
