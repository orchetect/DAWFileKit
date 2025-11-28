//
//  FCPXML Time and Frame Rate Parsing.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import SwiftTimecodeCore
import SwiftExtensions

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
                    add(diff)
                    if elementType != .transition {
                        lastStart = nil
                    }
                } else {
                    add(offset.doubleValue)
                }
            }
            
            if let elementType {
                switch elementType {
                case .marker, .chapterMarker, .keyword:
                    // markers and keywords use `start` attribute as an offset, so handle it specially
                    if let elementStart = ancestor.fcpStart {
                        if let ancestorParent = ancestor.parentElement {
                            if ancestorParent.fcpElementType == .transition,
                               let lastStart
                            {
                                let diff = elementStart.doubleValue - lastStart
                                add(diff)
                            } else if let parentStart = ancestorParent.fcpStart {
                                let diff = elementStart.doubleValue - parentStart.doubleValue
                                add(diff)
                            } else {
                                add(elementStart.doubleValue)
                            }
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
    
    /// FCPXML: Finds the element's containing clip (if any) and if it contains a `conform-rate` element, the time
    /// scaling factor is returned.
    ///
    /// Scaling is based on source (local timeline) frame rate and parent timeline frame rate.
    ///
    /// - Parameters:
    ///   - ancestors: Optional replacement for ancestors. Ordered nearest to furthest ancestor.
    ///   - timelineFrameRate: Optionally supply the parent's timecode frame rate if known.
    ///     Otherwise it will be auto-discovered if possible.
    ///   - includingSelf: Include the current element in the search for the containing clip.
    ///   - resources: Optional replacement for resources.
    ///
    /// - Returns: Scaling factor which which to multiply child time values of the clip.
    ///
    /// See [`conform-rate` documentation.](https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/story_elements/conform-rate)
    func _fcpConformRateScalingFactor<S: Sequence<XMLElement>>(
        ancestors: S? = nil as [XMLElement]?,
        timelineFrameRate: TimecodeFrameRate? = nil,
        includingSelf: Bool,
        resources: XMLElement? = nil
    ) -> Double? {
        guard let (container, remainingAncestors) = fcpAncestorTimeline(
            ancestors: ancestors,
            includingSelf: includingSelf
        ),
            let conformRate = container.firstChild(whereFCPElement: .conformRate),
            conformRate.scaleEnabled,
            let mediaFrameRate = conformRate.srcFrameRate?.timecodeFrameRate
        else { return nil }
        
        var timelineFrameRate = timelineFrameRate
        if timelineFrameRate == nil,
           let (parent, remainingAncestors) = container._fcpFirstContainerAncestorWithZeroLane(
               ancestors: remainingAncestors,
               includingSelf: false
           )
        {
            timelineFrameRate = parent._fcpTimecodeFrameRate(
                source: .localToElement,
                breadcrumbs: remainingAncestors,
                resources: resources
            )
        }
        
        guard let timelineFrameRate else { return nil }
        
        // FCPXML shouldn't request conforming between the same frame rate
        assert(timelineFrameRate != mediaFrameRate)
        
        let scalingFactor = Self._fcpConformRateScalingFactor(
            timelineFrameRate: timelineFrameRate,
            mediaFrameRate: mediaFrameRate
        )
        
        return scalingFactor
    }
    
    /// Returns the first ancestor with a lane of `0`.
    ///
    /// Ancestors are ordered nearest to furthest.
    func _fcpFirstAncestorWithZeroLane<S: Sequence<XMLElement>>(
        ancestors: S? = nil as [XMLElement]?,
        includingSelf: Bool
    ) -> (element: XMLElement, remainingAncestors: AnySequence<XMLElement>)? {
        var ancestors = ancestorElements(overrideWith: ancestors, includingSelf: includingSelf)
        
        for ancestor in ancestors {
            ancestors = ancestors.dropFirst()
            if (ancestor.fcpLane ?? 0) == 0 {
                return (element: ancestor, remainingAncestors: ancestors)
            }
        }
        
        return nil
    }
    
    /// Returns the first container ancestor with a lane of `0`.
    ///
    /// Ancestors are ordered nearest to furthest.
    func _fcpFirstContainerAncestorWithZeroLane<S: Sequence<XMLElement>>(
        ancestors: S? = nil as [XMLElement]?,
        includingSelf: Bool
    ) -> (element: XMLElement, remainingAncestors: AnySequence<XMLElement>)? {
        var ancestors = ancestorElements(overrideWith: ancestors, includingSelf: includingSelf)
        let types: Set<FinalCutPro.FCPXML.ElementType> = // .allTimelineCases
        [
            /*.refClip, .syncClip, .mcClip,*/ .sequence, .spine, .mcAngle
        ]
        
        for ancestor in ancestors {
            ancestors = ancestors.dropFirst()
            
            let isAssetClip = ancestor.fcpElementType != nil
                && ancestor.fcpElementType == .assetClip
            
            let nextAncestor = ancestors.first { _ in true }?.fcpElementType
            let nextAncestorIsAssetClip = nextAncestor != nil 
                && nextAncestor == .assetClip
            
            if let elementType = ancestor.fcpElementType,
               types.contains(elementType),
               (ancestor.fcpLane ?? 0) == 0,
               !(isAssetClip && nextAncestorIsAssetClip)
            {
                return (element: ancestor, remainingAncestors: ancestors)
            }
        }
        
        return nil
    }
    
    /// Table of conform scaling factors.
    ///
    /// See [`conform-rate` documentation.](https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/story_elements/conform-rate)
    static func _fcpConformRateScalingFactor(
        timelineFrameRate: TimecodeFrameRate,
        mediaFrameRate: TimecodeFrameRate
    ) -> Double? {
        let t = timelineFrameRate.frameDuration.doubleValue
        let m = mediaFrameRate.frameDuration.doubleValue
        
        // TODO: some of these values may be wrong. need to test more frame rates.
        
        switch mediaFrameRate.compatibleGroup {
        case .ntscColor: // 23.976, 29.97, etc.
            switch timelineFrameRate.compatibleGroup {
            case .ntscColor:
                switch mediaFrameRate {
                case .fps23_976, .fps47_952:
                    switch timelineFrameRate {
                    case .fps23_976, .fps47_952: return nil
                    case .fps29_97, .fps59_94, .fps119_88: return 1 / 1.001
                    default: break
                    }
                case .fps29_97, .fps59_94, .fps119_88:
                    switch timelineFrameRate {
                    case .fps23_976, .fps47_952: return 1.001
                    case .fps29_97, .fps59_94, .fps119_88: return nil
                    default: break
                    }
                default: return nil
                }
                return nil
            case .ntscColorWallTime:
                return nil // not used by FCP
            case .ntscDrop:
                return nil
            case .whole:
                return 1 / 1.001 // works for 60fps timeline -> 23.98 media
            }
            
        case .ntscColorWallTime: // 30d, 60d - not used by FCP
            return nil
            
        case .ntscDrop: // 29.97d, 59.94d
            switch timelineFrameRate.compatibleGroup {
            case .ntscColor: 
                return t / m
            case .ntscColorWallTime:
                return nil // not used by FCP
            case .ntscDrop:
                return nil
            case .whole:
                return t / m
            }
            
        case .whole: // 24, 25, 30, 60
            switch timelineFrameRate.compatibleGroup {
            case .ntscColor: 
                return t / m // works for 23.98 timeline -> 25 media
            case .ntscColorWallTime:
                return nil // not used by FCP
            case .ntscDrop:
                return m / t
            case .whole:
                switch timelineFrameRate {
                case .fps24:
                    switch mediaFrameRate {
                    case .fps25: return t / m
                    default: return nil
                    }
                case .fps25:
                    switch mediaFrameRate {
                    case .fps24: return m / t // TODO: experimental until tested
                    default: return nil
                    }
                default: return nil
                }
            }
        }
    }
}

#endif
