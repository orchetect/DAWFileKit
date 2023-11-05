//
//  FCPXML Parse.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
@_implementationOnly import OTCore

// MARK: - XMLRoot/fcpxml/*

extension FinalCutPro.FCPXML {
    /// Returns resources contained in the XML, keyed by the resource ID.
    /// This is computed, so it is best to avoid repeat calls to this method.
    ///
    /// - Returns: `[ID: AnyResource]`
    public func resources() -> [String: AnyResource] {
        xmlResources?
            .children?
            .lazy
            .compactMap { $0 as? XMLElement }
            .reduce(into: [String: AnyResource]()) { dict, element in
                let id = element.attributeStringValue(forName: "id") ?? ""
                
                guard let resourceName = element.name,
                      let resource = AnyResource.ResourceType(rawValue: resourceName)
                else {
                    let n = (element.name ?? "").quoted
                    print("Unhandled FCPXML resource type: \(n)")
                    return
                }
                
                // TODO: refactor into AnyResource?
                switch resource {
                case .asset:
                    let res = Asset(from: element)
                    dict[id] = .asset(res)
                case .media:
                    let res = Media(from: element)
                    dict[id] = .media(res)
                case .format:
                    let res = Format(from: element)
                    dict[id] = .format(res)
                case .effect:
                    let res = Effect(from: element)
                    dict[id] = .effect(res)
                case .locator:
                    let res = Locator(from: element)
                    dict[id] = .locator(res)
                case .objectTracker:
                    let res = ObjectTracker(from: element)
                    dict[id] = .objectTracker(res)
                case .trackingShape:
                    let res = TrackingShape(from: element)
                    dict[id] = .trackingShape(res)
                }
            } ?? [:]
    }
    
    /// A fcpxml file may or may not contain one library.
    public func library() -> Library? {
        guard let library = xmlLibrary else { return nil }
        let location = library.attributeStringValue(forName: "location") ?? ""
        
        guard let locationURL = URL(string: location) else {
            print("Invalid fcpxml library URL: \(location.quoted)")
            return nil
        }
        return Library(location: locationURL)
    }
}

// MARK: fcpxml/event or
// MARK: fcpxml/library/event

extension FinalCutPro.FCPXML {
    /// Convenience to return all events.
    /// This is computed, so it is best to avoid repeat calls to this method.
    ///
    /// Events may exist within:
    /// - the `fcpxml` element
    /// - the `fcpxml/library` element if it exists
    public func events() -> [Event] {
        let resources = resources()
        var gatheredEvents: [Event] = []
        
        if let xmlRoot = xmlRoot {
            gatheredEvents.append(contentsOf: events(in: xmlRoot, resources: resources))
        }
        
        if let xmlLibrary = xmlLibrary {
            gatheredEvents.append(contentsOf: events(in: xmlLibrary, resources: resources))
        }
        
        return gatheredEvents
    }
    
    /// Internal:
    /// Parses events from a leaf (usually from the `fcpxml` leaf or an `library` leaf).
    /// This is computed, so it is best to avoid repeat calls to this method.
    internal func events(
        in xmlLeaf: XMLElement,
        resources: [String: AnyResource]
    ) -> [Event] {
        let xmlElements = xmlLeaf.elements(forName: "event")
        let events = xmlElements.map {
            Event(
                name: $0.attributeStringValue(forName: "name") ?? "",
                projects: projects(in: $0, resources: resources)
            )
        }
        return events
    }
}

// MARK: fcpxml/project or
// MARK: fcpxml/event/project or
// MARK: fcpxml/library/event/project

extension FinalCutPro.FCPXML {
    /// Convenience to return all projects.
    /// This is computed, so it is best to avoid repeat calls to this method.
    ///
    /// Projects may exist within:
    /// - the `fcpxml` element
    /// - an `fcpxml/event` element
    /// - an `fcpxml/library/event` element
    public func projects() -> [Project] {
        let resources = resources()
        var gatheredProjects: [Project] = []
        
        if let xmlRoot = xmlRoot {
            gatheredProjects.append(contentsOf: projects(in: xmlRoot, resources: resources))
        }
        
        let projectsInEvents: [Project] = events().reduce(into: []) { projectsInEvents, event in
            projectsInEvents.append(contentsOf: event.projects)
        }
        gatheredProjects.append(contentsOf: projectsInEvents)
        
        return gatheredProjects
    }
    
    /// Internal:
    /// Parses projects from a leaf (usually from the `fcpxml` leaf or an `event` leaf).
    /// This is computed, so it is best to avoid repeat calls to this method.
    internal func projects(
        in xmlLeaf: XMLElement,
        resources: [String: AnyResource]
    ) -> [Project] {
        let xmlElements = xmlLeaf.elements(forName: "project")
        let projects = xmlElements.map {
            let sequences = parseSequences(in: $0, resources: resources)
            let project = Project(
                name: $0.attributeStringValue(forName: "name") ?? "",
                sequences: sequences
            )
            return project
        }
        return projects
    }
}

// MARK: fcpxml/project/sequence or
// MARK: fcpxml/event/project/sequence or
// MARK: fcpxml/library/event/project/sequence

extension FinalCutPro.FCPXML {
    /// Internal:
    /// Parse sequences from a leaf (usually from a `project` leaf).
    /// This is computed, so it is best to avoid repeat calls to this method.
    internal func parseSequences(
        in xmlLeaf: XMLElement,
        resources: [String: AnyResource]
    ) -> [Sequence] {
        let xmlElements = xmlLeaf.elements(forName: "sequence")
        let sequences = xmlElements.map {
            Sequence(from: $0, resources: resources)
        }
        return sequences
    }
}

#endif
