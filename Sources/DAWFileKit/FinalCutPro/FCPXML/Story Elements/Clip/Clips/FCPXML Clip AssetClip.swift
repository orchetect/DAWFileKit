//
//  FCPXML Clip AssetClip.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML.Clip {
    // <asset-clip ref="r2" offset="0s" name="Nature Makes You Happy" duration="355100/2500s" tcFormat="NDF" audioRole="dialogue">
    /// Asset Clip.
    /// References a single media asset.
    ///
    /// > Final Cut Pro FCPXML 1.11 Reference:
    /// >
    /// > Use an `asset-clip` element as a shorthand for a `clip` when it references the entire set
    /// > of media components in a single media.
    /// >
    /// > Specify the timing of the edit through the Timing Attributes. The `start` and `duration`
    /// > attributes of the `asset-clip` element apply to all media components in the asset.
    /// >
    /// > Use the `audio-role` and `video-role` attributes to specify the main role. Generate
    /// > subroles using the main role name, followed by a numerical suffix. For example,
    /// > `dialogue.dialogue-1`, `dialogue.dialogue-2` and so on.
    /// >
    /// > Just as you do with the `clip` element, you can also use a `asset-clip` element as an
    /// > immediate child element of an event element to represent a browser clip. In this case, use
    /// > the Timeline Attributes to specify its format, etc.
    /// >
    /// > > Note:
    /// > > FCPXML 1.6 added the `asset-clip` element to add both the audio and video media
    /// > > components from a media file as a clip.
    public struct AssetClip: FCPXMLStoryElement {
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

extension FinalCutPro.FCPXML.Clip.AssetClip {
    /// Asset clip XML Attributes.
    public enum Attributes: String {
        case ref // resource ID
        case offset // TODO: replace with FCPXMLTimingAttributes
        case name
        case duration // TODO: replace with FCPXMLTimingAttributes
        case audioRole
    }
    
    internal init(
        from xmlLeaf: XMLElement,
        sequenceFrameRate frameRate: TimecodeFrameRate
    ) {
        // "ref"
        ref = FinalCutPro.FCPXML.Clip.getRef(from: xmlLeaf)
        
        // TODO: replace with FCPXMLTimingAttributes
        // "offset"
        offset = FinalCutPro.FCPXML.Clip.getTimecode(
            attribute: .offset,
            from: xmlLeaf,
            sequenceFrameRate: frameRate
        )
        
        // "name"
        name = FinalCutPro.FCPXML.Clip.getName(from: xmlLeaf)
        
        // TODO: replace with FCPXMLTimingAttributes
        // "duration"
        duration = FinalCutPro.FCPXML.Clip.getTimecode(
            attribute: .duration,
            from: xmlLeaf,
            sequenceFrameRate: frameRate
        )
        
        // "audioRole"
        audioRole = xmlLeaf.attributeStringValue(forName: Attributes.audioRole.rawValue) ?? ""
    }
}

#endif

