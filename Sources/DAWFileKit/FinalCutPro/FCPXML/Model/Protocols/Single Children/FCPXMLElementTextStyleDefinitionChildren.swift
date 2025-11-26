//
//  FCPXMLElementTextStyleDefinitionChildren.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKitCore
import SwiftExtensions

public protocol FCPXMLElementTextStyleDefinitionChildren: FCPXMLElement {
    /// Child `text-style-def` elements.
    var fcpTextStyleDefinitions: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> { get nonmutating set }
}

extension FCPXMLElementTextStyleDefinitionChildren {
    public var fcpTextStyleDefinitions: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
        get { element.fcpTextStyleDefinitions }
        nonmutating set { element.fcpTextStyleDefinitions = newValue }
    }
}

extension XMLElement {
    // TODO: no model objects yet, so just return the bare XML
    
    /// FCPXML: Returns child `text-style-def` elements.
    public var fcpTextStyleDefinitions: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
        get {
            childElements
                .filter(whereFCPElementType: .textStyleDef)
        }
        set {
            _updateChildElements(ofType: .textStyleDef, with: newValue)
        }
    }
}
#endif
