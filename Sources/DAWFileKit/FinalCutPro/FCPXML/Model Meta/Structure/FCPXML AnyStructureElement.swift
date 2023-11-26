//
//  FCPXML AnyStructureElement.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    /// Type-erased box containing a specialized structure element instance.
    public enum AnyStructureElement {
        case library(Library)
        case event(Event)
        case project(Project)
    }
}

extension FinalCutPro.FCPXML.AnyStructureElement: FCPXMLStructureElement {
    public init?(
        from xmlLeaf: XMLElement,
        breadcrumbs: [XMLElement],
        resources: [String: FinalCutPro.FCPXML.AnyResource],
        contextBuilder: FCPXMLElementContextBuilder
    ) {
        guard let name = xmlLeaf.name else { return nil }
        
        guard let structureElementType = FinalCutPro.FCPXML.StructureElementType(rawValue: name)
        else { return nil }
        
        switch structureElementType {
        case .library:
            guard let library = FinalCutPro.FCPXML.Library(
                from: xmlLeaf,
                breadcrumbs: breadcrumbs,
                resources: resources,
                contextBuilder: contextBuilder
            )
            else { return nil }
            
            self = .library(library)
            
        case .event:
            guard let event = FinalCutPro.FCPXML.Event(
                from: xmlLeaf,
                breadcrumbs: breadcrumbs,
                resources: resources,
                contextBuilder: contextBuilder
            )
            else { return nil }
            
            self = .event(event)
            
        case .project:
            guard let project = FinalCutPro.FCPXML.Project(
                from: xmlLeaf,
                breadcrumbs: breadcrumbs,
                resources: resources,
                contextBuilder: contextBuilder
            )
            else { return nil }
            
            self = .project(project)
        }
    }
    
    public var structureElementType: FinalCutPro.FCPXML.StructureElementType {
        switch self {
        case let .library(library): return library.structureElementType
        case let .event(event): return event.structureElementType
        case let .project(project): return project.structureElementType
        }
    }
    
    /// Redundant, but required to fulfill `FCPXMLStructureElement` protocol requirements.
    public func asAnyStructureElement() -> FinalCutPro.FCPXML.AnyStructureElement {
        self
    }
}

extension FinalCutPro.FCPXML.AnyStructureElement {
    /// Returns the unwrapped structure element typed as ``FCPXMLStructureElement``.
    public var wrapped: any FCPXMLStructureElement {
        switch self {
        case let .library(structureElement): return structureElement
        case let .event(structureElement): return structureElement
        case let .project(structureElement): return structureElement
        }
    }
}

extension FinalCutPro.FCPXML.AnyStructureElement: FCPXMLElementContext {
    public var context: FinalCutPro.FCPXML.ElementContext {
        wrapped.context
    }
}

// MARK: Proxy Properties

extension FinalCutPro.FCPXML.AnyStructureElement {
    /// Convenience to return the name of the story element.
    /// Returns `nil` if attribute is not present or not applicable.
    public var name: String? {
        switch self {
        case let .library(library): return library.name
        case let .event(event): return event.name
        case let .project(project): return project.name
        }
    }
    
    /// Convenience to return the start of the story element.
    /// Returns `nil` if attribute is not present or not applicable.
    public var start: Timecode? {
        switch self {
        case .library(_): return nil
        case .event(_): return nil
        case .project(_): return nil
        }
    }
}

extension FinalCutPro.FCPXML.AnyStructureElement: FCPXMLExtractable {
    public func extractableElements() -> [FinalCutPro.FCPXML.AnyElement] {
        switch self {
        case .library(_): return [] // TODO: implement on library
        case let .event(event): return event.extractableElements()
        case let .project(project): return project.extractableElements()
        }
    }
    
    public func extractableChildren() -> [FinalCutPro.FCPXML.AnyElement] {
        switch self {
        case .library(_): return [] // TODO: implement on library
        case let .event(event): return event.extractableChildren()
        case let .project(project): return project.extractableChildren()
        }
    }
}

// MARK: - Filtering

extension Collection<FinalCutPro.FCPXML.AnyStructureElement> {
    /// Convenience to filter the FCPXML structure element collection and return only libraries.
    public func libraries() -> [FinalCutPro.FCPXML.Library] {
        reduce(into: []) { elements, element in
            if case let .library(element) = element { elements.append(element) }
        }
    }
    
    /// Convenience to filter the FCPXML structure element collection and return only events.
    public func events() -> [FinalCutPro.FCPXML.Event] {
        reduce(into: []) { elements, element in
            if case let .event(element) = element { elements.append(element) }
        }
    }
    
    /// Convenience to filter the FCPXML structure element collection and return only projects.
    public func projects() -> [FinalCutPro.FCPXML.Project] {
        reduce(into: []) { elements, element in
            if case let .project(element) = element { elements.append(element) }
        }
    }
}

// MARK: - FCPXML Parsing

extension FinalCutPro.FCPXML {
    static func structureElements(
        in xmlLeaf: XMLElement,
        breadcrumbs: [XMLElement],
        resources: [String: FinalCutPro.FCPXML.AnyResource],
        contextBuilder: FCPXMLElementContextBuilder
    ) -> [AnyStructureElement] {
        xmlLeaf
            .children?
            .lazy
            .compactMap { $0 as? XMLElement }
            .compactMap {
                AnyStructureElement(
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
