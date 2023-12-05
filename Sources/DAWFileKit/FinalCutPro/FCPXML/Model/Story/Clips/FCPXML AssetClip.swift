//
//  FCPXML AssetClip.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import OTCore

extension FinalCutPro.FCPXML {
    /// Asset Clip element.
    ///
    /// > Final Cut Pro FCPXML 1.11 Reference:
    /// >
    /// > References a single media asset.
    /// >
    /// > Use an `asset-clip` element as a shorthand for a `clip` when it references the entire set
    /// > of media components in a single media.
    /// >
    /// > Specify the timing of the edit through the Timing Attributes. The `start` and `duration`
    /// > attributes of the `asset-clip` element apply to all media components in the asset.
    /// >
    /// > Use the `audioRole` and `videoRole` attributes to specify the main role. Generate
    /// > subroles using the main role name, followed by a numerical suffix. For example,
    /// > `dialogue.dialogue-1`, `dialogue.dialogue-2` and so on.
    /// >
    /// > Just as you do with the `clip` element, you can also use a `asset-clip` element as an
    /// > immediate child element of an `event` element to represent a browser clip. In this case,
    /// > use the Timeline Attributes to specify its format, etc.
    /// >
    /// > > Note:
    /// > > FCPXML 1.6 added the `asset-clip` element to add both the audio and video media
    /// > > components from a media file as a clip.
    public struct AssetClip: Equatable, Hashable {
        public let element: XMLElement
        
        /// Required.
        /// Resource ID.
        public var ref: String {
            get { element.fcpRef ?? "" }
            set { element.fcpRef = newValue }
        }
        
        public var audioRole: AudioRole? {
            get { element.fcpAudioRole }
            set { element.fcpAudioRole = newValue }
        }
        
        public var videoRole: VideoRole? {
            get { element.fcpVideoRole }
            set { element.fcpVideoRole = newValue }
        }
        
        // Anchorable Attributes
        
        public var lane: Int? {
            get { element.fcpLane }
            set { element.fcpLane = newValue }
        }
        
        public var offset: Fraction? {
            get { element.fcpOffset }
            set { element.fcpOffset = newValue }
        }
        
        // Clip Attributes
        
        public var name: String {
            get { element.fcpName ?? "" }
            set { element.fcpName = newValue }
        }
        
        public var start: Fraction? {
            get { element.fcpStart }
            set { element.fcpStart = newValue }
        }
        
        public var duration: Fraction? {
            get { element.fcpDuration }
            set { element.fcpDuration = newValue }
        }
        
        public var enabled: Bool {
            get { element.fcpGetEnabled(default: true) }
            set { element.fcpSet(enabled: newValue, default: true) }
        }
        
        // Children
        
        /// Returns child `audio-channel-source` elements.
        public var audioChannelSources: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
            element.fcpAudioChannelSources
        }
        
        /// Returns all child elements.
        public var contents: LazyCompactMapSequence<[XMLNode], XMLElement> {
            element.childElements
        }
        
        /// Returns child story elements.
        public var storyElements: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
            element.fcpStoryElements
        }
        
        // TODO: add missing attributes and protocols
        
        public init(element: XMLElement) {
            self.element = element
        }
    }
}

extension FinalCutPro.FCPXML.AssetClip {
    public static let clipType: FinalCutPro.FCPXML.ClipType = .assetClip
    
    public enum Attributes: String, XMLParsableAttributesKey {
        /// Resource ID.
        /// Required.
        case ref
        case audioRole
        case videoRole
        
        // Anchorable Attributes
        case lane
        case offset
        
        // Clip Attributes
        case name
        case start
        case duration
        case enabled
    }
    
    public enum Children: String {
        case audioChannelSource = "audio-channel-source"
    }
    
    // contains story elements
}

extension XMLElement { // AssetClip
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/AssetClip`` model object.
    /// Call this on a `asset-clip` element only.
    public var fcpAsAssetClip: FinalCutPro.FCPXML.AssetClip {
        .init(element: self)
    }
}

extension XMLElement { // AssetClip
    /// FCPXML: Returns child `audio-channel-source` elements.
    /// Use on `clip` or `asset-clip` elements.
    public var fcpAudioChannelSources: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
        childElements
            .filter(whereElementNamed: FinalCutPro.FCPXML.AssetClip.Children.audioChannelSource.rawValue)
    }
}

#endif

