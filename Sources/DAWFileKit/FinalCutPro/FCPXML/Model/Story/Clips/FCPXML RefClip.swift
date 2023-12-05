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
    public struct RefClip: Equatable, Hashable {
        public let element: XMLElement
        
        /// Required.
        /// Resource ID
        public var ref: String {
            get { element.fcpRef ?? "" }
            set { element.fcpRef = newValue }
        }
        
        public var useAudioSubroles: Bool { // only used by `ref-clip`
            get { element.getBool(forAttribute: Attributes.useAudioSubroles.rawValue) ?? false }
            set { element.set(bool: newValue, forAttribute: Attributes.useAudioSubroles.rawValue) }
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
            get { element.fcpEnabled ?? true }
            set { element.fcpEnabled = newValue }
        }
        
        // Resource
        
        /// Returns the `media` resource element for `ref` resource ID.
        public var mediaResource: XMLElement? {
            element.fcpResource(forID: ref)
        }
        
        /// Returns the `sequence` contained in the `media` resource.
        public var mediaSequence: XMLElement? {
            mediaResource?.fcpAsMedia.sequence
        }
        
        // Children
        
        /// Returns child `audio-role-source` elements.
        public var audioRoleSources: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
            element.fcpAudioRoleSources
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

extension FinalCutPro.FCPXML.RefClip {
    public static let clipType: FinalCutPro.FCPXML.ClipType = .refClip
    
    public enum Attributes: String, XMLParsableAttributesKey {
        /// Required.
        /// Resource ID
        case ref
        case role
        case useAudioSubroles // default false
        
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
        case audioRoleSource = "audio-role-source"
    }
}

extension XMLElement { // RefClip
    /// Returns child `audio-role-source` elements.
    /// Use on `ref-clip`, `sync-source`, or `mc-source` elements.
    public var fcpAudioRoleSources: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
        childElements
            .filter(whereElementNamed: FinalCutPro.FCPXML.RefClip.Children.audioRoleSource.rawValue)
    }
    
}
#endif
