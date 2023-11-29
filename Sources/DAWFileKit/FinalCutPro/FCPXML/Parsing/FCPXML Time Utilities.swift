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
    
    static func occlusion(
        area parentRange: Range<Timecode>,
        internalStart: Timecode,
        internalEnd: Timecode?
    ) -> ElementOcclusion {
        if let internalEnd = internalEnd {
            // internal element has duration, treat as a time range
            
            let internalRange = internalStart ..< internalEnd.clamped(to: internalStart...)
            
            if parentRange.contains(internalRange) {
                return .notOccluded
            }
            
            if parentRange.overlaps(internalRange)
            // elementEnd != parentStart, // don't count consecutive events as overlap
            // elementStart != parentEnd // don't count consecutive events as overlap
            {
                return .partiallyOccluded
            } else {
                return .fullyOccluded
            }
        } else {
            // internal element does not have duration, treat as a single point in time
            
            let isContained = parentRange.contains(internalStart)
            return isContained ? .notOccluded : .fullyOccluded
        }
    }
    
    static func effectiveOcclusion(
        of element: XMLElement,
        breadcrumbs: [XMLElement],
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) -> FinalCutPro.FCPXML.ElementOcclusion {
        guard var elementStart = calculateAbsoluteStart(
            of: element,
            breadcrumbs: breadcrumbs,
            resources: resources
        ) else { return .notOccluded }
        
        var elementEnd: Timecode?
        if let elementDuration = duration(of: element, resources: resources) {
            elementEnd = elementStart + elementDuration
        }
        
        var isPartial = false
        
        var breadcrumbs = breadcrumbs
        var lastLane: Int?
        
        while let breadcrumb = breadcrumbs.popLast() {
            let value = breadcrumb.attributeStringValue(forName: "lane")
            let lane = value != nil ? Int(value!) : nil
            defer { lastLane = lane }
            
            if let getLastLane = lastLane {
                guard lane == getLastLane else { continue }
            }
            
            guard let bcAbsStart = calculateAbsoluteStart(
                of: breadcrumb,
                breadcrumbs: breadcrumbs,
                resources: resources
            ),
            let bcDuration = nearestDuration(of: breadcrumb, breadcrumbs: breadcrumbs, resources: resources)
            else { continue }
            
            let bcAbsEnd = bcAbsStart + bcDuration
            let bcRange = bcAbsStart ..< bcAbsEnd
            
            let o = occlusion(area: bcRange, internalStart: elementStart, internalEnd: elementEnd)
            
            if o == .fullyOccluded {
                return o
            }
            
            if o == .partiallyOccluded {
                // reduce exposed internal range
                elementStart = elementStart.clamped(to: bcRange)
                elementEnd = elementEnd?.clamped(to: bcRange)
                isPartial = true
            }
        }
        
        return isPartial ? .partiallyOccluded : .notOccluded
    }
    
    /// Returns the `duration` attribute value as `Timecode`.
    static func duration(
        of element: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) -> Timecode? {
        guard let startValue = element.attributeStringValue(forName: "duration")
        else { return nil }
        
        return try? timecode(fromRational: startValue, xmlLeaf: element, resources: resources)
    }
    
    /// Return nearest `duration` attribute value as `Timecode`, starting from the element and
    /// traversing up through ancestors.
    static func nearestDuration(
        of element: XMLElement,
        breadcrumbs: [XMLElement],
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) -> Timecode? {
        let elements = (breadcrumbs + [element]).reversed()
        
        guard let firstWithDuration = elements
            .first(where: { $0.attribute(forName: "duration") != nil }),
              let durString = firstWithDuration.attributeStringValue(forName: "duration")
        else { return nil }
        
        return try? timecode(fromRational: durString, xmlLeaf: firstWithDuration, resources: resources)
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
