//
//  FCPXML Clip.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import OTCore

extension FinalCutPro.FCPXML {
    /// Represents a basic unit of editing.
    ///
    /// > Final Cut Pro FCPXML 1.11 Reference:
    /// >
    /// > Use a `clip` element to describe a timeline sequence created from a source media file. A
    /// > `clip` contains video and/or audio elements, each of which represents a media component
    /// > (usually a track) in media. Specify the timing of the edit through the
    /// > [Timing Attributes](
    /// > https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/story_elements/clip
    /// > ).
    /// >
    /// > You can also use a `clip` element as an immediate child element of an event element to
    /// > represent a browser clip. In this case, use the [Timeline Attributes](
    /// > https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/story_elements/clip
    /// > ) to specify its format, etc.
    public struct Clip: FCPXMLElement {
        public let element: XMLElement
        
        public let elementType: ElementType = .clip
        
        public static let supportedElementTypes: Set<ElementType> = [.clip]
        
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

extension FinalCutPro.FCPXML.Clip {
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

extension FinalCutPro.FCPXML.Clip {
    public enum Attributes: String {
        // Element-Specific Attributes
        case format
        case tcStart
        case tcFormat
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
        
        // Mod Date
        case modDate
    }
    
    // contains DTD %timing-params
    // contains DTD %intrinsic-params
    // contains spines, clips, captions
    // contains markers
    // contains DTD %video_filter_item*
    // contains DTD filter-audio*
}

// MARK: - Attributes

extension FinalCutPro.FCPXML.Clip: FCPXMLElementClipAttributes { }

extension FinalCutPro.FCPXML.Clip {
    public var format: String? { // DTD: default is same as parent
        get { element.fcpFormat }
        set { element.fcpFormat = newValue }
    }
}

extension FinalCutPro.FCPXML.Clip: FCPXMLElementOptionalTCStart { }

extension FinalCutPro.FCPXML.Clip: FCPXMLElementOptionalTCFormat { }

extension FinalCutPro.FCPXML.Clip /* : FCPXMLElementAudioStartAndDuration */ {
    public var audioStart: Fraction? {
        get { element.fcpAudioStart }
        set { element.fcpAudioStart = newValue }
    }
    
    public var audioDuration: Fraction? {
        get { element.fcpAudioDuration }
        set { element.fcpAudioDuration = newValue }
    }
}

extension FinalCutPro.FCPXML.Clip: FCPXMLElementOptionalModDate { }

// MARK: - Children

extension FinalCutPro.FCPXML.Clip {
    /// Returns all child elements.
    public var contents: LazyCompactMapSequence<[XMLNode], XMLElement> {
        element.childElements
    }
    
    /// Returns child story elements.
    public var storyElements: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
        element.fcpStoryElements
    }
}

extension FinalCutPro.FCPXML.Clip: FCPXMLElementNoteChild { }

extension FinalCutPro.FCPXML.Clip: FCPXMLElementMetadataChild { }

extension FinalCutPro.FCPXML.Clip: FCPXMLElementAudioChannelSourceChildren { }

// MARK: - Typing

// Clip
extension XMLElement {
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/Clip`` model object.
    /// Call this on a `clip` element only.
    public var fcpAsClip: FinalCutPro.FCPXML.Clip? {
        .init(element: self)
    }
}

#endif
