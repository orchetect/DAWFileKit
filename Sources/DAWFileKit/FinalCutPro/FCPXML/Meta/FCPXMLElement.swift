//
//  FCPXMLElement.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

/// FCPXML elements.
public protocol FCPXMLElement where Self: Equatable, Self: FCPXMLElementContext {
    /// Returns the element type enum case.
    var elementType: FinalCutPro.FCPXML.ElementType { get }
    
    /// Returns the element as ``FinalCutPro/FCPXML/AnyElement``.
    func asAnyElement() -> FinalCutPro.FCPXML.AnyElement
    
    init?(
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    )
}

// MARK: - Equatable

extension FCPXMLElement {
    func isEqual(to other: some FCPXMLElement) -> Bool {
        self.asAnyElement() == other.asAnyElement()
    }
}

// MARK: - Collection Methods

extension Collection<FinalCutPro.FCPXML.AnyElement> {
    public func contains(_ element: any FCPXMLElement) -> Bool {
        contains(where: { $0.wrapped.isEqual(to: element) })
    }
}

extension Dictionary where Value == FinalCutPro.FCPXML.AnyElement {
    public func contains(value element: any FCPXMLElement) -> Bool {
        values.contains(element)
    }
}

extension Collection where Element: FCPXMLElement {
    public func contains(_ element: FinalCutPro.FCPXML.AnyElement) -> Bool {
        contains(where: { $0.asAnyElement() == element })
    }
}

extension Dictionary where Value: FCPXMLElement {
    public func contains(value element: FinalCutPro.FCPXML.AnyElement) -> Bool {
        values.contains(where: { $0.asAnyElement() == element })
    }
}

#endif
