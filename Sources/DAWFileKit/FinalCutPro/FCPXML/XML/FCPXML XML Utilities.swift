//
//  FCPXML XML Utilities.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import OTCore

// MARK: - Rational Time Value Utils

extension Sequence where Element == XMLElement {
    /// FCPXML: Returns the sequence filtered by the given element type.
    public func filter(
        whereFCPElementType elementType: FinalCutPro.FCPXML.ElementType
    ) -> LazyFilterSequence<Self> {
        self.lazy.filter(whereFCPElementType: elementType)
    }
    
    /// FCPXML: Returns the sequence filtered by the given element type.
    public func first(
        whereFCPElementType elementType: FinalCutPro.FCPXML.ElementType
    ) -> Element? {
        first { $0.fcpElementType == elementType }
    }
}

extension LazySequence where Element == XMLElement {
    /// FCPXML: Returns the sequence filtered by the given element type.
    public func filter(
        whereFCPElementType elementType: FinalCutPro.FCPXML.ElementType
    ) -> LazyFilterSequence<LazySequence<Base>.Elements> {
       filter { $0.fcpElementType == elementType }
    }
}

#endif
