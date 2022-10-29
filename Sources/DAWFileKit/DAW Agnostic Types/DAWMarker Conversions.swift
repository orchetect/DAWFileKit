//
//  DAWMarker Conversions.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import TimecodeKit

extension DAWMarker {
    /// Computed property, not cached.
    /// Produces a timecode object from the marker's time data storage, after calculating the effective timecode by converting frame rates if necessary.
    public func resolvedTimecode(
        at newFrameRate: Timecode.FrameRate,
        limit: Timecode.UpperLimit,
        base: Timecode.SubFramesBase
    ) -> Timecode? {
        switch timeStorage?.value {
        case let .realTime(time):
            // if storage is real time, we can form timecode without any additional information
            
            let timecode = try? Timecode(
                realTimeValue: time,
                at: newFrameRate,
                limit: limit,
                base: base
            )
            
            return timecode
            
        case let .timecodeString(string):
            // if storage is a timecode string, we need original frame rate
            // if frame rates differ, convert timecode between them
            
            let usingFrameRate = timeStorage?.frameRate ?? newFrameRate
            
            var timecode = try? Timecode(
                string,
                at: usingFrameRate,
                limit: limit,
                base: base
            )
            
            // if frame rates differ, convert
            
            if timeStorage?.frameRate != nil,
               timecode != nil,
               newFrameRate != timeStorage?.frameRate
            {
                timecode = try? Timecode(
                    realTimeValue: timecode!.realTimeValue,
                    at: newFrameRate,
                    limit: limit,
                    base: base
                )
            }
            
            return timecode
            
        case .none:
            return nil
        }
    }
    
    /// Computed property, not cached.
    /// Returns a timecode object constructed from the `timeStorage` contents.
    public func originalTimecode(
        limit: Timecode.UpperLimit,
        base: Timecode.SubFramesBase
    ) -> Timecode? {
        guard let timeStorage = timeStorage else { return nil }
        
        switch timeStorage.value {
        case let .realTime(time):
            let timecode = try? Timecode(
                realTimeValue: time,
                at: timeStorage.frameRate,
                limit: limit,
                base: base
            )
            
            return timecode
            
        case let .timecodeString(string):
            let timecode = try? Timecode(
                string,
                at: timeStorage.frameRate,
                limit: limit,
                base: base
            )
            
            return timecode
        }
    }
}
