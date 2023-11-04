//
//  FCPXML Clip Title.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML.Clip {
    // <title ref="r2" offset="0s" name="Basic Title" start="0s" duration="1920919/30000s">
    /// Title Clip.
    ///
    /// This is a FCP meta type and video is generated.
    /// Its frame rate is inferred from the sequence.
    /// Therefore, "tcFormat" (NDF/DF) attribute is not stored in `<title>` XML itself.
    public struct Title {
        public let ref: String // resource ID
        public let offset: Timecode
        public let name: String
        public let start: Timecode
        public let duration: Timecode
        // TODO: add audio/video roles?
        
        // Contents
        public let markers: [FinalCutPro.FCPXML.Marker]
        
        internal init(
            ref: String,
            offset: Timecode,
            name: String,
            start: Timecode,
            duration: Timecode,
            markers: [FinalCutPro.FCPXML.Marker]
        ) {
            self.ref = ref
            self.offset = offset
            self.name = name
            self.start = start
            self.duration = duration
            self.markers = markers
        }
    }
}

extension FinalCutPro.FCPXML.Clip.Title {
    /// Title clip XML Attributes.
    public enum Attributes: String {
        case ref // resource ID
        case offset
        case name
        case start
        case duration
    }
    
    /// Note: `frameDuration` and `tcFormat` is not stored in `<title>`,
    /// it's inferred from the parent sequence.
    internal init(
        from xmlLeaf: XMLElement,
        sequenceFrameRate frameRate: TimecodeFrameRate
    ) {
        // "ref"
        ref = FinalCutPro.FCPXML.Clip.getRef(from: xmlLeaf)
        
        // "offset"
        offset = FinalCutPro.FCPXML.Clip.getTimecode(
            attribute: .offset,
            from: xmlLeaf,
            sequenceFrameRate: frameRate
        )
        
        // "name"
        name = FinalCutPro.FCPXML.Clip.getName(from: xmlLeaf)
        
        // "start"
        start = FinalCutPro.FCPXML.Clip.getTimecode(
            attribute: .start,
            from: xmlLeaf,
            sequenceFrameRate: frameRate
        )
        
        // "duration"
        duration = FinalCutPro.FCPXML.Clip.getTimecode(
            attribute: .duration,
            from: xmlLeaf,
            sequenceFrameRate: frameRate
        )
        
        // contents
        markers = FinalCutPro.FCPXML.Clip.getMarkers(from: xmlLeaf, sequenceFrameRate: frameRate)
    }
}

#endif
