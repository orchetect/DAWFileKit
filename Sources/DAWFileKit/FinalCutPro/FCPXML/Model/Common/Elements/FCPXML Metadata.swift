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
        
        public let elementType: ElementType = .metadata
        
        public static let supportedElementTypes: Set<ElementType> = [.metadata]
        
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

extension FinalCutPro.FCPXML.Metadata {
    // TODO: add init after adding properties
}

// MARK: Custom inits

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

// MARK: - Structure

extension FinalCutPro.FCPXML.Metadata {
    // no attributes
    
    // contains key/value children
}

// MARK: - Children

extension FinalCutPro.FCPXML.Metadata {
    // TODO: add strongly-typed enums/structs for metadata types
    
    /// Returns all child elements.
    public var contents: LazyCompactMapSequence<[XMLNode], XMLElement> {
        element.childElements
    }
}

// MARK: - Typing

// Metadata
extension XMLElement {
    /// FCPXML: Returns the element wrapped in a ``FinalCutPro/FCPXML/Metadata`` model object.
    /// Call this on a `metadata` element only.
    public var fcpAsMetadata: FinalCutPro.FCPXML.Metadata? {
        .init(element: self)
    }
}

#endif
