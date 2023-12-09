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
        public let elementName: String = "clip"
        
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

extension FinalCutPro.FCPXML.Clip: FCPXMLElementNoteChild { }

extension FinalCutPro.FCPXML.Clip: FCPXMLElementMetadataChild { }

extension FinalCutPro.FCPXML.Clip: FCPXMLElementAudioChannelSourceChildren { }

extension FinalCutPro.FCPXML.Clip {
    public static let clipType: FinalCutPro.FCPXML.ClipType = .clip
    
    public enum Attributes: String {
        // Element-Specific Attributes
        case format
        case tcStart
        case tcFormat
        case audioStart
        case audioDuration
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
    
    // contains DTD %timing-params
    // contains DTD %intrinsic-params
    // contains spines, clips, captions
    // contains markers
    // contains DTD %video_filter_item*
    // contains DTD filter-audio*
}

extension XMLElement { // Clip
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/Clip`` model object.
    /// Call this on a `clip` element only.
    public var fcpAsClip: FinalCutPro.FCPXML.Clip? {
        .init(element: self)
    }
}

#endif
