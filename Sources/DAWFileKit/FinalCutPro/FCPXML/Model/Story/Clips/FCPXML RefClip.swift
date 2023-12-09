//
//  FCPXML RefClip.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import OTCore

extension FinalCutPro.FCPXML {
    /// References a compound clip media.
    ///
    /// > Final Cut Pro FCPXML 1.11 Reference:
    /// >
    /// > Use a `ref-clip` element to describe a timeline sequence created from a
    /// > [Compound Clip Media](
    /// > https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/story_elements/ref-clip
    /// > ).
    /// > The edit uses the entire set of media components in the compound clip media. Specify the
    /// > timing of the edit through the [Timing Attributes](
    /// > https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/story_elements/timing_attributes
    /// > ).
    /// >
    /// > You can also use a ref-clip element as an immediate child element of an event element to
    /// > represent a browser clip. In this case, use the [Timeline Attributes](
    /// > https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/story_elements/ref-clip
    /// > ) to specify its format and other attributes.
    public struct RefClip: FCPXMLElement {
        public let element: XMLElement
        public let elementName: String = "ref-clip"
        
        // Element-Specific Attributes
        
        /// Required.
        /// Resource ID
        public var ref: String {
            get { element.fcpRef ?? "" }
            set { element.fcpRef = newValue }
        }
        
        public var useAudioSubroles: Bool { // only used by `ref-clip`
            get { element.getBool(forAttribute: Attributes.useAudioSubroles.rawValue) ?? false }
            set {
                element._fcpSet(
                    bool: newValue,
                    forAttribute: Attributes.useAudioSubroles.rawValue,
                    defaultValue: false,
                    removeIfDefault: true
                )
            }
        }
        
        /// Sources to enable for audio and video. (Default: `.all`)
        public var srcEnable: ClipSourceEnable {
            get { element.fcpClipSourceEnable }
            set { element.fcpClipSourceEnable = newValue }
        }
        
        // Resource
        
        /// Returns the `media` resource element for `ref` resource ID.
        public var mediaResource: Media? {
            element.fcpResource(forID: ref)?.fcpAsMedia
        }
        
        /// Returns the `sequence` contained in the `media` resource.
        public var mediaSequence: Sequence? {
            mediaResource?.sequence
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

extension FinalCutPro.FCPXML.RefClip: FCPXMLElementClipAttributes { }

extension FinalCutPro.FCPXML.RefClip /* : FCPXMLElementAudioStartAndDuration */ {
    public var audioStart: Fraction? {
        get { element.fcpAudioStart }
        set { element.fcpAudioStart = newValue }
    }
    
    public var audioDuration: Fraction? {
        get { element.fcpAudioDuration }
        set { element.fcpAudioDuration = newValue }
    }
}

extension FinalCutPro.FCPXML.RefClip: FCPXMLElementOptionalModDate { }

extension FinalCutPro.FCPXML.RefClip: FCPXMLElementAudioRoleSourceChildren { }

extension FinalCutPro.FCPXML.RefClip: FCPXMLElementNoteChild { }

extension FinalCutPro.FCPXML.RefClip: FCPXMLElementMetadataChild { }

extension FinalCutPro.FCPXML.RefClip {
    public static let clipType: FinalCutPro.FCPXML.ClipType = .refClip
    
    public enum Attributes: String {
        /// Required.
        /// Resource ID
        case ref
        case role
        case srcEnable
        case audioStart
        case audioDuration
        case useAudioSubroles // default `0` (false)
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
        case audioRoleSource = "audio-role-source"
    }
    
    // contains DTD %timing-params
    // contains DTD %intrinsic-params
    // can contain DTD %anchor_item*
    // can contain markers
    // can contain filter-audio
}

extension XMLElement { // RefClip
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/RefClip`` model object.
    /// Call this on a `ref-clip` element only.
    public var fcpAsRefClip: FinalCutPro.FCPXML.RefClip? {
        .init(element: self)
    }
}

#endif
