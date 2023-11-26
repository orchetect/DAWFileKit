//
//  FCPXML Properties.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

// MARK: - Main Public Model Getters

extension FinalCutPro.FCPXML {
    /// Returns resources contained in the XML, keyed by the resource ID string.
    /// This is computed, so it is best to avoid repeat calls to this method.
    ///
    /// - Returns: `[ID: AnyResource]`
    public func resources() -> [String: AnyResource] {
        xmlResources?
            .children?
            .lazy
            .compactMap { $0 as? XMLElement }
            .reduce(into: [String: AnyResource]()) { dict, element in
                guard let id = element.attributeStringValue(forName: "id"),
                      let resource = AnyResource(from: element)
                else { return }
                
                dict[id] = resource
            } ?? [:]
    }
    
    /// Returns all elements comprising the entire structure within the `fcpxml` element.
    /// This is computed, so it is best to avoid repeat calls to this method.
    public func allElements(context: FCPXMLElementContextBuilder = .default) -> [AnyElement] {
        guard let xmlRoot = xmlRoot else { return [] }
        return Self.elements( // adds xmlRoot as breadcrumb
            in: xmlRoot,
            breadcrumbs: [],
            resources: resources(),
            contextBuilder: context
        )
    }
    
    /// Returns all events that exist anywhere within the XML hierarchy.
    /// This is computed, so it is best to avoid repeat calls to this method.
    ///
    /// Events may exist within:
    /// - the `fcpxml` element
    /// - the `fcpxml/library` element if it exists
    public func allEvents(context: FCPXMLElementContextBuilder = .default) -> [Event] {
        let resources = resources()
        let elements = allElements(context: context)
        
        let rootStructureElements = elements.structureElements()
        
        var events: [Event] = []
        
        // root events
        events.append(contentsOf: rootStructureElements.events())
        
        // library events
        if let xmlLibrary = xmlLibrary {
            let libraryEvents = Self.structureElements( // adds xmlLibrary as breadcrumb
                in: xmlLibrary,
                breadcrumbs: [],
                resources: resources,
                contextBuilder: context
            )
            .events()
            events.append(contentsOf: libraryEvents)
        }
        
        return events
    }
    
    /// Returns all projects that exist anywhere within the XML hierarchy.
    /// This is computed, so it is best to avoid repeat calls to this method.
    ///
    /// Projects may exist within:
    /// - the `fcpxml` element
    /// - an `fcpxml/event` element
    /// - an `fcpxml/library/event` element
    public func allProjects(context: FCPXMLElementContextBuilder = .default) -> [Project] {
        let elements = allElements(context: context)
        
        let rootStructureElements = elements.structureElements()
        
        var projects: [Project] = []
        
        // root projects
        projects.append(contentsOf: rootStructureElements.projects())
        
        // projects within events (this fetches events from all possible locations)
        let events = allEvents(context: context)
        projects.append(contentsOf: events.flatMap(\.projects))
        
        return projects
    }
    
    /// Returns the library, if any.
    /// A fcpxml file may optionally contain only one library.
    /// This is computed, so it is best to avoid repeat calls to this method.
    public func library(context: FCPXMLElementContextBuilder = .default) -> Library? {
        guard let xmlRoot = xmlRoot else { return nil }
        return Self.structureElements( // adds xmlRoot as breadcrumb
            in: xmlRoot,
            breadcrumbs: [],
            resources: resources(),
            contextBuilder: context
        )
        .libraries()
        .first
    }
}

// MARK: - XMLRoot/*

extension FinalCutPro.FCPXML {
    /// Utility:
    /// Returns the root `fcpxml` XML element if it exists.
    public var xmlRoot: XMLElement? {
        xml.children?
            .lazy
            .compactMap { $0 as? XMLElement }
            .first(where: { $0.name == FoundationElementType.fcpxml.rawValue })
    }
    
    enum FCPXMLAttributesKey: String {
        case version
    }
}

// MARK: - XMLRoot/fcpxml/*

extension FinalCutPro.FCPXML {
    /// Utility:
    /// Returns the `fcpxml/resources` XML element if it exists.
    /// Exactly one of these elements is always required, regardless of the version of the FCPXML.
    public var xmlResources: XMLElement? {
        xmlRoot?.elements(forName: FoundationElementType.resources.rawValue).first
    }
    
    /// Utility:
    /// Returns the `fcpxml/library` XML element if it exists.
    /// One or zero of these elements may be present within the `fcpxml` element.
    public var xmlLibrary: XMLElement? {
        xmlRoot?.elements(forName: FoundationElementType.library.rawValue).first
    }
}

#endif
