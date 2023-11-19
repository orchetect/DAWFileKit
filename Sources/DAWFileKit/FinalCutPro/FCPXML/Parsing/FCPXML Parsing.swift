//
//  FCPXML Parsing.swift
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
    
    static func elements(
        in xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource],
        contextBuilder: FCPXMLElementContextBuilder /*= .default*/
    ) -> [AnyElement] {
        xmlLeaf
            .children?
            .lazy
            .compactMap { $0 as? XMLElement }
            .compactMap {
                AnyElement(from: $0, resources: resources, contextBuilder: contextBuilder)
            }
        ?? []
    }
    
    static func structureElements(
        in xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource],
        contextBuilder: FCPXMLElementContextBuilder /*= .default*/
    ) -> [AnyStructureElement] {
        xmlLeaf
            .children?
            .lazy
            .compactMap { $0 as? XMLElement }
            .compactMap { 
                AnyStructureElement(from: $0, resources: resources, contextBuilder: contextBuilder)
            }
        ?? []
    }
    
    static func storyElements(
        in xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource],
        contextBuilder: FCPXMLElementContextBuilder /*= .default*/
    ) -> [AnyStoryElement] {
        xmlLeaf
            .children?
            .lazy
            .compactMap { $0 as? XMLElement }
            .compactMap {
                AnyStoryElement(from: $0, resources: resources, contextBuilder: contextBuilder)
            }
        ?? []
    }
}

extension FinalCutPro.FCPXML {
    /// Convenience to return all elements.
    /// This is computed, so it is best to avoid repeat calls to this method.
    public func allElements(contextBuilder: FCPXMLElementContextBuilder /*= .default*/) -> [AnyElement] {
        guard let xmlRoot = xmlRoot else { return [] }
        return Self.elements(in: xmlRoot, resources: resources(), contextBuilder: contextBuilder)
    }
    
    /// Convenience to return all events.
    /// This is computed, so it is best to avoid repeat calls to this method.
    ///
    /// Events may exist within:
    /// - the `fcpxml` element
    /// - the `fcpxml/library` element if it exists
    public func allEvents(contextBuilder: FCPXMLElementContextBuilder /*= .default*/) -> [Event] {
        let resources = resources()
        let elements = allElements(contextBuilder: contextBuilder)
        
        let rootStructureElements = elements.structureElements()
        
        var events: [Event] = []
        
        // root events
        events.append(contentsOf: rootStructureElements.events())
        
        // library events
        if let xmlLibrary = xmlLibrary {
            let libraryEvents = Self.structureElements(
                in: xmlLibrary, 
                resources: resources,
                contextBuilder: contextBuilder
            )
            .events()
            events.append(contentsOf: libraryEvents)
        }
        
        return events
    }
    
    /// Convenience to return all projects.
    /// This is computed, so it is best to avoid repeat calls to this method.
    ///
    /// Projects may exist within:
    /// - the `fcpxml` element
    /// - an `fcpxml/event` element
    /// - an `fcpxml/library/event` element
    public func allProjects(contextBuilder: FCPXMLElementContextBuilder /*= .default*/) -> [Project] {
        let elements = allElements(contextBuilder: contextBuilder)
        
        let rootStructureElements = elements.structureElements()
        
        var projects: [Project] = []
        
        // root projects
        projects.append(contentsOf: rootStructureElements.projects())
        
        // projects within events (this fetches events from all possible locations)
        let events = allEvents(contextBuilder: contextBuilder)
        projects.append(contentsOf: events.flatMap(\.projects))
        
        return projects
    }
    
    /// Convenience to return the library.
    /// A fcpxml file may optionally contain only one library.
    public func library(contextBuilder: FCPXMLElementContextBuilder /*= .default*/) -> Library? {
        guard let xmlRoot = xmlRoot else { return nil }
        return Self.structureElements(
            in: xmlRoot,
            resources: resources(),
            contextBuilder: contextBuilder
        )
        .libraries()
        .first
    }
}

// MARK: - Calculate Absolute Timecode
// TODO: (these methods are not used but they work)

extension FinalCutPro.FCPXML {
    static func calculateAbsoluteStart(
        element: AnyElement,
        parent: FinalCutPro.FCPXML.AnyElement,
        ancestorsOfParent: [FinalCutPro.FCPXML.AnyElement],
        parentAbsoluteStart: Timecode?
    ) -> Timecode? {
        let parentStart = nearestStart(of: parent, ancestors: ancestorsOfParent)
        
        guard let elementStart = element.start,
              let parentStart = parentStart,
              let parentAbsoluteStart = parentAbsoluteStart
        else {
            // skip emitting an error for elements known to not have start information
            // or known to not inherit absolute start information
            if element.elementType != .structure(.library),
               element.elementType != .structure(.event),
               element.elementType != .structure(.project)
            {
                let pas = parentAbsoluteStart?.stringValue(format: [.showSubFrames]) ?? "missing"
                let ps = parentStart?.stringValue(format: [.showSubFrames]) ?? "missing"
                print(
                    "Error calculating absolute timecode for element \(element.name?.quoted ?? "")."
                    + " Parent absolute start: \(pas) Parent start: \(ps)"
                )
            }
            return nil
        }
        
        let localElementStart = elementStart - parentStart
        guard let elementAbsoluteStart = try? parentAbsoluteStart.adding(
            localElementStart,
            by: .wrapping
        )
        else {
            print("Error offsetting timecode for element \(element.name?.quoted ?? "").")
            return nil
        }
        
        return elementAbsoluteStart
    }
    
