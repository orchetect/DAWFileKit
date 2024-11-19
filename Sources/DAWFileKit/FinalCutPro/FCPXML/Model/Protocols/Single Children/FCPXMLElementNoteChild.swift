//
//  FCPXMLElementNoteChild.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

public protocol FCPXMLElementNoteChild: FCPXMLElement {
    /// Optional note text.
    var note: String? { get nonmutating set }
}

extension FCPXMLElementNoteChild {
    public var note: String? {
        get {
            element
                .firstChildElement(whereFCPElementType: .note)?
                .stringValue
        }
        nonmutating set {
            element
                ._updateFirstChildElement(ofType: .note, newStringValue: newValue)
        }
    }
}

#endif
