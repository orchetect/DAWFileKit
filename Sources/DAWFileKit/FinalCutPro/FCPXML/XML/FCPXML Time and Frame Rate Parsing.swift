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
    ///   - resources: Optional replacement for resources.
    ///
    /// - Returns: Elapsed seconds from zero timecode as a floating-point `TimeInterval` (`Double`).
    func _fcpCalculateAbsoluteStart<S: Sequence<XMLElement>>(
        ancestors: S? = nil as [XMLElement]?,
        resources: XMLElement? = nil
    ) -> TimeInterval? {
        var accum: TimeInterval?
        var lastStart: TimeInterval?
        
        func add(_ value: TimeInterval?) {
            guard let value = value else { return }
            let base = accum ?? 0.0
            accum = base + value
        }
        
        // iterate from root to current element
        
        var ancestors = Array(ancestorElements(overrideWith: ancestors, includingSelf: true))
        
        while let ancestor = ancestors.popLast() {
            let elementType = ancestor.fcpElementType
            
            if let tcStart = ancestor.fcpTCStart {
                assert(ancestor.fcpStart == nil)
                
                add(tcStart.doubleValue)
                lastStart = tcStart.doubleValue
                
                continue
            }
            
            if let offset = ancestor.fcpOffset {
                if let _lastStart = lastStart {
                    let diff = offset.doubleValue - _lastStart
                    lastStart = nil
                    add(diff)
                } else {
                    add(offset.doubleValue)
                }
            }
            
            if let elementType = elementType {
                switch elementType {
                case .marker, .chapterMarker, .keyword:
                    // markers and keywords use `start` attribute as an offset, so handle it specially
                    if let elementStart = ancestor.fcpStart {
                        if let ancestorParent = ancestor.parentElement,
                           let parentStart = ancestorParent.fcpStart
                        {
                            let parentStartScaled = parentStart.doubleValue
                            
                            let diffScaled = elementStart.doubleValue - parentStartScaled
                            add(diffScaled)
                        } else {
                            add(elementStart.doubleValue)
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
                lastStart = start.doubleValue
            }
        }
        
        return accum
    }
    
    /// FCPXML: Returns the `conform-rate` element if it exists in the element's containing clip.
    func _fcpAncestorClipConformRate<S: Sequence<XMLElement>>(
        ancestors: S? = nil as [XMLElement]?,
        includeSelf: Bool = false
    ) -> FinalCutPro.FCPXML.ConformRate? {
        guard let container = fcpAncestorClip(ancestors: ancestors, includeSelf: includeSelf),
              let conformRate = container.firstChild(whereFCPElement: .conformRate)
        else { return nil }
        
        return conformRate
    }
    
    /// FCPXML: Finds the element's containing clip (if any) and if it contains a `conform-rate` element, the time
    /// scaling factor is returned.
    ///
    /// Scaling is based on source (local timeline) frame rate and parent (sequence) frame rate:
    ///
    /// `childTime x (SFD / MFD)`
    /// 
    /// Where:
    /// 
    /// - `childTime` is a rational fraction time value of a child of the scaling clip
    /// - `SFD` is the sequence/parent frame duration (ie: 1/24), and
    /// - `MFD` is the media frame duration derived from the `srcFrameRate` attribute of the clip's `conform-rate` child element
    /// 
    /// - Parameters:
    ///   - ancestors: Optional replacement for ancestors. Ordered nearest to furthest ancestor.
    ///   - sequenceFrameRate: Optionally supply the sequence/parent's timecode frame rate if known.
    ///     Otherwise it will be auto-discovered if possible.
    ///   - includeSelf: Include the current element in the search for the containing clip.
    ///   - resources: Optional replacement for resources.
    ///
    /// - Returns: Scaling factor which which to multiply child time values of the clip.
    func _fcpConformRateScalingFactor<S: Sequence<XMLElement>>(
        ancestors: S? = nil as [XMLElement]?,
        sequenceFrameRate: TimecodeFrameRate? = nil,
        includeSelf: Bool = false,
        resources: XMLElement? = nil
    ) -> Double? {
        guard let container = fcpAncestorClip(ancestors: ancestors, includeSelf: includeSelf),
              let conformRate = _fcpAncestorClipConformRate(ancestors: ancestors, includeSelf: includeSelf),
              conformRate.scaleEnabled,
              let mediaFrameRate = conformRate.srcFrameRate
        else { return nil }
        
        guard let sequenceFrameRate = sequenceFrameRate
                ?? container.parentElement?._fcpTimecodeFrameRate(
                    source: .localToElement,
                    breadcrumbs: ancestors,
                    resources: resources
                )
        else { return nil }
        
        let seqFrameDuration = sequenceFrameRate.frameDuration.doubleValue
        let mediaFrameDuration = mediaFrameRate.timecodeFrameRate.frameDuration.doubleValue
        
        return seqFrameDuration / mediaFrameDuration
    }
}

#endif
