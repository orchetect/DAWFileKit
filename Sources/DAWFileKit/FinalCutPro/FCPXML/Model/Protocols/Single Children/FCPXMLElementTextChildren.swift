//
//  FCPXMLElementTextChildren.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import OTCore

public protocol FCPXMLElementTextChildren: FCPXMLElement {
    /// Child `text` elements.
    var texts: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> { get }
}

extension FCPXMLElementTextChildren {
    public var texts: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
        element.fcpTexts()
    }
}

extension XMLElement {
    /// FCPXML: Returns child `text` elements.
    public func fcpTexts() -> LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
        childElements
            .filter(whereElementNamed: "text")
    }
}
#endif
