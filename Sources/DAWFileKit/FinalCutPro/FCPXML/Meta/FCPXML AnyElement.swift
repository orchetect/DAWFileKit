//
//  FCPXML AnyElement.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    /// Type-erased box containing a FCPXML element.
    public enum AnyElement {
        case story(AnyStoryElement)
        case structure(AnyStructureElement)
    }
}

extension FinalCutPro.FCPXML.AnyElement: FCPXMLElement {
    public var elementType: FinalCutPro.FCPXML.ElementType {
        switch self {
        case let .story(story): return story.elementType
        case let .structure(structure): return structure.elementType
        }
    }
    
    /// Redundant, but required to fulfill `FCPXMLElement` protocol requirements.
    public func asAnyElement() -> FinalCutPro.FCPXML.AnyElement {
        self
    }
}

// MARK: Proxy Properties

extension FinalCutPro.FCPXML.AnyElement {
    /// Convenience to return the name of the story element.
    /// Returns `nil` if attribute is not present or not applicable.
    public var name: String? {
        switch self {
        case let .story(story): return story.name
        case let .structure(structure): return structure.name
        }
    }
    
    /// Convenience to return the start of the story element.
    /// Returns `nil` if attribute is not present or not applicable.
    public var start: Timecode? {
        switch self {
        case let .story(story): return story.start
        case let .structure(structure): return structure.start
        }
    }
}

extension FinalCutPro.FCPXML.AnyElement: FCPXMLExtractableElement {
    public func extractableStart() -> Timecode? { nil }
    public func extractableName() -> String? { nil }
}

#endif
