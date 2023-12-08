//
//  FCPXML Metadata.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import OTCore

extension FinalCutPro.FCPXML {
    /// Metadata container.
    public struct Metadata: FCPXMLElement, Equatable, Hashable {
        public let element: XMLElement
        public let elementName: String = "metadata"
        
        // Children
        
        /// Returns all child elements.
        public var contents: LazyCompactMapSequence<[XMLNode], XMLElement> {
            element.childElements
        }
        
        // TODO: add strongly-typed enums/structs for metadata types
        
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

extension FinalCutPro.FCPXML.Metadata {
    /// Wraps children in a `metadata` container element.
    public init(from children: [XMLElement]) {
        let container = (try? XMLElement(xmlString: "<metadata></metadata>")) ?? XMLElement()
        
        children.forEach {
            container.addChild($0)
        }
        
        element = container
    }
}

extension XMLElement { // Metadata
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/Metadata`` model object.
    /// Call this on a `metadata` element only.
    public var fcpAsMetadata: FinalCutPro.FCPXML.Metadata? {
        .init(element: self)
    }
}

#endif
