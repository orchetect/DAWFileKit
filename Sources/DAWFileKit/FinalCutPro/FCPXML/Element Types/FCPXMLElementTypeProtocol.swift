//
//  FCPXMLElementTypeProtocol.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

/// FCPXML elements.
public protocol FCPXMLElementTypeProtocol where
Self: Equatable, Self: Hashable,
Self: RawRepresentable, RawValue == String
{
    /// Returns the element type enum case.
    var elementType: FinalCutPro.FCPXML.ElementType { get }
}

extension FCPXMLElementTypeProtocol {
    /// Initialize from an XML element.
    public init?(from xmlLeaf: XMLElement) {
        guard let name = xmlLeaf.name else { return nil }
        self.init(rawValue: name)
    }
}

#endif
