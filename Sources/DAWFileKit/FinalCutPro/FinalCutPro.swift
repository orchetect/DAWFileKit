//
//  FinalCutPro.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation
import TimecodeKitCore

/// Collection of methods and structures related to Final Cut Pro.
/// Do not instance; use methods within directly.
public enum FinalCutPro {
    /// `Timecode` setting for `.subFramesBase`.
    /// Final Cut Pro uses 80 subframes per frame.
    public static let timecodeSubFramesBase: Timecode.SubFramesBase = .max80SubFrames
    
    /// `Timecode` setting for `.upperLimit`.
    /// Final Cut Pro is confined to a 24-hour SMPTE timecode clock.
    public static let timecodeUpperLimit: Timecode.UpperLimit = .max24Hours
    
    /// `Timecode` setting for `.stringFormat`.
    public static let timecodeStringFormat: Timecode.StringFormat = []
}

extension FinalCutPro {
    /// `Timecode` template.
    public static func formTimecode(
        at rate: TimecodeFrameRate
    ) -> Timecode {
        Timecode(
            .zero,
            at: rate,
            base: timecodeSubFramesBase,
            limit: timecodeUpperLimit
        )
    }
    
    /// `Timecode` template.
    public static func formTimecode(
        rational: Fraction,
        at rate: TimecodeFrameRate
    ) throws -> Timecode {
        try Timecode(
            .rational(rational),
            at: rate,
            base: timecodeSubFramesBase,
            limit: timecodeUpperLimit
        )
    }
    
    /// `Timecode` template.
    public static func formTimecode(
        realTime seconds: TimeInterval,
        at rate: TimecodeFrameRate
    ) throws -> Timecode {
        try Timecode(
            .realTime(seconds: seconds),
            at: rate,
            base: timecodeSubFramesBase,
            limit: timecodeUpperLimit
        )
    }
    
    /// `TimecodeInterval` template.
    public static func formTimecodeInterval(
        at rate: TimecodeFrameRate
    ) -> TimecodeInterval {
        let tc = formTimecode(at: rate)
        return TimecodeInterval(tc)
    }
    
    /// `TimecodeInterval` template.
    public static func formTimecodeInterval(
        realTime: TimeInterval,
        at rate: TimecodeFrameRate
    ) throws -> TimecodeInterval {
        
        try TimecodeInterval(
            realTime: realTime,
            at: rate,
            base: timecodeSubFramesBase,
            limit: timecodeUpperLimit
        )
    }
    
    /// `TimecodeInterval` template.
    public static func formTimecodeInterval(
        rational: Fraction,
        at rate: TimecodeFrameRate
    ) throws -> TimecodeInterval {
        try TimecodeInterval(
            rational,
            at: rate,
            base: timecodeSubFramesBase,
            limit: timecodeUpperLimit
        )
    }
}
