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
    public struct MCClip: Equatable, Hashable {
        public let element: XMLElement
        
        /// Required.
        /// Resource ID
        public var ref: String? {
            get { element.fcpRef }
            set { element.fcpRef = newValue }
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
        
        /// Returns child `mc-source` elements.
        public var sources: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
            element.fcpMulticamSources
        }
        
        public init(element: XMLElement) {
            self.element = element
        }
    }
}

extension FinalCutPro.FCPXML.MCClip {
    public static let clipType: FinalCutPro.FCPXML.ClipType = .mcClip
    
    public enum Attributes: String, XMLParsableAttributesKey {
        /// Required.
        /// Resource ID
        case ref
        
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
}

extension XMLElement { // MCClip
    /// Returns the element wrapped in a ``/FinalCutPro/FCPXML/MCClip`` model object.
    /// Call this on a `mc-clip` element only.
    public var asMCClip: FinalCutPro.FCPXML.MCClip {
        .init(element: self)
    }
}

#endif
