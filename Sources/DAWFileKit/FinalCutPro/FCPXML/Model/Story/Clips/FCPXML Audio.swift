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
    public struct Audio: FCPXMLElement {
        public let element: XMLElement
        
        public let elementType: ElementType = .audio
        
        public static let supportedElementTypes: Set<ElementType> = [.audio]
        
        public init() {
            element = XMLElement(name: elementType.rawValue)
        }
        
        public init?(element: XMLElement) {
            self.element = element
            guard _isElementTypeSupported(element: element) else { return nil }
        }
    }
}

// MARK: - Structure

extension FinalCutPro.FCPXML.Audio {
    public enum Attributes: String {
        /// Required.
        /// Resource ID.
        case ref
        case role
        /// Source/track identifier in asset (if not '1').
        case srcID
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
    
    // contains DTD %timing-params
    // contains DTD adjust-volume?
    // contains DTD %anchor_item*
    // contains markers
    // contains DTD filter-audio*
}

// MARK: - Attributes

extension FinalCutPro.FCPXML.Audio {
    /// Required.
    /// Resource ID
    public var ref: String {
        get { element.fcpRef ?? "" }
        set { element.fcpRef = newValue }
    }
    
    public var role: FinalCutPro.FCPXML.AudioRole? {
        get { element.fcpAudioRole }
        set { element.fcpAudioRole = newValue }
    }
    
    /// Source/track identifier in asset (if not '1').
    public var srcID: String? {
        get { element.stringValue(forAttributeNamed: Attributes.srcID.rawValue) }
        set { element.addAttribute(withName: Attributes.srcID.rawValue, value: newValue) }
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
}

extension FinalCutPro.FCPXML.Audio: FCPXMLElementClipAttributes { }

// MARK: - Children

extension FinalCutPro.FCPXML.Audio {
    /// Returns all child elements.
    public var contents: LazyCompactMapSequence<[XMLNode], XMLElement> {
        element.childElements
    }
    
    /// Returns child story elements.
    public var storyElements: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
        element.fcpStoryElements
    }
}

extension FinalCutPro.FCPXML.Audio: FCPXMLElementNoteChild { }

// MARK: - Properties

// Audio
extension XMLElement {
    /// FCPXML: Get or set the value of the `srcCh` attribute.
    /// Use on `audio` and `audio-channel-source` elements.
    public var fcpSourceChannels: String? {
        get { stringValue(forAttributeNamed: "srcCh") }
        set { addAttribute(withName: "srcCh", value: newValue) }
    }
    
    /// FCPXML: Get or set the value of the `outCh` attribute.
    /// Use on `audio` and `audio-channel-source` elements.
    public var fcpOutputChannels: String? {
        get { stringValue(forAttributeNamed: "outCh") }
        set { addAttribute(withName: "outCh", value: newValue) }
    }
}

// MARK: - Typing

// Audio
extension XMLElement {
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/Audio`` model object.
    /// Call this on a `audio` element only.
    public var fcpAsAudio: FinalCutPro.FCPXML.Audio? {
        .init(element: self)
    }
}

#endif
