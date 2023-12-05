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
    public struct Gap: Equatable, Hashable {
        public let element: XMLElement
        
        // Anchorable Attributes
        
        // (no lane)
        
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

extension FinalCutPro.FCPXML.Gap {
    public static let clipType: FinalCutPro.FCPXML.ClipType = .gap
    
    public enum Attributes: String, XMLParsableAttributesKey {
        // Anchorable Attributes
        // (no lane)
        case offset
        
        // Clip Attributes
        case name
        case start
        case duration
        case enabled
    }
}

extension XMLElement { // Gap
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/Gap`` model object.
    /// Call this on a `gap` element only.
    public var fcpAsGap: FinalCutPro.FCPXML.Gap {
        .init(element: self)
    }
}

#endif
