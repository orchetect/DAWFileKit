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
        // don't allow element start exactly on container upper bound
        let startWithinParent = containerTimeRange.contains(internalStartTime) &&
            internalStartTime < containerTimeRange.upperBound
        
        guard startWithinParent else { return .fullyOccluded }
        
        guard let internalEndTime = internalEndTime else {
            return .notOccluded
        }
        
        let internalTimeRange = internalStartTime ..< internalEndTime
        
        if containerTimeRange.contains(internalStartTime),
           containerTimeRange.contains(internalEndTime) {
            return .notOccluded
        }
        
        if internalTimeRange.overlaps(containerTimeRange) {
            return .partiallyOccluded
        }
        
        return .fullyOccluded
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
        
        guard var internalAbsStart = _fcpCalculateAbsoluteStart(
            ancestors: ancestors
        ) else { return .notOccluded }
        
        var internalAbsEnd: Fraction?
        if let elementDuration = fcpDuration {
            internalAbsEnd = internalAbsStart + elementDuration
        }
        
        var ancestorWalkedCount = 0
        var isPartial = false
        var lastLane: Int?
        
        for ancestor in ancestors {
            ancestorWalkedCount += 1
            let partialAncestors = ancestors.dropFirst(ancestorWalkedCount)
            
            let value = ancestor.fcpLane
            let lane = value != nil ? Int(value!) : nil
            defer { lastLane = lane }
            
            if let getLastLane = lastLane {
                guard lane == getLastLane else { continue }
            }
            
            guard let ancestorAbsStart = ancestor._fcpCalculateAbsoluteStart(
                ancestors: partialAncestors
            ),
                let ancestorDuration = ancestor._fcpNearestDuration(
                    ancestors: partialAncestors,
                    includingSelf: true
                )
            else { continue }
            
            let ancestorAbsEnd = ancestorAbsStart + ancestorDuration
            let ancestorRange = ancestorAbsStart ... ancestorAbsEnd
            
            // if fcpElementType == .story(.sequence) {
            //     _ = Void() // set breakpoint for debugging on this line
            // }
            
            let o = FinalCutPro.FCPXML._occlusion(
                containerTimeRange: ancestorRange,
                internalStartTime: internalAbsStart,
                internalEndTime: internalAbsEnd
            )
            
            // print(self.name!, stringValue(forAttributeNamed: "value") ?? "",
            //       o, ([ancestor] + partialAncestors).map(\.name!))
            
            if o == .fullyOccluded {
                return o
            }
            
            if o == .partiallyOccluded {
                // reduce exposed internal range
                internalAbsStart = internalAbsStart.clamped(to: ancestorRange)
                internalAbsEnd = internalAbsEnd?.clamped(to: ancestorRange)
                isPartial = true
            }
        }
        
        let result: FinalCutPro.FCPXML.ElementOcclusion = isPartial ? .partiallyOccluded : .notOccluded
        
        // print(self.name!, stringValue(forAttributeNamed: "value") ?? "",
        //       result, "-> return")
        
        return result
    }
}

#endif
