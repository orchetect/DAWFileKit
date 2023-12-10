//
//  FCPXMLElementTextStyleDefinitionChildren.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import OTCore

public protocol FCPXMLElementTextStyleDefinitionChildren: FCPXMLElement {
    /// Child `text-style-def` elements.
    var fcpTextStyleDefinitions: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> { get }
}

extension FCPXMLElementTextStyleDefinitionChildren {
    public var fcpTextStyleDefinitions: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
        element.fcpTextStyleDefinitions()
    }
}

extension XMLElement {
    // TODO: no model objects yet, so just return the bare XML
    
    /// FCPXML: Returns child `text-style-def` elements.
    public func fcpTextStyleDefinitions() -> LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
        childElements
            .filter(whereFCPElementType: .textStyleDef)
    }
}
#endif
