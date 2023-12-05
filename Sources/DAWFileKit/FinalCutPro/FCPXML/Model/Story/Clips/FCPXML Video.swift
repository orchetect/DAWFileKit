//
//  FCPXML Video.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import OTCore

extension FinalCutPro.FCPXML {
    /// Video element.
    ///
    /// > Final Cut Pro FCPXML 1.11 Reference:
    /// >
    /// > References video data from an `asset` or `effect` element.
    public struct Video: Equatable, Hashable {
        public let element: XMLElement
        
        /// Required.
        /// Resource ID.
        public var ref: String {
            get { element.fcpRef ?? "" }
            set { element.fcpRef = newValue }
        }
        
        public var role: VideoRole? {
            get { element.fcpVideoRole }
            set { element.fcpVideoRole = newValue }
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
            get { element.fcpGetEnabled(default: true) }
            set { element.fcpSet(enabled: newValue, default: true) }
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
        
        public init(element: XMLElement) {
            self.element = element
        }
    }
}

extension FinalCutPro.FCPXML.Video {
    public static let clipType: FinalCutPro.FCPXML.ClipType = .video
    
    public enum Attributes: String, XMLParsableAttributesKey {
        /// Required.
        /// Resource ID.
        case ref
        case role
        
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

extension XMLElement { // Video
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/Video`` model object.
    /// Call this on a `video` element only.
    public var fcpAsVideo: FinalCutPro.FCPXML.Video {
        .init(element: self)
    }
}

#endif
