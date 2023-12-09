//
//  FCPXML Gap.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import OTCore

extension FinalCutPro.FCPXML {
    /// Gap element.
    ///
    /// > Final Cut Pro FCPXML 1.11 Reference:
    /// >
    /// > Defines a placeholder element that has no intrinsic audio or video data.
    public struct Gap: FCPXMLElement {
        public let element: XMLElement
        public let elementName: String = "gap"
        
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

extension FinalCutPro.FCPXML.Gap: FCPXMLElementClipAttributes {
    // A kludge since Gap uses 5 of the 6 clip attributes, except `lane`.
    public var lane: Int? {
        get { nil }
        set { assertionFailure("Can't set lane attribute on gap clip.") }
    }
}

extension FinalCutPro.FCPXML.Gap: FCPXMLElementMetadataChild { }

extension FinalCutPro.FCPXML.Gap: FCPXMLElementNoteChild { }

extension FinalCutPro.FCPXML.Gap {
    public static let clipType: FinalCutPro.FCPXML.ClipType = .gap
    
    public enum Attributes: String {
        // Anchorable Attributes
        // (no lane)
        case offset
        
        // Clip Attributes
        case name
        case start
        case duration
        case enabled
    }
    
    // can contain DTD anchor_item*
    // can contain markers
}

extension XMLElement { // Gap
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/Gap`` model object.
    /// Call this on a `gap` element only.
    public var fcpAsGap: FinalCutPro.FCPXML.Gap? {
        .init(element: self)
    }
}

#endif
