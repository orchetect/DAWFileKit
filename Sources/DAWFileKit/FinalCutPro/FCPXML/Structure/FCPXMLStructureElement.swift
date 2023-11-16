//
//  FCPXMLStructureElement.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

/// FCPXML structural elements.
public protocol FCPXMLStructureElement {
    /// Returns the structure element type enum case.
    var structureElementType: FinalCutPro.FCPXML.StructureElementType { get }
}

#endif
