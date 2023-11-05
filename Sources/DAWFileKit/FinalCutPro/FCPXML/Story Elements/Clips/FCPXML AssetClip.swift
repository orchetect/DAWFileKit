//
//  FCPXML AssetClip.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
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
        public var ref: String // resource ID
        public var audioRole: String?
        
        // FCPXMLAnchorableAttributes
        public var lane: Int?
        public var offset: Timecode?
        
        // FCPXMLClipAttributes
        public var name: String?
        public var start: Timecode?
        public var duration: Timecode?
        public var enabled: Bool
        
        // TODO: add attributes array, ie: markers?
        
        internal init(
            ref: String,
            audioRole: String?,
            // FCPXMLAnchorableAttributes
            lane: Int?,
            offset: Timecode,
            // FCPXMLClipAttributes
            name: String,
            start: Timecode, // TODO: not used?
            duration: Timecode,
            enabled: Bool
        ) {
            self.ref = ref
            self.audioRole = audioRole
            
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

extension FinalCutPro.FCPXML.AssetClip: FCPXMLClipAttributes {
    /// Attributes unique to Asset Clip.
    public enum Attributes: String {
        case ref // resource ID
        case audioRole
    }
    
    internal init(
        from xmlLeaf: XMLElement,
        frameRate: TimecodeFrameRate
    ) {
        ref = FinalCutPro.FCPXML.getRefAttribute(from: xmlLeaf) ?? "" // TODO: error condition?
        audioRole = xmlLeaf.attributeStringValue(forName: Attributes.audioRole.rawValue)
        
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

