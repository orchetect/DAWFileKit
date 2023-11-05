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
    
    /// Title Clip.
    ///
    /// This is a FCP meta type and video is generated.
    /// Its frame rate is inferred from the sequence.
    /// Therefore, "tcFormat" (NDF/DF) attribute is not stored in `<title>` XML itself.
    public struct Title: FCPXMLStoryElement {
        public let ref: String // resource ID
        public let markers: [FinalCutPro.FCPXML.Marker] // TODO: refactor as attributes
        // TODO: add audio/video roles?
        
        // FCPXMLAnchorableAttributes
        public let lane: Int?
        public let offset: Timecode?
        
        // FCPXMLClipAttributes
        public let name: String?
        public let start: Timecode?
        public let duration: Timecode?
        public let enabled: Bool
        
        internal init(
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
    }
    
    /// Note: `frameDuration` and `tcFormat` is not stored in `<title>`,
    /// it's inferred from the parent sequence.
    internal init(
        from xmlLeaf: XMLElement,
        frameRate: TimecodeFrameRate
    ) {
        ref = FinalCutPro.FCPXML.getRefAttribute(from: xmlLeaf) ?? "" // TODO: error condition?
        markers = FinalCutPro.FCPXML.getMarkers(from: xmlLeaf, frameRate: frameRate)
        
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
}

#endif
