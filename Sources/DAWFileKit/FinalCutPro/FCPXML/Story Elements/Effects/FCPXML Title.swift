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
        public let name: String
        
        // FCPXMLTimingAttributes
        public let offset: Timecode
        public let start: Timecode
        public let duration: Timecode
        
        // TODO: add audio/video roles?
        
        // TODO: should probably be story elements, not just markers
        public let markers: [FinalCutPro.FCPXML.Marker]
        
        internal init(
            ref: String,
            name: String,
            offset: Timecode,
            start: Timecode,
            duration: Timecode,
            markers: [FinalCutPro.FCPXML.Marker] // TODO: should probably be story elements, not just markers
        ) {
            self.ref = ref
            self.name = name
            self.offset = offset
            self.start = start
            self.duration = duration
            self.markers = markers
        }
    }
}

extension FinalCutPro.FCPXML.Title: FCPXMLTimingAttributes {
    /// Title clip XML Attributes.
    public enum Attributes: String {
        case ref // resource ID
        case name
        // case offset // handled with FCPXMLTimingAttributes
        // case start // handled with FCPXMLTimingAttributes
        // case duration // handled with FCPXMLTimingAttributes
    }
    
    /// Note: `frameDuration` and `tcFormat` is not stored in `<title>`,
    /// it's inferred from the parent sequence.
    internal init(
        from xmlLeaf: XMLElement,
        frameRate: TimecodeFrameRate,
        resources: [String: FinalCutPro.FCPXML.Resource]
    ) {
        // `ref`
        ref = FinalCutPro.FCPXML.getRefAttribute(from: xmlLeaf)
        
        // `name`
        name = FinalCutPro.FCPXML.getNameAttribute(from: xmlLeaf)
        
        let timingAttributes = Self.parseTimingAttributesDefaulted(
            frameRate: frameRate,
            from: xmlLeaf,
            resources: resources
        )
        
        // `offset`
        offset = timingAttributes.offset
        
        // `start`
        start = timingAttributes.start
        
        // `duration`
        duration = timingAttributes.duration
        
        // TODO: should probably be story elements, not just markers
        markers = FinalCutPro.FCPXML.getMarkers(from: xmlLeaf, frameRate: frameRate)
    }
}

#endif
