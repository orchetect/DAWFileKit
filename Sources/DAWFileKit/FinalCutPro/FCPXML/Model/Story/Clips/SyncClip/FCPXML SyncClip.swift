//
//  FCPXML SyncClip.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import OTCore

extension FinalCutPro.FCPXML {
    /// Contains a clip with its contained and anchored items synchronized.
    ///
    /// In Final Cut Pro, a Sync Clip does not bear roles itself.
    /// Instead, it inherits the video and audio role of the asset clip(s) within it.
    ///
    /// > Final Cut Pro FCPXML 1.11 Reference:
    /// >
    /// > Use the `sync-source` element to describe the audio components of a synchronized clip.
    public struct SyncClip: FCPXMLElement {
        public let element: XMLElement
        
        // Element-Specific Attributes
        
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
        
        public init(element: XMLElement) {
            self.element = element
        }
    }
}

extension FinalCutPro.FCPXML.SyncClip: FCPXMLElementClipAttributes { }

extension FinalCutPro.FCPXML.SyncClip: FCPXMLElementOptionalTCStart { }

extension FinalCutPro.FCPXML.SyncClip: FCPXMLElementOptionalTCFormat { }

extension FinalCutPro.FCPXML.SyncClip /* : FCPXMLElementAudioStartAndDuration */ {
    public var audioStart: Fraction? {
        get { element.fcpAudioStart }
        set { element.fcpAudioStart = newValue }
    }
    
    public var audioDuration: Fraction? {
        get { element.fcpAudioDuration }
        set { element.fcpAudioDuration = newValue }
    }
}

extension FinalCutPro.FCPXML.SyncClip: FCPXMLElementNoteChild { }

extension FinalCutPro.FCPXML.SyncClip: FCPXMLElementMetadataChild { }

extension FinalCutPro.FCPXML.SyncClip: FCPXMLElementOptionalModDate { }

extension FinalCutPro.FCPXML.SyncClip /* : FCPXMLElementSyncSourceChildren */ {
    /// Returns child `sync-source` elements.
    public var syncSources: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
        element.fcpSyncSources()
    }
}

extension FinalCutPro.FCPXML.SyncClip {
    public static let clipType: FinalCutPro.FCPXML.ClipType = .syncClip
    
    public enum Attributes: String, XMLParsableAttributesKey {
        // Element-Specific Attributes
        case format
        case audioStart
        case audioDuration
        case tcStart
        case tcFormat
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
        case syncSource = "sync-source"
    }
    
    // contains DTD %timing-params
    // contains DTD %intrinsic-params
    // contains captions
    // contains markers
    // contains DTD %video_filter_item*
    // contains DTD filter-audio*
}

extension XMLElement { // SyncClip
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/SyncClip`` model object.
    /// Call this on a `sync-clip` element only.
    public var fcpAsSyncClip: FinalCutPro.FCPXML.SyncClip {
        .init(element: self)
    }
}

#endif
