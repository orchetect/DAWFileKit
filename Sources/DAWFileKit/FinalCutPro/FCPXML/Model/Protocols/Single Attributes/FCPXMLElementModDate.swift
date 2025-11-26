//
//  FCPXMLElementModDate.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKitCore

public protocol FCPXMLElementOptionalModDate: FCPXMLElement {
    /// Modification date.
    var modDate: String? { get nonmutating set }
}

extension FCPXMLElementOptionalModDate {
    public var modDate: String? {
        get { element.stringValue(forAttributeNamed: "modDate") }
        nonmutating set { element.addAttribute(withName: "modDate", value: newValue) }
    }
}

#endif
