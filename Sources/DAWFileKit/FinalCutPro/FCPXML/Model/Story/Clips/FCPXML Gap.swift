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
        
        public let elementType: ElementType = .gap
        
        public static let supportedElementTypes: Set<ElementType> = [.gap]
        
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

extension FinalCutPro.FCPXML.Gap {
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

// MARK: - Attributes

extension FinalCutPro.FCPXML.Gap: FCPXMLElementClipAttributes {
    // A kludge since Gap uses 5 of the 6 clip attributes, except `lane`.
    public var lane: Int? {
        get { nil }
        set { assertionFailure("Can't set lane attribute on gap clip.") }
    }
}

// MARK: - Children

extension FinalCutPro.FCPXML.Gap {
    /// Returns all child elements.
    public var contents: LazyCompactMapSequence<[XMLNode], XMLElement> {
        element.childElements
    }
    
    /// Returns child story elements.
    public var storyElements: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
        element.fcpStoryElements
    }
}

extension FinalCutPro.FCPXML.Gap: FCPXMLElementMetadataChild { }

extension FinalCutPro.FCPXML.Gap: FCPXMLElementNoteChild { }

// MARK: - Typing

// Gap
extension XMLElement {
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/Gap`` model object.
    /// Call this on a `gap` element only.
    public var fcpAsGap: FinalCutPro.FCPXML.Gap? {
        .init(element: self)
    }
}

#endif
