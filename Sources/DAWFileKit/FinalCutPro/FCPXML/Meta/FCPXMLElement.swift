//
//  FCPXMLElement.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

/// FCPXML elements.
public protocol FCPXMLElement {
    /// Returns the element type enum case.
    var elementType: FinalCutPro.FCPXML.ElementType { get }
    
    /// Returns the element as ``FinalCutPro/FCPXML/AnyElement``.
    func asAnyElement() -> FinalCutPro.FCPXML.AnyElement
}

#endif
