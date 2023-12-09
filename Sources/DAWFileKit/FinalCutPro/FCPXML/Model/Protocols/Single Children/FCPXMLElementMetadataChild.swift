//
//  FCPXMLElementMetadataChild.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

public protocol FCPXMLElementMetadataChild: FCPXMLElement {
    /// Metadata for the element.
    var metadata: FinalCutPro.FCPXML.Metadata? { get set }
}

extension FCPXMLElementMetadataChild {
    public var metadata: FinalCutPro.FCPXML.Metadata? {
        get {
            element
                .firstChildElement(named: "metadata")?
                .fcpAsMetadata
        }
        set {
            if let existingElement = element.firstChildElement(named: "metadata") {
                existingElement.detach()
            }
            if let newValue = newValue {
                element.addChild(newValue.element)
            }
        }
    }
}

#endif
