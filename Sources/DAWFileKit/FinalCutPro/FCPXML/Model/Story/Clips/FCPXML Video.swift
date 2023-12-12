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
        
        public let elementType: ElementType = .video
        
        public static let supportedElementTypes: Set<ElementType> = [.video]
        
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

extension FinalCutPro.FCPXML.Video {
    public enum Attributes: String {
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

// MARK: - Attributes

extension FinalCutPro.FCPXML.Video {
    /// Resource ID. (Required)
    public var ref: String {
        get { element.fcpRef ?? "" }
        set { element.fcpRef = newValue }
    }
    
    /// Video role. (Default: Video)
    public var role: FinalCutPro.FCPXML.VideoRole? {
        get { element.fcpRole(as: FinalCutPro.FCPXML.VideoRole.self) }
        set { element.fcpSet(role: newValue) }
    }
}

extension FinalCutPro.FCPXML.Video: FCPXMLElementClipAttributes { }

// MARK: - Children

extension FinalCutPro.FCPXML.Video {
    /// Returns all child elements.
    public var contents: LazyCompactMapSequence<[XMLNode], XMLElement> {
        element.childElements
    }
    
    /// Returns child story elements.
    public var storyElements: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
        element.fcpStoryElements
    }
}

extension FinalCutPro.FCPXML.Video: FCPXMLElementNoteChild { }

// MARK: - Typing

// Video
extension XMLElement {
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/Video`` model object.
    /// Call this on a `video` element only.
    public var fcpAsVideo: FinalCutPro.FCPXML.Video? {
        .init(element: self)
    }
}

#endif
