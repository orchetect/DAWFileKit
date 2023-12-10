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
        
        public let elementType: ElementType = .refClip
        
        public static let supportedElementTypes: Set<ElementType> = [.refClip]
        
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

extension FinalCutPro.FCPXML.RefClip {
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
    
    // contains audio-role-source*
    // contains DTD %timing-params
    // contains DTD %intrinsic-params
    // can contain DTD %anchor_item*
    // can contain markers
    // can contain filter-audio
}

// MARK: - Attributes

extension FinalCutPro.FCPXML.RefClip {
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
    public var srcEnable: FinalCutPro.FCPXML.ClipSourceEnable {
        get { element.fcpClipSourceEnable }
        set { element.fcpClipSourceEnable = newValue }
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

// MARK: - Children

extension FinalCutPro.FCPXML.RefClip {
    /// Returns all child elements.
    public var contents: LazyCompactMapSequence<[XMLNode], XMLElement> {
        element.childElements
    }
    
    /// Returns child story elements.
    public var storyElements: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
        element.fcpStoryElements
    }
}

extension FinalCutPro.FCPXML.RefClip: FCPXMLElementAudioRoleSourceChildren { }

extension FinalCutPro.FCPXML.RefClip: FCPXMLElementNoteChild { }

extension FinalCutPro.FCPXML.RefClip: FCPXMLElementMetadataChild { }

// MARK: - Resource

extension FinalCutPro.FCPXML.RefClip {
    /// Returns the `media` resource element for `ref` resource ID.
    public var mediaResource: FinalCutPro.FCPXML.Media? {
        element.fcpResource(forID: ref)?.fcpAsMedia
    }
    
    /// Returns the `sequence` contained in the `media` resource.
    public var mediaSequence: FinalCutPro.FCPXML.Sequence? {
        mediaResource?.sequence
    }
}

// MARK: - Typing

// RefClip
extension XMLElement {
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/RefClip`` model object.
    /// Call this on a `ref-clip` element only.
    public var fcpAsRefClip: FinalCutPro.FCPXML.RefClip? {
        .init(element: self)
    }
}

#endif
