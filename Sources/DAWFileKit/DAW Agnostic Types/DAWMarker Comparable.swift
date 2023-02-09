//
//  DAWMarker Comparable.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation
import TimecodeKit

extension DAWMarker: Comparable {
    // useful for sorting markers or comparing markers chronologically
    // this is purely linear, and does not consider 24-hour wrap around.
    public static func < (lhs: DAWMarker, rhs: DAWMarker) -> Bool {
        let lhsSFD = lhs.timeStorage?.base ?? ._80SubFrames
        let rhsSFD = rhs.timeStorage?.base ?? ._80SubFrames
        
        if let lhsTC = lhs.originalTimecode(
            limit: ._100days,
            base: lhsSFD
        ),
            let rhsTC = rhs.originalTimecode(
                limit: ._100days,
                base: rhsSFD
            )
        {
            return lhsTC < rhsTC
            
        } else {
            return false
        }
    }
}

extension DAWMarker {
    /// Compare two ``DAWMarker`` instances, optionally using a timeline that does not start at
    /// 00:00:00:00. Timeline length and wrap point is determined by the `timelineStart`'s
    /// `upperLimit` property. The timeline is considered linear for 24 hours (or
    /// 100 days) from this start time, wrapping around the upper limit.
    ///
    /// Sometimes a timeline does not have a zero start time (00:00:00:00). For example, many DAW
    /// software applications such as Pro Tools allows a project start time to be set to any
    /// timecode. Its timeline then extends for 24 hours from that timecode, wrapping around over
    /// 00:00:00:00 at some point along the timeline.
    ///
    /// Methods to sort and test sort order of `Timecode` collections are provided.
    ///
    /// For example, given a 24 hour limit:
    ///
    /// - A timeline start of 00:00:00:00:
    ///
    ///   24 hours elapses from 00:00:00:00 → 23:59:59:XX (where XX is max frame - 1)
    ///
    /// - A timeline start of 20:00:00:00:
    ///
    ///   24 hours elapses from 20:00:00:00 → 00:00:00:00 → 19:59:59:XX (where XX is max frame - 1)
    ///
    /// This would mean for example, that 21:00:00:00 is `<` 00:00:00:00 since it is earlier in the
    /// wrapping timeline, and 18:00:00:00 is `>` 21:00:00:00 since it is later in the wrapping
    /// timeline.
    ///
    /// Note that passing `timelineStart` of `nil` or zero (00:00:00:00) is the same as using the
    /// standard  `<`, `==`, or  `>` operators as a sort comparator.
    public func compare(to other: DAWMarker, timelineStart: Timecode? = nil) -> ComparisonResult {
        let lhsSFD = timeStorage?.base ?? ._80SubFrames
        let rhsSFD = other.timeStorage?.base ?? ._80SubFrames
        
        let limit: Timecode.UpperLimit = timelineStart?.upperLimit ?? ._24hours
        
        if let lhsTC = originalTimecode(
            limit: limit,
            base: lhsSFD
        ),
           let rhsTC = other.originalTimecode(
            limit: limit,
            base: rhsSFD
           )
        {
            return lhsTC.compare(to: rhsTC, timelineStart: timelineStart)
            
        } else {
            return .orderedSame // TODO: throw an error instead?
        }
    }
}

extension DAWMarker: Equatable {
    public static func == (lhs: DAWMarker, rhs: DAWMarker) -> Bool {
        let lhsSFD = lhs.timeStorage?.base ?? ._80SubFrames
        let rhsSFD = rhs.timeStorage?.base ?? ._80SubFrames
        
        if let lhsTC = lhs.originalTimecode(
            limit: ._100days,
            base: lhsSFD
        ),
            let rhsTC = rhs.originalTimecode(
                limit: ._100days,
                base: rhsSFD
            )
        {
            return lhsTC == rhsTC
            
        } else {
            return false
        }
    }
}
