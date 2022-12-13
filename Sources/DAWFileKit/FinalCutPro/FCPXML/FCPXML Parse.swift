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
    /// [ID: Resource]
    internal func parseResources() -> [String: Resource] {
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
    public func parseEvents(
        resources: [String: Resource]
    ) -> [Event] {
        xmlEvents.map {
            let projects = parseProjects(in: $0, resources: resources)
            let event = Event(projects: projects)
            return event
        }
    }
    
    internal func parseProjects(
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
