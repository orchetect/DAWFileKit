//
//  FCPXMLElementTextChildren.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import OTCore
import TimecodeKit

public protocol FCPXMLElementTextChildren: FCPXMLElement {
    /// Child `text` elements.
    var texts: LazyFCPXMLChildrenSequence<FinalCutPro.FCPXML.Text> { get }
}

extension FCPXMLElementTextChildren {
    // TODO: add set support, not just read-only
    public var texts: LazyFCPXMLChildrenSequence<FinalCutPro.FCPXML.Text> {
        element.fcpTexts()
    }
}

extension XMLElement {
    /// FCPXML: Returns child `text` elements.
    public func fcpTexts() -> LazyFCPXMLChildrenSequence<FinalCutPro.FCPXML.Text> {
        children(whereFCPElement: .text)
    }
}
#endif