    /// Return absolute timecode of innermost parent by calculating aggregate offset of ancestors.
    /// - Note: Ancestors is ordered from furthest ancestor to closest ancestor of the `parent`.
    static func aggregateOffset(
        of element: FinalCutPro.FCPXML.AnyElement,
        ancestors: [FinalCutPro.FCPXML.AnyElement]
    ) -> Timecode? {
        let ancestors = ancestors + [element] // topmost -> innermost
        
        var pos: Timecode?
        
        func add(_ other: Timecode?) {
            guard let other = other else { return }
            let newTC = pos ?? Timecode(.zero, using: other.properties)
            pos = try? newTC.adding(other, by: .wrapping)
        }
        
        for ancestor in ancestors {
            switch ancestor {
            case let .story(storyElement):
                switch storyElement {
                case let .anyAnnotation(annotation):
                    add(annotation.offset)
                    
                case let .anyClip(clip):
                    add(clip.offset)
                    
                case .sequence(_ /* let sequence */ ):
                    // pos = sequence.startTimecode
                    break
                    
                case let .spine(spine):
                    add(spine.offset)
                }
                
            case .structure(_):
                break
            }
        }
        
        return pos
    }
    
    /// Return nearest `start` attribute value, starting from closest parent and traversing up
    /// through ancestors.
    /// - Note: Ancestors is ordered from furthest ancestor to closest ancestor of the `parent`.
    static func nearestStart(
        of element: FinalCutPro.FCPXML.AnyElement,
        ancestors: [FinalCutPro.FCPXML.AnyElement]
    ) -> Timecode? {
        let ancestors = ancestors + [element] // topmost -> innermost
        
        for ancestor in ancestors.reversed() {
            if let start = ancestor.start { return start }
        }
        
        return nil
    }
}

extension FinalCutPro.FCPXML {
    static func calculateAbsoluteStart(
        element: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) -> Timecode? {
        if let tcStart = tcStart(of: element, resources: resources) {
            return tcStart
        }
        
        guard let parent = element.parentXMLElement else { return nil }
        
        let parentStart = nearestStart(of: parent, resources: resources)
            ?? nearestTCStart(of: parent, resources: resources)
        let parentAbsoluteStart = aggregateOffset(of: parent, resources: resources)
        
        guard let parentStart = parentStart,
              let elementStart = nearestStart(of: element, resources: resources)
                ?? nearestTCStart(of: parent, resources: resources)
        else {
            let ps = parentStart?.stringValue(format: [.showSubFrames]) ?? "missing"
            let pas = parentAbsoluteStart?.stringValue(format: [.showSubFrames]) ?? "missing"
            print(
                "Error calculating absolute timecode for element \(element.name?.quoted ?? "")."
                + " Parent start: \(ps) Parent absolute start: \(pas)"
            )
            return nil
        }
        
        let localElementStart = elementStart - parentStart
        
        let elementAbsoluteStart: Timecode
        do {
            elementAbsoluteStart = try parentAbsoluteStart?.adding(
                localElementStart,
                by: .wrapping
            ) ?? localElementStart
        } catch {
            print("Error offsetting timecode for element \(element.name?.quoted ?? "").")
            return nil
        }
        
        return elementAbsoluteStart
    }
    
    /// Return absolute timecode of innermost parent by calculating aggregate offset of ancestors.
    static func aggregateOffset(
        of element: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) -> Timecode? {
        var pos: Timecode?
        
        func add(_ other: Timecode?) {
            guard let other = other else { return }
            let newTC = pos ?? Timecode(.zero, using: other.properties)
            pos = try? newTC.adding(other, by: .wrapping)
        }
        
        element.walkAncestors(includingSelf: true) { ancestor in
            if let offsetString = ancestor.attributeStringValue(forName: "offset") {
                let offsetTC = try? timecode(fromRational: offsetString, xmlLeaf: ancestor, resources: resources)
                add(offsetTC)
            }
            
            return true
        }
        
        return pos
    }
    
    /// Return nearest `start` attribute value as `Timecode`, starting from the element and
    /// traversing up through ancestors.
    static func nearestStart(
        of element: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) -> Timecode? {
        guard let s = element.attributeStringValueTraversingAncestors(forName: "start")
        else { return nil }
        
        return try? timecode(fromRational: s.value, xmlLeaf: s.inElement, resources: resources)
    }
    
    /// Returns the `start` attribute value as `Timecode`.
    static func start(
        of element: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) -> Timecode? {
        guard let startValue = element.attributeStringValue(forName: "start")
        else { return nil }
        
        return try? timecode(fromRational: startValue, xmlLeaf: element, resources: resources)
    }
    
    /// Return nearest `tcStart` attribute value as `Timecode`, starting from the element and
    /// traversing up through ancestors.
    static func nearestTCStart(
        of element: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) -> Timecode? {
        guard let s = element.attributeStringValueTraversingAncestors(forName: "tcStart")
        else { return nil }
        
        return try? timecode(fromRational: s.value, xmlLeaf: s.inElement, resources: resources)
    }
    
    /// Returns the `tcStart` attribute value as `Timecode`.
    static func tcStart(
        of element: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) -> Timecode? {
        guard let startValue = element.attributeStringValue(forName: "tcStart")
        else { return nil }
        
        return try? timecode(fromRational: startValue, xmlLeaf: element, resources: resources)
    }
}

#endif
