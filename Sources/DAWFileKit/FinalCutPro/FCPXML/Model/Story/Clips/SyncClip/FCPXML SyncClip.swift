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
        
        public let elementType: ElementType = .syncClip
        
        public static let supportedElementTypes: Set<ElementType> = [.syncClip]
        
        public init() {
            element = XMLElement(name: elementType.rawValue)
        }
        
        public init?(element: XMLElement) {
            self.element = element
            guard _isElementTypeSupported(element: element) else { return nil }
        }
    }
}

// MARK: - Parameterized init

extension FinalCutPro.FCPXML.SyncClip {
    public init(
        format: String? = nil,
        tcStart: Fraction? = nil,
        tcFormat: FinalCutPro.FCPXML.TimecodeFormat? = nil,
        // Audio Start/Duration
        audioStart: Fraction? = nil,
        audioDuration: Fraction? = nil,
        // Anchorable Attributes
        lane: Int? = nil,
        offset: Fraction? = nil,
        // Clip Attributes
        name: String? = nil,
        start: Fraction? = nil,
        duration: Fraction,
        enabled: Bool = true,
        // Mod Date
        modDate: String? = nil,
        // Note child
        note: String? = nil,
        // Metadata
        metadata: FinalCutPro.FCPXML.Metadata? = nil
    ) {
        self.init()
        
        self.format = format
        self.tcStart = tcStart
        self.tcFormat = tcFormat
        
        // Audio Start/Duration
        self.audioStart = audioStart
        self.audioDuration = audioDuration
        
        // Anchorable Attributes
        self.lane = lane
        self.offset = offset
        
        // Clip Attributes
        self.name = name
        self.start = start
        self.duration = duration
        self.enabled = enabled
        
        // Mod Date
        self.modDate = modDate
        
        // Note child
        self.note = note
        
        // Metadata
        self.metadata = metadata
    }
}

// MARK: - Structure

extension FinalCutPro.FCPXML.SyncClip {
    public enum Attributes: String {
        // Element-Specific Attributes
        case format
        case audioStart
        case audioDuration
        case tcStart
        case tcFormat
        
        // Anchorable Attributes
        case lane
        case offset
        
        // Clip Attributes
        case name
        case start
        case duration
        case enabled
        
        // Mod Date
        case modDate
    }
    
    // contains DTD sync-source*
    // contains DTD %timing-params
    // contains DTD %intrinsic-params
    // contains captions
    // contains markers
    // contains DTD %video_filter_item*
    // contains DTD filter-audio*
}

// MARK: - Attributes

extension FinalCutPro.FCPXML.SyncClip {
    public var format: String? { // DTD: default is same as parent
        get { element.fcpFormat }
        set { element.fcpFormat = newValue }
    }
}

extension FinalCutPro.FCPXML.SyncClip: FCPXMLElementClipAttributes { }

extension FinalCutPro.FCPXML.SyncClip: FCPXMLElementOptionalTCStart { }

extension FinalCutPro.FCPXML.SyncClip: FCPXMLElementOptionalTCFormat { }

extension FinalCutPro.FCPXML.SyncClip: FCPXMLElementAudioStartAndDuration { }

extension FinalCutPro.FCPXML.SyncClip: FCPXMLElementOptionalModDate { }

extension FinalCutPro.FCPXML.SyncClip: FCPXMLElementTimingParams { }

// MARK: - Children

extension FinalCutPro.FCPXML.SyncClip {
    /// Get or set child elements.
    public var contents: LazyCompactMapSequence<[XMLNode], XMLElement> {
        get { element.childElements }
        set {
            element.removeAllChildren()
            element.addChildren(newValue)
        }
    }
    
    /// Returns child story elements.
    public var storyElements: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
        element.fcpStoryElements
    }
}

extension FinalCutPro.FCPXML.SyncClip: FCPXMLElementNoteChild { }

extension FinalCutPro.FCPXML.SyncClip: FCPXMLElementMetadataChild { }

extension FinalCutPro.FCPXML.SyncClip /* : FCPXMLElementSyncSourceChildren */ {
    /// Returns child `sync-source` elements.
    public var syncSources: LazyFCPXMLChildrenSequence<FinalCutPro.FCPXML.SyncClip.SyncSource> {
        get { element.fcpSyncSources }
        set { element.fcpSyncSources = newValue }
    }
}

// MARK: - Typing

// SyncClip
extension XMLElement {
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/SyncClip`` model object.
    /// Call this on a `sync-clip` element only.
    public var fcpAsSyncClip: FinalCutPro.FCPXML.SyncClip? {
        .init(element: self)
    }
}

#endif
