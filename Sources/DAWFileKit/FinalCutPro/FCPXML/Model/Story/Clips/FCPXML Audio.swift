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

// MARK: - Parameterized init

extension FinalCutPro.FCPXML.Audio {
    public init(
        ref: String,
        role: FinalCutPro.FCPXML.AudioRole? = nil,
        srcID: String? = nil,
        sourceChannels: String? = nil,
        outputChannels: String? = nil,
        // Anchorable Attributes
        lane: Int? = nil,
        offset: Fraction? = nil,
        // Clip Attributes
        name: String? = nil,
        start: Fraction? = nil,
        duration: Fraction,
        enabled: Bool = true,
        // Note child
        note: String? = nil
    ) {
        self.init()
        
        self.ref = ref
        self.role = role
        self.srcID = srcID
        self.sourceChannels = sourceChannels
        self.outputChannels = outputChannels
        
        // Anchorable Attributes
        self.lane = lane
        self.offset = offset
        
        // Clip Attributes
        self.name = name
        self.start = start
        self.duration = duration
        self.enabled = enabled
        
        // Note child
        self.note = note
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
        nonmutating set { element.fcpRef = newValue }
    }
    
    public var role: FinalCutPro.FCPXML.AudioRole? {
        get { element.fcpRole(as: FinalCutPro.FCPXML.AudioRole.self) }
        nonmutating set { element.fcpSet(role: newValue) }
    }
    
    /// Source/track identifier in asset (if not '1').
    public var srcID: String? {
        get { element.stringValue(forAttributeNamed: Attributes.srcID.rawValue) }
        nonmutating set { element.addAttribute(withName: Attributes.srcID.rawValue, value: newValue) }
    }
    
    /// Source audio channels (comma separated, 1-based index, ie: "1, 2")
    public var sourceChannels: String? {
        get { element.fcpSourceChannels }
        nonmutating set { element.fcpSourceChannels = newValue }
    }
    
    /// Output audio channels (comma separated, from: `L, R, C, LFE, Ls, Rs, X`)
    public var outputChannels: String? {
        get { element.fcpOutputChannels }
        nonmutating set { element.fcpOutputChannels = newValue }
    }
}

extension FinalCutPro.FCPXML.Audio: FCPXMLElementClipAttributes { }

// MARK: - Children

extension FinalCutPro.FCPXML.Audio {
    /// Get or set child elements.
    public var contents: LazyCompactMapSequence<[XMLNode], XMLElement> {
        get { element.childElements }
        nonmutating set {
            element.removeAllChildren()
            element.addChildren(newValue)
        }
    }
    
    /// Returns child story elements.
    public var storyElements: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
        element.fcpStoryElements
    }
}

extension FinalCutPro.FCPXML.Audio: FCPXMLElementNoteChild { }

extension FinalCutPro.FCPXML.Audio: FCPXMLElementTimingParams { }

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
