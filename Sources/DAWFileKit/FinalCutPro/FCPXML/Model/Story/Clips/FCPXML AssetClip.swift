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
    public struct AssetClip: FCPXMLElement {
        public let element: XMLElement
        public let elementName: String = "asset-clip"
        
        // Element-Specific Attributes
        
        /// Required.
        /// Resource ID.
        public var ref: String {
            get { element.fcpRef ?? "" }
            set { element.fcpRef = newValue }
        }
        
        /// Sources to enable for audio and video. (Default: `.all`)
        public var srcEnable: FinalCutPro.FCPXML.ClipSourceEnable {
            get { element.fcpClipSourceEnable }
            set { element.fcpClipSourceEnable = newValue }
        }
        
        public var format: String? { // DTD: default is same as parent
            get { element.fcpFormat }
            set { element.fcpFormat = newValue }
        }
        
        // Children
        
        /// Returns all child elements.
        public var contents: LazyCompactMapSequence<[XMLNode], XMLElement> {
            element.childElements
        }
        
        /// Returns child story elements.
        public var storyElements: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
            element.fcpStoryElements
        }
        
        // TODO: add missing attributes and protocols
        
        // MARK: FCPXMLElement inits
        
        public init() {
            element = XMLElement(name: elementName)
        }
        
        public init?(element: XMLElement) {
            self.element = element
            guard _isElementValid(element: element) else { return nil }
        }
    }
}

extension FinalCutPro.FCPXML.AssetClip: FCPXMLElementClipAttributesOptionalDuration { }

extension FinalCutPro.FCPXML.AssetClip: FCPXMLElementOptionalTCStart { }

extension FinalCutPro.FCPXML.AssetClip: FCPXMLElementOptionalTCFormat { }

extension FinalCutPro.FCPXML.AssetClip /* : FCPXMLElementAudioStartAndDuration */ {
    public var audioStart: Fraction? {
        get { element.fcpAudioStart }
        set { element.fcpAudioStart = newValue }
    }
    
    public var audioDuration: Fraction? {
        get { element.fcpAudioDuration }
        set { element.fcpAudioDuration = newValue }
    }
}

extension FinalCutPro.FCPXML.AssetClip /* FCPXMLElementOptionalAudioRole */ {
    public var audioRole: FinalCutPro.FCPXML.AudioRole? {
        get { element.fcpAudioRole }
        set { element.fcpAudioRole = newValue }
    }
}

extension FinalCutPro.FCPXML.AssetClip /* FCPXMLElementOptionalVideoRole */ {
    public var videoRole: FinalCutPro.FCPXML.VideoRole? {
        get { element.fcpVideoRole }
        set { element.fcpVideoRole = newValue }
    }
}

extension FinalCutPro.FCPXML.AssetClip: FCPXMLElementOptionalModDate { }

extension FinalCutPro.FCPXML.AssetClip: FCPXMLElementNoteChild { }

extension FinalCutPro.FCPXML.AssetClip: FCPXMLElementAudioChannelSourceChildren { }

extension FinalCutPro.FCPXML.AssetClip {
    public static let clipType: FinalCutPro.FCPXML.ClipType = .assetClip
    
    public enum Attributes: String {
        // Element-Specific Attributes
        case ref
        case format
        case tcStart
        case tcFormat
        case audioStart
        case audioDuration
        case audioRole
        case videoRole
        case srcEnable
        case modDate
        
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
    
    // contains DTD %timing-params
    // contains DTD %intrinsic-params
    // contains DTD %anchor_item* (includes captions)
    // contains markers
}

extension XMLElement { // AssetClip
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/AssetClip`` model object.
    /// Call this on a `asset-clip` element only.
    public var fcpAsAssetClip: FinalCutPro.FCPXML.AssetClip? {
        .init(element: self)
    }
}

#endif

