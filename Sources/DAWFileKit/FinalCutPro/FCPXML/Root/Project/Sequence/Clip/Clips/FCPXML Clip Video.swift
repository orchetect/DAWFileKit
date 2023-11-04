//
//  FCPXML Clip Video.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML.Sequence.Clip {
    // <video ref="r7" offset="869600/2500s" name="Clouds" start="3600s" duration="250300/2500s" role="Sample Role.Sample Role-1">
    /// Video Clip.
    public struct Video {
        public let ref: String // resource ID
        public let offset: Timecode
        public let name: String
        public let start: Timecode
        public let duration: Timecode
        public let role: String
        
        internal init(
            ref: String,
            offset: Timecode,
            name: String,
            start: Timecode,
            duration: Timecode,
            role: String
        ) {
            self.ref = ref
            self.offset = offset
            self.name = name
            self.start = start
            self.duration = duration
            self.role = role
        }
    }
}

extension FinalCutPro.FCPXML.Sequence.Clip.Video {
    /// Video clip XML Attributes.
    public enum Attributes: String {
        case ref // resource ID
        case offset
        case name
        case start
        case duration
        case role
    }
    
    internal init(
        from xmlLeaf: XMLElement,
        sequenceFrameRate frameRate: TimecodeFrameRate
    ) {
        // "ref"
        ref = FinalCutPro.FCPXML.Sequence.Clip.getRef(from: xmlLeaf)
        
        // "offset"
        offset = FinalCutPro.FCPXML.Sequence.Clip.getTimecode(
            attribute: .offset,
            from: xmlLeaf,
            sequenceFrameRate: frameRate
        )
        
        // "name"
        name = FinalCutPro.FCPXML.Sequence.Clip.getName(from: xmlLeaf)
        
        // "start"
        start = FinalCutPro.FCPXML.Sequence.Clip.getTimecode(
            attribute: .start,
            from: xmlLeaf,
            sequenceFrameRate: frameRate
        )
        
        // "duration"
        duration = FinalCutPro.FCPXML.Sequence.Clip.getTimecode(
            attribute: .duration,
            from: xmlLeaf,
            sequenceFrameRate: frameRate
        )
        
        // "role"
        role = xmlLeaf.attributeStringValue(forName: Attributes.role.rawValue) ?? ""
    }
}

#endif
