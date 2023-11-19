//
//  FCPXML Time Utilities.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
@_implementationOnly import OTCore

// MARK: - Time Parsing & Calculations (Model)
// TODO: (these methods are not used but they work)

extension FinalCutPro.FCPXML {
    /// Return the absolute start timecode of the element.
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
    /// Note that this is relative to the element's parent's timeline and may not be absolute
    /// timecode.
    ///
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

// MARK: - Time Parsing & Calculations (XML)

extension FinalCutPro.FCPXML {
    static func calculateAbsoluteStart(
        element: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) -> Timecode? {
        if let tcStart = tcStart(of: element, resources: resources) {
            return tcStart
        }
        
        guard let parent = element.parentXMLElement else { return nil }
        let parentType = ElementType(from: parent)
        
        let parentStart = nearestStart(of: parent, resources: resources)
            ?? nearestTCStart(of: parent, resources: resources)
        let parentAbsoluteStart = aggregateOffset(of: parent, resources: resources)
        
        guard let parentStart = parentStart,
              let elementStart = nearestStart(of: element, resources: resources)
                ?? nearestTCStart(of: parent, resources: resources)
        else {
            // skip emitting an error for elements known to not have start information
            // or known to not inherit absolute start information
            if parentType != .structure(.library),
               parentType != .structure(.event),
               parentType != .structure(.project)
            {
                let ps = parentStart?.stringValue(format: [.showSubFrames]) ?? "missing"
                let pas = parentAbsoluteStart?.stringValue(format: [.showSubFrames]) ?? "missing"
                print(
                    "Error calculating absolute timecode for element \(element.name?.quoted ?? "")."
                    + " Parent start: \(ps) Parent absolute start: \(pas)"
                )
            }
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
    /// Note that this is relative to the element's parent's timeline and may not be absolute
    /// timecode.
    static func nearestStart(
        of element: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) -> Timecode? {
        guard let s = element.attributeStringValueTraversingAncestors(forName: "start")
        else { return nil }
        
        return try? timecode(fromRational: s.value, xmlLeaf: s.inElement, resources: resources)
    }
    
    /// Returns the `start` attribute value as `Timecode`.
    /// Note that this is relative to the element's parent's timeline and may not be absolute
    /// timecode.
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
