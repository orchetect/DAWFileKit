//
//  FCPXML Spine.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import OTCore

extension FinalCutPro.FCPXML {
    /// Contains elements ordered sequentially in time.
    public struct Spine: Equatable, Hashable {
        public let element: XMLElement
        
        public var name: String? {
            get { element.fcpName }
            set { element.fcpName = newValue }
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
        
        // Children
        
        /// Returns all child elements.
        public var contents: LazyCompactMapSequence<[XMLNode], XMLElement> {
            element.childElements
        }
        
        /// Returns child story elements.
        public var storyElements: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
            element.fcpStoryElements
        }
        
        public init(element: XMLElement) {
            self.element = element
        }
    }
}

extension FinalCutPro.FCPXML.Spine {
    public static let storyElementType: FinalCutPro.FCPXML.StoryElementType = .spine
    
    public enum Attributes: String, XMLParsableAttributesKey {
        case name
        
        // Anchorable Attributes
        case lane
        case offset
    }
    
    // contains story elements
}

extension XMLElement { // Spine
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/Spine`` model object.
    /// Call this on a `spine` element only.
    public var fcpAsSpine: FinalCutPro.FCPXML.Spine {
        .init(element: self)
    }
}

#endif
