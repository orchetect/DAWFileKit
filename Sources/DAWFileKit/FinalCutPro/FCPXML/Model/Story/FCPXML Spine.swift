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
        
        public let elementType: ElementType = .spine
        
        public static let supportedElementTypes: Set<ElementType> = [.spine]
        
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

extension FinalCutPro.FCPXML.Spine {
    public init(
        name: String? = nil,
        format: String? = nil,
        // Anchorable Attributes
        lane: Int? = nil,
        offset: Fraction? = nil
    ) {
        self.init()
        
        self.name = name
        self.format = format
        
        // Anchorable Attributes
        self.lane = lane
        self.offset = offset
    }
}

// MARK: - Structure

extension FinalCutPro.FCPXML.Spine {
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

// MARK: - Attributes

extension FinalCutPro.FCPXML.Spine {
    public var name: String? {
        get { element.fcpName }
        nonmutating set { element.fcpName = newValue }
    }
    
    public var format: String? {
        get { element.fcpFormat }
        nonmutating set { element.fcpFormat = newValue }
    }
}

extension FinalCutPro.FCPXML.Spine: FCPXMLElementAnchorableAttributes { }

// MARK: - Children

extension FinalCutPro.FCPXML.Spine {
    /// Returns child story elements.
    public var storyElements: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
        element.fcpStoryElements
    }
    
    /// Get or set child elements.
    public var contents: LazyCompactMapSequence<[XMLNode], XMLElement> {
        get { element.childElements }
        nonmutating set {
            element.removeAllChildren()
            element.addChildren(newValue)
        }
    }
}

// MARK: - Meta Conformances

extension FinalCutPro.FCPXML.Spine: FCPXMLElementMetaTimeline { 
    public func asAnyTimeline() -> FinalCutPro.FCPXML.AnyTimeline { .spine(self) }
}

// MARK: - Typing

// Spine
extension XMLElement {
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/Spine`` model object.
    /// Call this on a `spine` element only.
    public var fcpAsSpine: FinalCutPro.FCPXML.Spine? {
        .init(element: self)
    }
}

#endif
