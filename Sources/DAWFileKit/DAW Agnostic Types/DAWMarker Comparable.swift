//
//  DAWMarker Comparable.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation
import TimecodeKit

extension DAWMarker: Equatable {
    public static func == (lhs: DAWMarker, rhs: DAWMarker) -> Bool {
        guard let lhsTC = lhs.convertToTimecodeForComparison(limit: .max100Days),
              let rhsTC = rhs.convertToTimecodeForComparison(limit: .max100Days)
        else { return false }
        
        return lhsTC == rhsTC
    }
}

extension DAWMarker: Comparable {
    // useful for sorting markers or comparing markers chronologically
    // this is purely linear, and does not consider 24-hour wrap around.
    public static func < (lhs: DAWMarker, rhs: DAWMarker) -> Bool {
        guard let lhsTC = lhs.convertToTimecodeForComparison(limit: .max100Days),
              let rhsTC = rhs.convertToTimecodeForComparison(limit: .max100Days)
        else { return false }
        
        return lhsTC < rhsTC
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
    public func compare(to other: DAWMarker, timelineStart: Timecode? = nil) -> ComparisonResult? {
        let limit: Timecode.UpperLimit = timelineStart?.upperLimit ?? .max24Hours
        
        guard let lhsTC = convertToTimecodeForComparison(limit: limit),
              let rhsTC = other.convertToTimecodeForComparison(limit: limit)
        else { return nil }
        
        return lhsTC.compare(to: rhsTC, timelineStart: timelineStart)
    }
}

// MARK: - Collection Ordering

extension Collection where Element == DAWMarker {
    /// Returns `true` if all ``DAWMarker`` instances are ordered chronologically, either ascending
    /// or descending according to the `ascending` parameter.
    /// Contiguous subsequences of identical timecode are allowed.
    /// Timeline length and wrap point is determined by the  `timelineStart`'s `upperLimit`
    /// property. The timeline is considered linear for 24 hours (or 100 days) from this start time,
    /// wrapping around the upper limit.
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
    public func isSorted(ascending: Bool = true,
                         timelineStart: Timecode? = nil) -> Bool? {
        guard count > 1 else { return true }
        
        let limit: Timecode.UpperLimit = timelineStart?.upperLimit ?? .max24Hours
        let timecodes = compactMap { $0.convertToTimecodeForComparison(limit: limit) }
        
        // if any markers failed to convert to timecode, abort
        guard timecodes.count == count else { return nil }
        
        return timecodes.isSorted(ascending: ascending, timelineStart: timelineStart)
    }
}

extension Collection where Element == DAWMarker {
    /// Returns a collection sorting all ``DAWMarker`` instances chronologically, either ascending
    /// or descending.
    /// Contiguous subsequences of identical timecode are allowed.
    /// Timeline length and wrap point is determined by the `timelineStart`'s `upperLimit`
    /// property. The timeline is considered linear for 24 hours (or 100 days) from this start time,
    /// wrapping around the upper limit.
    ///
    /// Sometimes a timeline does not have a zero start time (00:00:00:00). For example, many DAW
    /// software applications such as Pro Tools allows a project start time to be set to any
    /// timecode. Its timeline then extends for 24 hours from that timecode, wrapping around over
    /// 00:00:00:00 at some point along the timeline.
    ///
    /// Methods to sort and test sort order of `DAWMarker` collections are provided.
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
    public func sorted(ascending: Bool = true,
                       timelineStart: Timecode) -> [Element] {
        sorted {
            $0.compare(to: $1, timelineStart: timelineStart)
                != (ascending ? .orderedDescending : .orderedAscending )
        }
    }
}

extension MutableCollection
where Element == DAWMarker,
      Self: RandomAccessCollection,
      Element: Comparable
{
    /// Sorts the collection in place by sorting all ``DAWMarker`` instances chronologically, either
    /// ascending or descending.
    /// Contiguous subsequences of identical timecode are allowed.
    /// Timeline length and wrap point is determined by the `timelineStart`'s `upperLimit`
    /// property. The timeline is considered linear for 24 hours (or 100 days) from this start time,
    /// wrapping around the upper limit.
    ///
    /// Sometimes a timeline does not have a zero start time (00:00:00:00). For example, many DAW
    /// software applications such as Pro Tools allows a project start time to be set to any
    /// timecode. Its timeline then extends for 24 hours from that timecode, wrapping around over
    /// 00:00:00:00 at some point along the timeline.
    ///
    /// Methods to sort and test sort order of `DAWMarker` collections are provided.
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
    public mutating func sort(ascending: Bool = true,
                              timelineStart: Timecode) {
        sort {
            $0.compare(to: $1, timelineStart: timelineStart)
            != (ascending ? .orderedDescending : .orderedAscending )
        }
    }
}

// MARK: - Helpers

extension DAWMarker {
    fileprivate func convertToTimecodeForComparison(limit: Timecode.UpperLimit) -> Timecode? {
        originalTimecode(
            base: timeStorage?.base ?? .max80SubFrames,
            limit: limit
        )
    }
}
