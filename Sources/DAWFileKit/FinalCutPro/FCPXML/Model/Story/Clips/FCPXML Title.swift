//
//  FCPXML Title.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import OTCore

extension FinalCutPro.FCPXML {
    /// Title clip.
    ///
    /// This is a FCP meta type and video is generated.
    /// Its frame rate is inferred from the sequence.
    /// Therefore, "tcFormat" (NDF/DF) attribute is not stored in `title` XML itself.
    public struct Title: FCPXMLElement {
        public let element: XMLElement
        
        public let elementType: ElementType = .title
        
        public static let supportedElementTypes: Set<ElementType> = [.title]
        
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

extension FinalCutPro.FCPXML.Title {
    public init(
        ref: String,
        role: FinalCutPro.FCPXML.VideoRole? = nil,
        // Anchorable Attributes
        lane: Int? = nil,
        offset: Fraction? = nil,
        // Clip Attributes
        name: String? = nil,
        start: Fraction? = nil,
        duration: Fraction,
        enabled: Bool = true,
        // Note child
        note: String? = nil,
        // Metadata
        metadata: FinalCutPro.FCPXML.Metadata? = nil
    ) {
        self.init()
        
        self.ref = ref
        self.role = role
        
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
        
        // Metadata
        self.metadata = metadata
    }
}

// MARK: - Structure

extension FinalCutPro.FCPXML.Title {
    public enum Attributes: String {
        case ref // effect ID for a Motion template
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
    
    // can contain DTD param*
    // contains DTD %intrinsic-params-video
    // can contain DTD %anchor_item*
    // can contain markers
    // can contain DTD %video_filter_item*
}

// MARK: - Attributes

extension FinalCutPro.FCPXML.Title {
    /// Effect ID (resource ID) for a Motion template. (Required)
    public var ref: String {
        get { element.fcpRef ?? "" }
        set { element.fcpRef = newValue }
    }
    
    public var role: FinalCutPro.FCPXML.VideoRole? {
        get { element.fcpVideoRole }
        set { element.fcpVideoRole = newValue }
    }
}

extension FinalCutPro.FCPXML.Title: FCPXMLElementClipAttributes { }

// MARK: - Children

extension FinalCutPro.FCPXML.Title {
    // TODO: public var texts
    
    /// Returns all child elements.
    public var contents: LazyCompactMapSequence<[XMLNode], XMLElement> {
        element.childElements
    }
    
    /// Returns child story elements.
    public var storyElements: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
        element.fcpStoryElements
    }
}

extension FinalCutPro.FCPXML.Title: FCPXMLElementNoteChild { }

extension FinalCutPro.FCPXML.Title: FCPXMLElementMetadataChild { }

extension FinalCutPro.FCPXML.Title: FCPXMLElementTextChildren { }

extension FinalCutPro.FCPXML.Title: FCPXMLElementTextStyleDefinitionChildren { }

// MARK: - Typing

// Title
extension XMLElement {
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/Title`` model object.
    /// Call this on a `title` element only.
    public var fcpAsTitle: FinalCutPro.FCPXML.Title? {
        .init(element: self)
    }
}

#endif
