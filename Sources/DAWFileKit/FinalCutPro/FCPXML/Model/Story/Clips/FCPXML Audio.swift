//
//  FCPXML Audio.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import OTCore

extension FinalCutPro.FCPXML {
    /// Audio element.
    ///
    /// > Final Cut Pro FCPXML 1.11 Reference:
    /// >
    /// > References audio data from an `asset` or `effect` element.
    public struct Audio {
        public let element: XMLElement
        
        /// Required.
        /// Resource ID
        public var ref: String? {
            get { element.fcpRef }
            set { element.fcpRef = newValue }
        }
        
        public var role: AudioRole? {
            get { element.fcpAudioRole }
            set { element.fcpAudioRole = newValue }
        }
        
        /// Source audio channels (comma separated, 1-based index, ie: "1, 2")
        public var sourceChannels: String? {
            get { element.fcpSourceChannels }
            set { element.fcpSourceChannels = newValue }
        }
        
        /// Output audio channels (comma separated, from: `L,R,C,LFE,Ls,Rs,X`)
        public var outputChannels: String? {
            get { element.fcpOutputChannels }
            set { element.fcpOutputChannels = newValue }
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
            get { element.fcpEnabled ?? true }
            set { element.fcpEnabled = newValue }
        }
        
        // Children
        
        /// Returns all child elements.
        public var contents: LazyCompactMapSequence<[XMLNode], XMLElement> {
            element.childElements
        }
        
        /// Returns child elements that are story elements.
        public var storyElements: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
            element.fcpStoryElements
        }
        
        // TODO: add missing attributes and protocols
        
        public init(element: XMLElement) {
            self.element = element
        }
    }
}

extension FinalCutPro.FCPXML.Audio {
    public static let clipType: FinalCutPro.FCPXML.ClipType = .audio
    
    public enum Attributes: String, XMLParsableAttributesKey {
        /// Required.
        /// Resource ID.
        case ref
        case role
        /// Source audio channels (comma separated, 1-based index, ie: "1, 2")
        case srcCh
        /// Output audio channels (comma separated, from: `L,R,C,LFE,Ls,Rs,X`)
        case outCh
        
        // Anchorable Attributes
        case lane
        case offset
        
        // Clip Attributes
        case name
        case start
        case duration
        case enabled
    }
    
    // contains story elements
}

extension XMLElement { // Audio
    /// Get or set the value of the `srcCh` attribute.
    /// Use on `audio` and `audio-channel-source` elements.
    public var fcpSourceChannels: String? {
        get { stringValue(forAttributeNamed: "srcCh") }
        set { addAttribute(withName: "srcCh", value: newValue) }
    }
    
    /// Get or set the value of the `outCh` attribute.
    /// Use on `audio` and `audio-channel-source` elements.
    public var fcpOutputChannels: String? {
        get { stringValue(forAttributeNamed: "outCh") }
        set { addAttribute(withName: "outCh", value: newValue) }
    }
}

#endif
