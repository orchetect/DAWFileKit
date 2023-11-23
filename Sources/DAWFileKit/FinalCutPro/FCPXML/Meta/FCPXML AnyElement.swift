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
    public init?(
        from xmlLeaf: XMLElement,
        breadcrumbs: [XMLElement],
        resources: [String: FinalCutPro.FCPXML.AnyResource],
        contextBuilder: FCPXMLElementContextBuilder
    ) {
        if let storyElement = FinalCutPro.FCPXML.AnyStoryElement(
            from: xmlLeaf,
            breadcrumbs: breadcrumbs,
            resources: resources,
            contextBuilder: contextBuilder
        ) {
            self = .story(storyElement)
        } else if let structureElement = FinalCutPro.FCPXML.AnyStructureElement(
            from: xmlLeaf,
            breadcrumbs: breadcrumbs,
            resources: resources,
            contextBuilder: contextBuilder
        ) {
            self = .structure(structureElement)
        } else {
            return nil
        }
    }
    
    public var elementType: FinalCutPro.FCPXML.ElementType {
        wrapped.elementType
    }
    
    /// Redundant, but required to fulfill `FCPXMLElement` protocol requirements.
    public func asAnyElement() -> FinalCutPro.FCPXML.AnyElement {
        self
    }
}

extension FinalCutPro.FCPXML.AnyElement {
    /// Returns the unwrapped structure element typed as ``FCPXMLElement``.
    public var wrapped: any FCPXMLElement {
        switch self {
        case let .story(element): return element
        case let .structure(element): return element
        }
    }
}

extension FinalCutPro.FCPXML.AnyElement: FCPXMLElementContext {
    public var context: FinalCutPro.FCPXML.ElementContext {
        wrapped.context
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

extension FinalCutPro.FCPXML.AnyElement: FCPXMLExtractable {
    public func extractableElements() -> [FinalCutPro.FCPXML.AnyElement] {
        switch self {
        case let .story(story):
            return story.extractableElements()
        case let .structure(structure):
            return structure.extractableElements()
        }
    }
    
    public func extractableChildren() -> [FinalCutPro.FCPXML.AnyElement] {
        switch self {
        case let .story(story):
            return story.extractableChildren()
        case let .structure(structure):
            return structure.extractableChildren()
        }
    }
}

// MARK: - Filtering

extension Collection<FinalCutPro.FCPXML.AnyElement> {
    /// Convenience to filter the FCPXML element collection and return only story elements.
    public func storyElements() -> [FinalCutPro.FCPXML.AnyStoryElement] {
        reduce(into: []) { elements, element in
            if case let .story(element) = element { elements.append(element) }
        }
    }
    
    /// Convenience to filter the FCPXML element collection and return only structure elements.
    public func structureElements() -> [FinalCutPro.FCPXML.AnyStructureElement] {
        reduce(into: []) { elements, element in
            if case let .structure(element) = element { elements.append(element) }
        }
    }
}

// MARK: - FCPXML Parsing

extension FinalCutPro.FCPXML {
    static func elements(
        in xmlLeaf: XMLElement,
        breadcrumbs: [XMLElement],
        resources: [String: FinalCutPro.FCPXML.AnyResource],
        contextBuilder: FCPXMLElementContextBuilder
    ) -> [AnyElement] {
        xmlLeaf
            .children?
            .lazy
            .compactMap { $0 as? XMLElement }
            .compactMap {
                AnyElement(
                    from: $0,
                    breadcrumbs: breadcrumbs + [xmlLeaf],
                    resources: resources,
                    contextBuilder: contextBuilder
                )
            }
            ?? []
    }
}

#endif
