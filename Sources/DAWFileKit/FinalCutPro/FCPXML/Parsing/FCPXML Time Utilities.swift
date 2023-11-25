//
//  FCPXML Time Utilities.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
@_implementationOnly import OTCore

// MARK: - Time Parsing & Calculations (XML)

extension FinalCutPro.FCPXML {
    static func calculateAbsoluteStart(
        of element: XMLElement,
        breadcrumbs: [XMLElement],
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) -> Timecode? {
        var accum: Timecode?
        var lastStart: Timecode?
        
        func add(_ other: Timecode?) {
            guard let other = other else { return }
            let newTC = accum ?? Timecode(.zero, using: other.properties)
            accum = try? newTC.adding(other, by: .wrapping)
        }
        
        // reverse so we can pop last to iterate from root to current element
        var bc = Array((breadcrumbs + [element]).reversed())
        
        while let breadcrumb = bc.popLast() {
            if let tcStart = tcStart(of: breadcrumb, resources: resources) {
                assert(breadcrumb.attributeStringValue(forName: "start") == nil)
                add(tcStart)
                lastStart = tcStart
                continue
            }
            
            if let offset = offset(of: breadcrumb, resources: resources) {
                if let _lastStart = lastStart {
                    let diff = offset - _lastStart
                    lastStart = nil
                    add(diff)
                } else {
                    add(offset)
                }
            }
            
            let elementType = ElementType(from: breadcrumb)
            
            if case let .story(storyElementType) = elementType,
               case let .anyAnnotation(annotationType) = storyElementType
            {
                switch annotationType {
                case .marker, .chapterMarker, .keyword:
                    // markers and keywords use `start` attribute as an offset, so handle it specially
                    if let elementStart = start(of: breadcrumb, resources: resources) {
                        if let breadcrumbParent = breadcrumb.parentXMLElement,
                           let parentStart = start(of: breadcrumbParent, resources: resources)
                        {
                            let diff = elementStart - parentStart
                            add(diff)
                        } else {
                            add(elementStart)
                        }
                    }
                case .caption:
                    // caption behaves like a clip and follows the same rules
                    break
                }
                
            }
            
            if let start = start(of: breadcrumb, resources: resources) {
                lastStart = start
            }
        }
        
        return accum
    }
    
    /// Returns the `offset` attribute value as `Timecode`.
    static func offset(
        of element: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) -> Timecode? {
        guard let startValue = element.attributeStringValue(forName: "offset")
        else { return nil }
        
        return try? timecode(fromRational: startValue, xmlLeaf: element, resources: resources)
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
