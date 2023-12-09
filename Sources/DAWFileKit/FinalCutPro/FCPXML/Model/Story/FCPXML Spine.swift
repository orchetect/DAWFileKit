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
    public struct Spine: FCPXMLElement {
        public let element: XMLElement
        public let elementName: String = "spine"
        
        // Element-Specific Attributes
        
        public var name: String? {
            get { element.fcpName }
            set { element.fcpName = newValue }
        }
        
        public var format: String? {
            get { element.fcpFormat }
            set { element.fcpFormat = newValue }
        }
        
        // Children
        
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

extension FinalCutPro.FCPXML.Spine: FCPXMLElementAnchorableAttributes { }

extension FinalCutPro.FCPXML.Spine {
    public static let storyElementType: FinalCutPro.FCPXML.StoryElementType = .spine
    
    public enum Attributes: String {
        // Element-Specific Attributes
        case name
        case format
        
        // Anchorable Attributes
        case lane
        case offset
    }
    
    // contains clips
    // contains transitions
}

extension XMLElement { // Spine
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/Spine`` model object.
    /// Call this on a `spine` element only.
    public var fcpAsSpine: FinalCutPro.FCPXML.Spine? {
        .init(element: self)
    }
}

#endif
