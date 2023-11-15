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
                guard let id = element.attributeStringValue(forName: "id"),
                      let resource = AnyResource(from: element)
                else { return }
                
                dict[id] = resource
            } ?? [:]
    }
    
    /// A fcpxml file may or may not contain one library.
    public func library() -> Library? {
        guard let library = xmlLibrary else { return nil }
        let location = library.attributeStringValue(
            forName: FinalCutPro.FCPXML.Library.Attributes.location.rawValue
        ) ?? ""
        
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
            let events = events(in: xmlRoot, resources: resources)
            gatheredEvents.append(contentsOf: events)
        }
        
        if let xmlLibrary = xmlLibrary {
            let events = events(in: xmlLibrary, resources: resources)
            gatheredEvents.append(contentsOf: events)
        }
        
        return gatheredEvents
    }
    
    /// Internal:
    /// Parses events from a leaf (usually from the `fcpxml` leaf or an `library` leaf).
    /// This is computed, so it is best to avoid repeat calls to this method.
    func events(
        in xmlLeaf: XMLElement,
        resources: [String: AnyResource]
    ) -> [Event] {
        let xmlElements = xmlLeaf.elements(forName: StructureElementType.event.rawValue)
        let events = xmlElements.compactMap {
            Event(from: $0, resources: resources)
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
            let projects = Self.projects(in: xmlRoot, resources: resources)
            gatheredProjects.append(contentsOf: projects)
        }
        
        let projectsInEvents: [Project] = events()
            .reduce(into: []) { projectsInEvents, event in
                projectsInEvents.append(contentsOf: event.projects)
            }
        gatheredProjects.append(contentsOf: projectsInEvents)
        
        return gatheredProjects
    }
    
    /// Internal:
    /// Parses projects from a leaf (usually from the `fcpxml` leaf or an `event` leaf).
    /// This is computed, so it is best to avoid repeat calls to this method.
    static func projects(
        in xmlLeaf: XMLElement,
        resources: [String: AnyResource]
    ) -> [Project] {
        let xmlElements = xmlLeaf.elements(forName: StructureElementType.project.rawValue)
        let projects: [Project] = xmlElements.compactMap { projectLeaf in
            Project(from: projectLeaf, resources: resources)
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
    static func parseSequences(
        in xmlLeaf: XMLElement,
        resources: [String: AnyResource]
    ) -> [Sequence] {
        let xmlElements = xmlLeaf.elements(forName: StoryElementType.sequence.rawValue)
        let sequences = xmlElements.compactMap {
            Sequence(from: $0, resources: resources)
        }
        return sequences
    }
}

// MARK: - Story Elements

extension FinalCutPro.FCPXML {
    static func parseStoryElements(
        in xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) -> [AnyStoryElement] {
        xmlLeaf
            .children?
            .lazy
            .compactMap { $0 as? XMLElement }
            .compactMap { AnyStoryElement(from: $0, resources: resources) }
        ?? []
    }
}

// MARK: - Clips

extension FinalCutPro.FCPXML {
    static func parseAuditions(
        in xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) -> [Audition] {
        xmlLeaf
            .children?
            .lazy
            .compactMap { $0 as? XMLElement }
            .compactMap { Audition(from: $0, resources: resources) }
        ?? []
    }
    
    static func parseClips(
        in xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) -> [AnyClip] {
        xmlLeaf
            .children?
            .lazy
            .compactMap { $0 as? XMLElement }
            .filter { xml in ClipType.allCases.contains(where: { ct in ct.rawValue == xml.name }) }
            .compactMap { AnyClip(from: $0, resources: resources) }
        ?? []
    }
}

// MARK: - Markers

extension FinalCutPro.FCPXML {
    // TODO: refactor this as a more generic annotation parser
    /// Parses markers shallowly in the given XML element.
    static func parseMarkers(
        in xmlLeaf: XMLElement,
        frameRate: TimecodeFrameRate
    ) -> [Marker] {
        let children = xmlLeaf
            .children?
            .lazy
            .compactMap { $0 as? XMLElement } ?? []
        
        var markers: [Marker] = []
        
        children.forEach {
            let itemName = $0.name ?? ""
            guard let item = AnnotationType(rawValue: itemName)
            else {
                print("Info: skipping clip item \(itemName.quoted). Not handled.")
                return // next forEach
            }
            
            // TODO: we'll just parse markers for the time being. more items can be added in future.
            switch item {
            case .marker, .chapterMarker:
                guard let marker = Marker(from: $0, frameRate: frameRate)
                else {
                    print("Error: failed to parse marker.")
                    return // next forEach
                }
                markers.append(marker)
            }
        }
        
        return markers
    }
    
    // TODO: refactor this as a more generic annotation parser
    /// Parses markers shallowly in the given XML element.
    static func parseMarkers(
        in xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) -> [Marker] {
        guard let frameRate = FinalCutPro.FCPXML.timecodeFrameRate(for: xmlLeaf, in: resources)
        else {
            print("Error: Could not determine frame rate while parsing markers.")
            return []
        }
        return parseMarkers(in: xmlLeaf, frameRate: frameRate)
    }
}

#endif
