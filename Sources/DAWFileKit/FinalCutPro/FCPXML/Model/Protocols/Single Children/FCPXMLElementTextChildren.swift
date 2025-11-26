//
//  FCPXMLElementTextChildren.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import SwiftExtensions
import TimecodeKit

public protocol FCPXMLElementTextChildren: FCPXMLElement {
    /// Child `text` elements.
    var texts: LazyFCPXMLChildrenSequence<FinalCutPro.FCPXML.Text> { get nonmutating set }
}

extension FCPXMLElementTextChildren {
    public var texts: LazyFCPXMLChildrenSequence<FinalCutPro.FCPXML.Text> {
        get { element.fcpTexts }
        nonmutating set { element.fcpTexts = newValue }
    }
}

extension XMLElement {
    /// FCPXML: Returns child `text` elements.
    public var fcpTexts: LazyFCPXMLChildrenSequence<FinalCutPro.FCPXML.Text> {
        get { children(whereFCPElement: .text) }
        set { _updateChildElements(ofType: .text, with: newValue) }
    }
}

#endif
