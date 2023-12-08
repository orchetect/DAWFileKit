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
    var metadata: XMLElement? { get set }
}

extension FCPXMLElementMetadataChild {
    public var metadata: XMLElement? {
        get {
            element.firstChildElement(named: "metadata")
        }
        set {
            if let existingElement = element.firstChildElement(named: "metadata") {
                existingElement.detach()
            }
            if let newValue = newValue {
                element.addChild(newValue)
            }
        }
    }
}

#endif
