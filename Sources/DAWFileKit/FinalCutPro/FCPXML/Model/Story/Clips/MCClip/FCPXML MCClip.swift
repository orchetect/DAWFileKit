//
//  FCPXML MCClip.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import OTCore

extension FinalCutPro.FCPXML {
    /// References a multicam media.
    ///
    /// > Final Cut Pro FCPXML 1.11 Reference:
    /// >
    /// > Use an `mc-clip` element to describe a timeline sequence created from a multicam media. To
    /// > use multicam media as a clip, see [Using Multicam Media](
    /// > https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/story_elements/mc-clip
    /// > ). To specify the timing of the edit,
    /// > use the [Timing Attributes](
    /// > https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/story_elements/mc-clip
    /// > ).
    public struct MCClip: FCPXMLElement {
        public let element: XMLElement
        public let elementName: String = "mc-clip"
        
        // Element-Specific Attributes
        
        /// Resource ID. (Required)
        public var ref: String {
            get { element.fcpRef ?? "" }
            set { element.fcpRef = newValue }
        }
        
        /// Sources to enable for audio and video. (Default: `.all`)
        public var srcEnable: ClipSourceEnable {
            get { element.fcpClipSourceEnable }
            set { element.fcpClipSourceEnable = newValue }
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

extension FinalCutPro.FCPXML.MCClip: FCPXMLElementClipAttributes { }

extension FinalCutPro.FCPXML.MCClip /* : FCPXMLElementAudioStartAndDuration */ {
    public var audioStart: Fraction? {
        get { element.fcpAudioStart }
        set { element.fcpAudioStart = newValue }
    }
    
    public var audioDuration: Fraction? {
        get { element.fcpAudioDuration }
        set { element.fcpAudioDuration = newValue }
    }
}

extension FinalCutPro.FCPXML.MCClip: FCPXMLElementOptionalModDate { }

extension FinalCutPro.FCPXML.MCClip: FCPXMLElementNoteChild { }

extension FinalCutPro.FCPXML.MCClip: FCPXMLElementMetadataChild { }

extension FinalCutPro.FCPXML.MCClip /* FCPXMLElementMCSourceChildren */ {
    /// Returns child `mc-source` elements.
    public var sources: LazyMapSequence<
        LazyFilterSequence<LazyMapSequence<
            LazyFilterSequence<LazyCompactMapSequence<[XMLNode], XMLElement>>.Elements,
            FinalCutPro.FCPXML.MulticamSource?
        >>, FinalCutPro.FCPXML.MulticamSource
    > {
        element.fcpMulticamSources
    }
}

extension FinalCutPro.FCPXML.MCClip {
    public static let clipType: FinalCutPro.FCPXML.ClipType = .mcClip
    
    public enum Attributes: String {
        // Element-Specific Attributes
        case ref // required
        case audioStart
        case audioDuration
        case srcEnable // (all, audio, video) default: all
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
        case mcSource = "mc-source"
    }
    
    // contains DTD %timing-params
    // contains DTD %intrinsic-params-audio
    // can contain markers
    // can contain filter-audio
}

extension FinalCutPro.FCPXML.MCClip {
    /// Locates the `media` resource used by the `mc-clip`, and returns the `multicam` element from
    /// within it.
    public var multicamResource: FinalCutPro.FCPXML.Media.Multicam? {
        element.fcpResource()?.fcpAsMedia?.multicam
    }
    /// Returns audio and video `mc-angle` elements from the `media` resource's `multicam` element
    /// that correspond to the angles used by the `mc-clip`'s `mc-source` children.
    ///
    /// These angles may be different, or may be the same, depending on if separate audio and video
    /// sources were selected in the `mc-source` element(s).
    public var audioVideoMCAngles: (
        audioMCAngle: FinalCutPro.FCPXML.Media.Multicam.Angle?,
        videoMCAngle: FinalCutPro.FCPXML.Media.Multicam.Angle?
    ) {
        let (audio, video) = multicamResource?.audioVideoMCAngles(forMulticamSources: sources)
            ?? (nil, nil)
        
        return (audio, video)
    }
}

extension XMLElement { // MCClip
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/MCClip`` model object.
    /// Call this on a `mc-clip` element only.
    public var fcpAsMCClip: FinalCutPro.FCPXML.MCClip? {
        .init(element: self)
    }
}

#endif
