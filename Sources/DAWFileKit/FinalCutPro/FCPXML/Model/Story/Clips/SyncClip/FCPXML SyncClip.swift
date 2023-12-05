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
    public struct SyncClip: Equatable, Hashable {
        public let element: XMLElement
        
        public var format: String? { // DTD: default is same as parent
            get { element.fcpFormat }
            set { element.fcpFormat = newValue }
        }
        
        public var audioStart: Fraction? {
            get { element.fcpAudioStart }
            set { element.fcpAudioStart = newValue }
        }
        
        public var audioDuration: Fraction? {
            get { element.fcpAudioDuration }
            set { element.fcpAudioDuration = newValue }
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
        
        /// Returns child `sync-source` elements.
        public var syncSources: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
            element.fcpSyncSources
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

extension FinalCutPro.FCPXML.SyncClip {
    public static let clipType: FinalCutPro.FCPXML.ClipType = .syncClip
    
    public enum Attributes: String, XMLParsableAttributesKey {
        case format
        
        case audioStart
        case audioDuration
        
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
    
    // contains story elements
}

#endif
