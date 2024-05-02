//
//  FCPXML ElementType XML.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import OTCore

// MARK: - Sequence First

extension Sequence where Element == XMLElement {
    /// FCPXML: Returns the first element with the given element type.
    public func first(
        whereFCPElementType elementType: FinalCutPro.FCPXML.ElementType
    ) -> Element? {
        first { $0.fcpElementType == elementType }
    }
    
    /// FCPXML: Returns the first element with any of the given element types.
    public func first(
        whereFCPElementTypes elementTypes: Set<FinalCutPro.FCPXML.ElementType>
    ) -> Element? {
        first {
            guard let elementType = $0.fcpElementType else { return false }
            return elementTypes.contains(elementType)
        }
    }
    
    /// FCPXML: Returns the first element that matches the given predicate.
    @_disfavoredOverload
    public func first(
        whereFCPElementType predicate: (_ elementType: FinalCutPro.FCPXML.ElementType) -> Bool
    ) -> Element? {
        first {
            guard let elementType = $0.fcpElementType else { return false }
            return predicate(elementType)
        }
    }
}

// MARK: - Sequence Filter

extension Sequence where Element == XMLElement {
    /// FCPXML: Returns the sequence filtered by the given element type.
    public func filter(
        whereFCPElementType elementType: FinalCutPro.FCPXML.ElementType
    ) -> LazyFilterSequence<Self> {
        self.lazy.filter(whereFCPElementType: elementType)
    }
    
    /// FCPXML: Returns the sequence filtered by the given element types.
    public func filter(
        whereFCPElementTypes elementTypes: Set<FinalCutPro.FCPXML.ElementType>
    ) -> LazyFilterSequence<Self> {
        self.lazy.filter(whereFCPElementTypes: elementTypes)
    }
    
    /// FCPXML: Returns the sequence filtered by the given predicate.
    @_disfavoredOverload
    public func filter(
        whereFCPElementType predicate: @escaping (_ elementType: FinalCutPro.FCPXML.ElementType) -> Bool,
        includeUnrecognizedElements: Bool
    ) -> LazyFilterSequence<Self> {
        self.lazy.filter(whereFCPElementType: predicate, includeUnrecognizedElements: includeUnrecognizedElements)
    }
}

// MARK: - LazySequence Filter

extension LazySequence where Element == XMLElement {
    /// FCPXML: Returns the sequence filtered by the given element type.
    public func filter(
        whereFCPElementType elementType: FinalCutPro.FCPXML.ElementType
    ) -> LazyFilterSequence<LazySequence<Base>.Elements> {
       filter { $0.fcpElementType == elementType }
    }
    
    /// FCPXML: Returns the sequence filtered by the given element types.
    public func filter(
        whereFCPElementTypes elementTypes: Set<FinalCutPro.FCPXML.ElementType>
    ) -> LazyFilterSequence<LazySequence<Base>.Elements> {
        filter {
            guard let elementType = $0.fcpElementType else { return false }
            return elementTypes.contains(elementType)
        }
    }
    
    /// FCPXML: Returns the sequence filtered by the given predicate.
    @_disfavoredOverload
    public func filter(
        whereFCPElementType predicate: @escaping (_ elementType: FinalCutPro.FCPXML.ElementType) -> Bool,
        includeUnrecognizedElements: Bool
    ) -> LazyFilterSequence<LazySequence<Base>.Elements> {
        filter {
            guard let elementType = $0.fcpElementType else { return includeUnrecognizedElements }
            return predicate(elementType)
        }
    }
}

// MARK: - Children

extension XMLElement {
    /// FCPXML: Returns the first child element of the given element type.
    public func firstChildElement(
        whereFCPElementType elementType: FinalCutPro.FCPXML.ElementType
    ) -> XMLElement? {
        childElements.first(whereFCPElementType: elementType)
    }
    
    /// FCPXML: Returns the first child element of the given element type.
    /// If no matching child is found, the default is added as a child and returned.
    ///
    /// - Warning: Ensure the `defaultChild` is a new instance not already attached to any parent.
    public func firstChildElement(
        whereFCPElementType elementType: FinalCutPro.FCPXML.ElementType,
        defaultChild: @autoclosure () -> XMLElement
    ) -> XMLElement {
        if let existingChild = childElements
            .first(whereFCPElementType: elementType)
        {
            return existingChild
        } else {
            let dc = defaultChild()
            addChild(dc)
            return dc
        }
    }
    
    /// FCPXML: Returns the first child element of the given element type.
    /// If no matching child is found, the default is added as a child and returned.
    ///
    /// - Warning: Ensure the `defaultChild` is a new instance not already attached to any parent.
    public func firstDefaultedChildElement(
        whereFCPElementType elementType: FinalCutPro.FCPXML.ElementType
    ) -> XMLElement {
        if let existingChild = childElements
            .first(whereFCPElementType: elementType)
        {
            return existingChild
        } else {
            let defaultChild = XMLElement(name: elementType.rawValue)
            addChild(defaultChild)
            return defaultChild
        }
    }
    
    /// FCPXML: Returns the first child element matching the given predicate.
    @_disfavoredOverload
    public func firstChildElement(
        whereFCPElementType predicate: (_ elementType: FinalCutPro.FCPXML.ElementType) -> Bool
    ) -> XMLElement? {
        childElements.first(whereFCPElementType: predicate)
    }
}

#endif
