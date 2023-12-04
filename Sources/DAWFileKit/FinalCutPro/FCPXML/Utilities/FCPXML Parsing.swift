//
//  FCPXML Parsing.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import OTCore

extension XMLElement {
    /// Returns the element type of the element.
    public var fcpElementType: FinalCutPro.FCPXML.ElementType? {
        FinalCutPro.FCPXML.ElementType(from: self)
    }
}

extension XMLElement {
    /// Returns child elements that are story elements.
    public var fcpStoryElements: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
        childElements
            .filter { $0.fcpStoryElementType != nil }
    }
    
    /// Returns the story element type of the element if the element is a story element.
    public var fcpStoryElementType: FinalCutPro.FCPXML.StoryElementType? {
        FinalCutPro.FCPXML.StoryElementType(from: self)
    }
}

extension XMLElement {
    public var fcpEvents: LazyFilteredCompactMapSequence<[XMLNode], XMLElement> {
        childElements
            .filter { $0.fcpElementType == .structure(.event) }
    }
}

#endif
