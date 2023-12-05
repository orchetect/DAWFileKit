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
    public struct Metadata: Equatable, Hashable {
        public let element: XMLElement
        
        // Children
        
        /// Returns all child elements.
        public var contents: LazyCompactMapSequence<[XMLNode], XMLElement> {
            element.childElements
        }
        
        // TODO: add strongly-typed enums/structs for metadata types
        
        public init(element: XMLElement) {
            self.element = element
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

#endif
