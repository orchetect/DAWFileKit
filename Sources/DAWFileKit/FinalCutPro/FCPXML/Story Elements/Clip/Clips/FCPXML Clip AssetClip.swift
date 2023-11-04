//
//  FCPXML Clip AssetClip.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML.Sequence.Clip {
    // <asset-clip ref="r2" offset="0s" name="Nature Makes You Happy" duration="355100/2500s" tcFormat="NDF" audioRole="dialogue">
    /// Asset Clip.
    public struct AssetClip {
        public let ref: String // resource ID
        public let offset: Timecode
        public let name: String
        public let duration: Timecode
        public let audioRole: String
        
        internal init(
            ref: String,
            offset: Timecode,
            name: String,
            duration: Timecode,
            audioRole: String
        ) {
            self.ref = ref
            self.offset = offset
            self.name = name
            self.duration = duration
            self.audioRole = audioRole
        }
    }
}

extension FinalCutPro.FCPXML.Sequence.Clip.AssetClip {
    /// Asset clip XML Attributes.
    public enum Attributes: String {
        case ref // resource ID
        case offset
        case name
        case duration
        case audioRole
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
        
        // "duration"
        duration = FinalCutPro.FCPXML.Sequence.Clip.getTimecode(
            attribute: .duration,
            from: xmlLeaf,
            sequenceFrameRate: frameRate
        )
        
        // "audioRole"
        audioRole = xmlLeaf.attributeStringValue(forName: Attributes.audioRole.rawValue) ?? ""
    }
}

#endif
