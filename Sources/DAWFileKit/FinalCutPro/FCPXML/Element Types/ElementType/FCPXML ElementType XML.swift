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
}

// MARK: - Children

extension XMLElement {
    /// FCPXML: Returns the first child element of the given element type.
    public func firstChildElement(
        whereFCPElementType elementType: FinalCutPro.FCPXML.ElementType
    ) -> XMLElement? {
        childElements.first(whereFCPElementType: elementType)
    }
}

#endif
