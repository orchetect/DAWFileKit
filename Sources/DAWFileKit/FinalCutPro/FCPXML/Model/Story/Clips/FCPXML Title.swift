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
        
        // Element-Specific Attributes
        
        /// Effect ID (resource ID) for a Motion template. (Required)
        public var ref: String {
            get { element.fcpRef ?? "" }
            set { element.fcpRef = newValue }
        }
        
        public var role: VideoRole? {
            get { element.fcpVideoRole }
            set { element.fcpVideoRole = newValue }
        }
        
        // Children
        
        // TODO: public var texts
        
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

extension FinalCutPro.FCPXML.Title: FCPXMLElementClipAttributes { }

extension FinalCutPro.FCPXML.Title: FCPXMLElementTextChildren { }

extension FinalCutPro.FCPXML.Title: FCPXMLElementTextStyleDefinitionChildren { }

extension FinalCutPro.FCPXML.Title: FCPXMLElementNoteChild { }

extension FinalCutPro.FCPXML.Title {
    public static let clipType: FinalCutPro.FCPXML.ClipType = .title
    
    public enum Attributes: String, XMLParsableAttributesKey {
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

extension XMLElement { // Title
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/Title`` model object.
    /// Call this on a `title` element only.
    public var fcpAsTitle: FinalCutPro.FCPXML.Title {
        .init(element: self)
    }
}

#endif
