//
//  FCPXML Time and Frame Rate Parsing.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import OTCore

// MARK: - Timecode Format

extension XMLElement {
    /// FCPXML: Traverses the parents of the element, including the element itself, and returns the
    /// first `tcFormat` attribute found.
    func _fcpTCFormatForElementOrAncestors() -> FinalCutPro.FCPXML.TimecodeFormat? {
        let attributeName = FinalCutPro.FCPXML.TimecodeFormat.attributeName
        
        guard let (_, tcFormatValue) = ancestorElements(includingSelf: true)
            .first(withAttribute: attributeName),
            let tcFormat = FinalCutPro.FCPXML.TimecodeFormat(rawValue: tcFormatValue)
        else { return nil }
        
        return tcFormat
    }
    
    /// FCPXML: Return nearest `duration` attribute value, starting from the element and
    /// traversing back through ancestors.
    ///
    /// - Parameters:
    ///   - ancestors: Optional replacement for ancestors. Ordered nearest to furthest ancestor.
    func _fcpNearestDuration<S: Sequence<XMLElement>>(
        ancestors: S? = nil as [XMLElement]?,
        includingSelf: Bool
    ) -> Fraction? {
        let elements = ancestorElements(overrideWith: ancestors, includingSelf: includingSelf)
        
        guard let (durElement, _) = elements.first(withAttribute: "duration")
        else { return nil }
        
        return durElement.fcpDuration
    }
    
    /// FCPXML: Return nearest `start` attribute value, starting from the element and
    /// traversing back through ancestors.
    ///
    /// - Parameters:
    ///   - ancestors: Optional replacement for ancestors. Ordered nearest to furthest ancestor.
    func _fcpNearestStart<S: Sequence<XMLElement>>(
        ancestors: S? = nil as [XMLElement]?,
        includingSelf: Bool
    ) -> Fraction? {
        let elements = ancestorElements(overrideWith: ancestors, includingSelf: includingSelf)
        
        guard let (durElement, _) = elements.first(withAttribute: "start")
        else { return nil }
        
        return durElement.fcpStart
    }
    
    /// FCPXML: Return nearest `tcStart` attribute value, starting from the element and
    /// traversing back through ancestors.
    ///
    /// - Parameters:
    ///   - ancestors: Optional replacement for ancestors. Ordered nearest to furthest ancestor.
    func _fcpNearestTCStart<S: Sequence<XMLElement>>(
        ancestors: S? = nil as [XMLElement]?,
        includingSelf: Bool
    ) -> Fraction? {
        let elements = ancestorElements(overrideWith: ancestors, includingSelf: includingSelf)
        
        guard let (durElement, _) = elements.first(withAttribute: "tcStart")
        else { return nil }
        
        return durElement.fcpTCStart
    }
}

// MARK: - Time Parsing & Calculations

extension XMLElement {
    /// FCPXML: Returns the absolute start time of the element in the outermost ancestor's timeline.
    ///
    /// - Parameters:
    ///   - ancestors: Optional replacement for ancestors. Ordered nearest to furthest ancestor.
    func _fcpCalculateAbsoluteStart<S: Sequence<XMLElement>>(
        ancestors: S? = nil as [XMLElement]?
    ) -> Fraction? {
        var accum: Fraction?
        var lastStart: Fraction?
        
        func add(_ other: Fraction?) {
            guard let other = other else { return }
            let newTC = accum ?? .zero
            accum = newTC + other
        }
        
        // iterate from root to current element
        
        var ancestors = Array(ancestorElements(overrideWith: ancestors, includingSelf: true))
        
        while let ancestor = ancestors.popLast() {
            if let tcStart = ancestor.fcpTCStart {
                assert(ancestor.fcpStart == nil)
                add(tcStart)
                lastStart = tcStart
                continue
            }
            
            if let offset = ancestor.fcpOffset {
                if let _lastStart = lastStart {
                    let diff = offset - _lastStart
                    lastStart = nil
                    add(diff)
                } else {
                    add(offset)
                }
            }
            
            let elementType = ancestor.fcpElementType
            
            if let elementType = elementType {
                switch elementType {
                case .marker, .keyword:
                    // markers and keywords use `start` attribute as an offset, so handle it specially
                    if let elementStart = ancestor.fcpStart {
                        if let ancestorParent = ancestor.parentElement,
                           let parentStart = ancestorParent.fcpStart
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
                    
                default:
                    break
                }
            }
            
            if let start = ancestor.fcpStart {
                lastStart = start
            }
        }
        
        return accum
    }
}

#endif
