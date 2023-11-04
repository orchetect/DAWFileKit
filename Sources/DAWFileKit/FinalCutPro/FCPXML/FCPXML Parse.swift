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
    /// - Returns: `[ID: Resource]`
    public func resources() -> [String: Resource] {
        xmlResources?
            .children?
            .lazy
            .compactMap { $0 as? XMLElement }
            .reduce(into: [String: Resource]()) { dict, element in
                let id = element.attributeStringValue(forName: "id") ?? ""
                
                guard let resourceName = element.name,
                      let resource = Resource.ResourceType(rawValue: resourceName)
                else {
                    let n = (element.name ?? "").quoted
                    print("Unhandled FCPXML resource type: \(n)")
                    return
                }
                
                switch resource {
                case .asset:
                    let res = Resource.Asset(from: element)
                    dict[id] = .asset(res)
                case .effect:
                    let res = Resource.Effect(from: element)
                    dict[id] = .effect(res)
                case .format:
                    let res = Resource.Format(from: element)
                    dict[id] = .format(res)
                }
            } ?? [:]
    }
    
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

// MARK: - XMLRoot/fcpxml/library/*

extension FinalCutPro.FCPXML {
    /// Returns all events.
    public func events() -> [Event] {
        let resources = resources()
        return xmlEvents.map {
            Event(
                name: $0.attributeStringValue(forName: "name") ?? "",
                projects: projects(in: $0, resources: resources)
            )
        }
    }
}

// MARK: - XMLRoot/fcpxml/library/event/*

extension FinalCutPro.FCPXML {
    /// Returns all projects.
    public func projects() -> [Project] {
        let resources = resources()
        return xmlEvents.flatMap {
            projects(in: $0, resources: resources)
        }
    }
    
    /// Internal:
    /// Parses projects from a leaf (usually from an `<event>` leaf).
    internal func projects(
        in xmlLeaf: XMLElement,
        resources: [String: Resource]
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

// MARK: - XMLRoot/fcpxml/library/event/project/*

extension FinalCutPro.FCPXML {
    /// Internal:
    /// Parse sequences from a leaf (usually from a `<project>` leaf).
    internal func parseSequences(
        in xmlLeaf: XMLElement,
        resources: [String: Resource]
    ) -> [Sequence] {
        let xmlElements = xmlLeaf.elements(forName: "sequence")
        let sequences = xmlElements.map {
            Sequence(from: $0, resources: resources)
        }
        return sequences
    }
}

#endif
