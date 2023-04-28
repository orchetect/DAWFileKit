//
//  FCPXML Parse.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
@_implementationOnly import OTCore

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

                switch element.name {
                case Resource.ResourceType.effect.rawValue:
                    let res = Resource.Effect(from: element)
                    dict[id] = .effect(res)
                case Resource.ResourceType.format.rawValue:
                    let res = Resource.Format(from: element)
                    dict[id] = .format(res)
                default:
                    let n = (element.name ?? "").quoted
                    print("Unhandled FCPXML resource type: \(n)")
                }
            } ?? [:]
    }
    
    /// Returns events in first library.
    /// (TODO: We're assuming the XML only contains one library)
    public func events() -> [Event] {
        let resources = resources()
        return xmlEvents.map {
            let projects = projects(in: $0, resources: resources)
            let event = Event(projects: projects)
            return event
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
            let project = Project(sequences: sequences)
            return project
        }
        return projects
    }
    
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
