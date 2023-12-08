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
    public struct Video: FCPXMLElement {
        public let element: XMLElement
        public let elementName: String = "video"
        
        // Element-Specific Attributes
        
        /// Resource ID. (Required)
        public var ref: String {
            get { element.fcpRef ?? "" }
            set { element.fcpRef = newValue }
        }
        
        /// Video role. (Default: Video)
        public var role: VideoRole? {
            get { element.fcpVideoRole }
            set { element.fcpVideoRole = newValue }
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

extension FinalCutPro.FCPXML.Video: FCPXMLElementClipAttributes { }

extension FinalCutPro.FCPXML.Video: FCPXMLElementNoteChild { }

extension FinalCutPro.FCPXML.Video {
    public static let clipType: FinalCutPro.FCPXML.ClipType = .video
    
    public enum Attributes: String, XMLParsableAttributesKey {
        /// Required.
        /// Resource ID.
        case ref
        case role
        case srcID
        
        // Anchorable Attributes
        case lane
        case offset
        
        // Clip Attributes
        case name
        case start
        case duration
        case enabled
    }
    
    // can contain DTD param*
    // contains DTD %timing-params
    // contains DTD %intrinsic-params-video
    // can contain DTD %anchor_item*
    // can contain markers
    // can contain DTD %video_filter_item*
    // con contain one or zero DTD reserved?
}

extension XMLElement { // Video
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/Video`` model object.
    /// Call this on a `video` element only.
    public var fcpAsVideo: FinalCutPro.FCPXML.Video? {
        .init(element: self)
    }
}

#endif
