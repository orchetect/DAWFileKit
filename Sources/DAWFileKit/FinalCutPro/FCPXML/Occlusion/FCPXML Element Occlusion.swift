//
//  FCPXML Element Occlusion.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import SwiftExtensions

extension FinalCutPro.FCPXML {
    /// Utility: Returns occlusion information.
    static func _occlusion(
        container: ClosedRange<TimeInterval>,
        internalStart: TimeInterval,
        internalEnd: TimeInterval?
    ) -> ElementOcclusion {
        // perform rounding to prevent floating-point precision from interfering
        let dp = 8
        let cStart = container.lowerBound.rounded(decimalPlaces: dp)
        let cEnd = container.upperBound.rounded(decimalPlaces: dp)
        let cRange = cStart ... cEnd
        let iStart = internalStart.rounded(decimalPlaces: dp)
        let iEnd = internalEnd?.rounded(decimalPlaces: dp)
        
        // don't allow element start exactly on container upper bound
        let isStartWithinParent = cRange.contains(iStart) && iStart < cEnd
        
        guard isStartWithinParent else { return .fullyOccluded }
        
        guard let iEnd = iEnd else {
            return .notOccluded
        }
        
        let isEndWithinParent = iEnd <= cEnd
        
        if isEndWithinParent {
            return .notOccluded
        }
        
        if (iStart ..< iEnd).overlaps(cRange) {
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
        ancestors: S? = nil as [XMLElement]?
    ) -> FinalCutPro.FCPXML.ElementOcclusion {
        let ancestors = ancestorElements(overrideWith: ancestors, includingSelf: false)
        
        guard var internalAbsStart = _fcpCalculateAbsoluteStart(
            ancestors: ancestors
        ) else { return .notOccluded }
        
        var internalAbsEnd: TimeInterval?
        if let elementDuration = fcpDuration {
            internalAbsEnd = internalAbsStart + elementDuration.doubleValue
        }
        
        var ancestorWalkedCount = 0
        var isPartial = false
        var lastLane: Int?
        
        for ancestor in ancestors {
            ancestorWalkedCount += 1
            let partialAncestors = ancestors.dropFirst(ancestorWalkedCount)
            
            let getLane = ancestor.fcpLane
            let lane = getLane != nil ? Int(getLane!) : nil
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
            
            let ancestorAbsEnd = ancestorAbsStart + ancestorDuration.doubleValue
            let ancestorRange = ancestorAbsStart ... ancestorAbsEnd
            
            // if fcpElementType == .story(.sequence) {
            //     _ = Void() // set breakpoint for debugging on this line
            // }
            
            let o = FinalCutPro.FCPXML._occlusion(
                container: ancestorRange,
                internalStart: internalAbsStart,
                internalEnd: internalAbsEnd
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
