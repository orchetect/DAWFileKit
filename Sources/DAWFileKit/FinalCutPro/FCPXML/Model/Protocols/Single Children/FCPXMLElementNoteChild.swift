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
    var note: String? { get set }
}

extension FCPXMLElementNoteChild {
    public var note: String? {
        get {
            element.firstChildElement(named: "note")?.stringValue
        }
        set {
            element._updateChildElement(named: "note", newStringValue: newValue)
        }
    }
}

#endif
