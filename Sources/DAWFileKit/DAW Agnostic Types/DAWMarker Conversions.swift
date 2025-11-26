//
//  DAWMarker Conversions.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import TimecodeKitCore

extension DAWMarker {
    /// Computed property, not cached.
    /// Produces a timecode object from the marker's time data storage, after calculating the
    /// effective timecode by converting frame rates if necessary.
    public func resolvedTimecode(
        at newFrameRate: TimecodeFrameRate,
        base: Timecode.SubFramesBase,
        limit: Timecode.UpperLimit,
        startTimecode: Timecode
    ) -> Timecode? {
        switch timeStorage?.value {
        case let .realTime(secondsRelativeToStart):
            guard let realTimeDurationAsTimecode = try? Timecode(
                .realTime(seconds: secondsRelativeToStart),
                at: newFrameRate,
                base: base,
                limit: limit
            ),
                  let offsetTimecode = try? startTimecode.adding(realTimeDurationAsTimecode)
            else { return nil }
            
            return offsetTimecode
            
        case let .timecodeString(string):
            // if storage is a timecode string, we need original frame rate
            // if frame rates differ, convert timecode between them
            
            let usingFrameRate = timeStorage?.frameRate ?? newFrameRate
            
            var timecode = try? Timecode(
                .string(string),
                at: usingFrameRate,
                base: base,
                limit: limit
            )
            
            // if frame rates differ, convert
            
            if timeStorage?.frameRate != nil,
               timecode != nil,
               newFrameRate != timeStorage?.frameRate
            {
                timecode = try? Timecode(
                    .realTime(seconds: timecode!.realTimeValue),
                    at: newFrameRate,
                    base: base,
                    limit: limit
                )
            }
            
            return timecode
            
        case let .rational(fraction):
            guard let realTimeDurationAsTimecode = try? Timecode(
                .rational(fraction),
                at: newFrameRate,
                base: base,
                limit: limit
            ),
                let offsetTimecode = try? startTimecode.adding(realTimeDurationAsTimecode)
            else { return nil }
            
            return offsetTimecode
            
        case .none:
            return nil
        }
    }
    
    /// Computed property, not cached.
    /// Returns a timecode object constructed from the `timeStorage` contents.
    public func originalTimecode(
        base: Timecode.SubFramesBase,
        limit: Timecode.UpperLimit
    ) -> Timecode? {
        guard let timeStorage = timeStorage else { return nil }
        
        switch timeStorage.value {
        case let .realTime(secondsRelativeToStart):
            return try? Timecode(
                .realTime(seconds: secondsRelativeToStart),
                at: timeStorage.frameRate,
                base: base,
                limit: limit
            )
            
        case let .timecodeString(string):
            return try? Timecode(
                .string(string),
                at: timeStorage.frameRate,
                base: base,
                limit: limit
            )
            
        case let .rational(fraction):
            return try? Timecode(
                .rational(fraction),
                at: timeStorage.frameRate,
                base: base,
                limit: limit
            )
        }
    }
}
