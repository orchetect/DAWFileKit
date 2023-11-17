//
//  FCPXML AnyStructureElement.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    /// Type-erased box containing a structure element.
    public enum AnyStructureElement {
        case library(Library)
        case event(Event)
        case project(Project)
    }
}

extension FinalCutPro.FCPXML.AnyStructureElement: FCPXMLElement {
    public var elementType: FinalCutPro.FCPXML.ElementType { .structure }
    public func asAnyElement() -> FinalCutPro.FCPXML.AnyElement { .structure(self) }
}

extension FinalCutPro.FCPXML.AnyStructureElement: FCPXMLStructureElement {
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

extension FinalCutPro.FCPXML.AnyStructureElement: FCPXMLExtractableElement {
    public func extractableStart() -> Timecode? { nil }
    public func extractableName() -> String? { nil }
}

#endif
