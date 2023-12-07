//
//  FCPXML Element Occlusion.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import OTCore

extension FinalCutPro.FCPXML {
    /// Utility: Returns occlusion information.
    static func _occlusion(
        containerTimeRange: ClosedRange<Fraction>,
        internalStartTime: Fraction,
        internalEndTime: Fraction?
    ) -> ElementOcclusion {
        if let internalEndTime = internalEndTime {
            // internal element has duration, treat as a time range
            
            let internalTimeRange = internalStartTime ..< internalEndTime.clamped(to: internalStartTime...)
            
            if containerTimeRange.contains(internalTimeRange) {
                return .notOccluded
            }
            
            if containerTimeRange.overlaps(internalTimeRange),
               // don't allow exactly on container upper bound to qualify as overlap
               internalTimeRange.lowerBound < containerTimeRange.upperBound
            {
                return .partiallyOccluded
            } else {
                return .fullyOccluded
            }
        } else {
            // internal element does not have duration, treat as a single point in time
            
            let isContained = containerTimeRange.contains(internalStartTime)
            return isContained ? .notOccluded : .fullyOccluded
        }
    }
}

extension XMLElement {
    /// FCPXML: Returns effective occlusion information for the element through all of its ancestor
    /// containers.
    ///
    /// - Parameters:
    ///   - ancestors: Optional replacement for ancestors. Ordered nearest to furthest ancestor.
    func _fcpEffectiveOcclusion<S: Sequence<XMLElement>>(
        ancestors: S? = nil
    ) -> FinalCutPro.FCPXML.ElementOcclusion {
        let ancestors = ancestorElements(overrideWith: ancestors, includingSelf: false)
        
        guard var elementAbsStart = _fcpCalculateAbsoluteStart(
            ancestors: ancestors
        ) else { return .notOccluded }
        
        var elementAbsEnd: Fraction?
        if let elementDuration = fcpDuration {
            elementAbsEnd = elementAbsStart + elementDuration
        }
        
        var ancestorWalkedCount = 0
        var isPartial = false
        var lastLane: Int?
        
        for ancestor in ancestors {
            defer { ancestorWalkedCount += 1 }
            
            let value = ancestor.fcpLane
            let lane = value != nil ? Int(value!) : nil
            defer { lastLane = lane }
            
            if let getLastLane = lastLane {
                guard lane == getLastLane else { continue }
            }
            
            guard let ancestorAbsStart = ancestor._fcpCalculateAbsoluteStart(
                ancestors: ancestors
            ),
                let bcDuration = ancestor._fcpNearestDuration(
                    ancestors: ancestors.prefix(ancestorWalkedCount),
                    includingSelf: true
                )
            else { continue }
            
            let ancestorAbsEnd = ancestorAbsStart + bcDuration
            let ancestorRange = ancestorAbsStart ... ancestorAbsEnd
            
            let o = FinalCutPro.FCPXML._occlusion(
                containerTimeRange: ancestorRange,
                internalStartTime: elementAbsStart,
                internalEndTime: elementAbsEnd
            )
            
            if o == .fullyOccluded {
                return o
            }
            
            if o == .partiallyOccluded {
                // reduce exposed internal range
                elementAbsStart = elementAbsStart.clamped(to: ancestorRange)
                elementAbsEnd = elementAbsEnd?.clamped(to: ancestorRange)
                isPartial = true
            }
        }
        
        return isPartial ? .partiallyOccluded : .notOccluded
    }
}

#endif
