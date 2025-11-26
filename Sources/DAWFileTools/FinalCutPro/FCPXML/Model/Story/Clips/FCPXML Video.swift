//
//  FCPXML Video.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKitCore
import SwiftExtensions

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

// MARK: - Parameterized init

extension FinalCutPro.FCPXML.Video {
    public init(
        ref: String,
        role: FinalCutPro.FCPXML.VideoRole? = nil,
        srcID: String? = nil,
        // Anchorable Attributes
        lane: Int? = nil,
        offset: Fraction? = nil,
        // Clip Attributes
        name: String? = nil,
        start: Fraction? = nil,
        duration: Fraction,
        enabled: Bool = true,
        // Note child
        note: String? = nil
    ) {
        self.init()
        
        self.ref = ref
        self.role = role
        self.srcID = srcID
        
        // Anchorable Attributes
        self.lane = lane
        self.offset = offset
        
        // Clip Attributes
        self.name = name
        self.start = start
        self.duration = duration
        self.enabled = enabled
        
        // Note child
        self.note = note
    }
}

// MARK: - Structure

extension FinalCutPro.FCPXML.Video {
    public enum Attributes: String {
        /// Required.
        /// Resource ID.
        case ref
        case role
        /// Source/track identifier in asset (if not '1').
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
        nonmutating set { element.fcpRef = newValue }
    }
    
    /// Video role. (Default: Video)
    public var role: FinalCutPro.FCPXML.VideoRole? {
        get { element.fcpRole(as: FinalCutPro.FCPXML.VideoRole.self) }
        nonmutating set { element.fcpSet(role: newValue) }
    }
    
    /// Source/track identifier in asset (if not '1').
    public var srcID: String? {
        get { element.stringValue(forAttributeNamed: Attributes.srcID.rawValue) }
        nonmutating set { element.addAttribute(withName: Attributes.srcID.rawValue, value: newValue) }
    }
}

extension FinalCutPro.FCPXML.Video: FCPXMLElementClipAttributes { }

// MARK: - Children

extension FinalCutPro.FCPXML.Video {
    /// Get or set child elements.
    public var contents: LazyCompactMapSequence<[XMLNode], XMLElement> {
        get { element.childElements }
        nonmutating set {
            element.removeAllChildren()
            element.addChildren(newValue)
        }
    }
    
    /// Returns child story elements.
    public var storyElements: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
        element.fcpStoryElements
    }
}

extension FinalCutPro.FCPXML.Video: FCPXMLElementNoteChild { }

extension FinalCutPro.FCPXML.Video: FCPXMLElementTimingParams { }

// MARK: - Meta Conformances

extension FinalCutPro.FCPXML.Video: FCPXMLElementMetaTimeline {
    public func asAnyTimeline() -> FinalCutPro.FCPXML.AnyTimeline { .video(self) }
}

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
