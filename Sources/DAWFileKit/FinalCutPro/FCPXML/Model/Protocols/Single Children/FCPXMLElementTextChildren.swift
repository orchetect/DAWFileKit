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
    var texts: LazyMapSequence<
        LazyFilterSequence<LazyMapSequence<
            LazyFilterSequence<LazyCompactMapSequence<[XMLNode], XMLElement>>.Elements,
            FinalCutPro.FCPXML.Text?
        >>,
        FinalCutPro.FCPXML.Text
    > { get }
}

extension FCPXMLElementTextChildren {
    public var texts: LazyMapSequence<
        LazyFilterSequence<LazyMapSequence<
            LazyFilterSequence<LazyCompactMapSequence<[XMLNode], XMLElement>>.Elements,
            FinalCutPro.FCPXML.Text?
        >>,
        FinalCutPro.FCPXML.Text
    > {
        element.fcpTexts()
    }
}

extension XMLElement {
    /// FCPXML: Returns child `text` elements.
    public func fcpTexts() -> LazyMapSequence<
        LazyFilterSequence<LazyMapSequence<
            LazyFilterSequence<LazyCompactMapSequence<[XMLNode], XMLElement>>.Elements,
            FinalCutPro.FCPXML.Text?
        >>,
        FinalCutPro.FCPXML.Text
    > {
        childElements
            .filter(whereElementNamed: "text")
            .compactMap(\.fcpAsText)
    }
}
#endif
