//
//  FCPXMLStructureElement.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

/// FCPXML structural elements.
public protocol FCPXMLStructureElement: FCPXMLElement where Self: Equatable {
    /// Returns the structure element type enum case.
    var structureElementType: FinalCutPro.FCPXML.StructureElementType { get }
    
    /// Returns the element as ``FinalCutPro/FCPXML/AnyStructureElement``.
    func asAnyStructureElement() -> FinalCutPro.FCPXML.AnyStructureElement
    
    init?(
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource],
        contextBuilder: FCPXMLElementContextBuilder
    )
}

// MARK: - Sub-Protocol Implementations

extension FCPXMLStructureElement /* : FCPXMLElement */ {
    public var elementType: FinalCutPro.FCPXML.ElementType { .structure(structureElementType) }
}

// MARK: - Equatable

extension FCPXMLStructureElement {
    func isEqual(to other: some FCPXMLStructureElement) -> Bool {
        self.asAnyStructureElement() == other.asAnyStructureElement()
    }
}

// MARK: - Nested Type Erasure

extension FCPXMLStructureElement {
    public func asAnyElement() -> FinalCutPro.FCPXML.AnyElement {
        .structure(asAnyStructureElement())
    }
}

extension Collection where Element: FCPXMLStructureElement {
    public func asAnyElements() -> [FinalCutPro.FCPXML.AnyElement] {
        map { $0.asAnyElement() }
    }
}

extension Collection<FinalCutPro.FCPXML.AnyStructureElement> {
    public func asAnyElements() -> [FinalCutPro.FCPXML.AnyElement] {
        map { $0.asAnyElement() }
    }
}

// MARK: - Collection Methods

extension Collection<FinalCutPro.FCPXML.AnyStructureElement> {
    public func contains(_ structureElement: any FCPXMLStructureElement) -> Bool {
        contains(where: { $0.wrapped.isEqual(to: structureElement) })
    }
}

extension Dictionary where Value == FinalCutPro.FCPXML.AnyStructureElement {
    public func contains(value structureElement: any FCPXMLStructureElement) -> Bool {
        values.contains(structureElement)
    }
}

extension Collection where Element: FCPXMLStructureElement {
    public func contains(_ structureElement: FinalCutPro.FCPXML.AnyStructureElement) -> Bool {
        contains(where: { $0.asAnyStructureElement() == structureElement })
    }
}

extension Dictionary where Value: FCPXMLStructureElement {
    public func contains(value structureElement: FinalCutPro.FCPXML.AnyStructureElement) -> Bool {
        values.contains(where: { $0.asAnyStructureElement() == structureElement })
    }
}

#endif
