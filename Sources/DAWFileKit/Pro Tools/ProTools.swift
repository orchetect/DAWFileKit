//
//  ProTools.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation
import TimecodeKit

/// Collection of methods and structures related to Pro Tools.
public enum ProTools {
    /// `Timecode` setting for `.subFramesBase`.
    /// Pro Tools uses 100 subframes per frame.
    public static let timecodeSubFramesBase: Timecode.SubFramesBase = ._100SubFrames
    
    /// `Timecode` setting for `.upperLimit`.
    /// Pro Tools uses a 24-hour SMPTE timecode clock.
    public static let timecodeUpperLimit: Timecode.UpperLimit = ._24hours
    
    /// `Timecode` setting for `.stringFormat`.
    public static let timecodeStringFormat: Timecode.StringFormat = []
    
    /// `Timecode` struct template.
    public static func formTimecode(
        _ exactly: Timecode.Components,
        at rate: TimecodeFrameRate
    ) throws -> Timecode {
        try Timecode(
            exactly,
            at: rate,
            limit: timecodeUpperLimit,
            base: timecodeSubFramesBase,
            format: timecodeStringFormat
        )
    }
    
    /// `Timecode` struct template.
    public static func formTimecode(
        _ exactly: String,
        at rate: TimecodeFrameRate
    ) throws -> Timecode {
        try Timecode(
            exactly,
            at: rate,
            limit: timecodeUpperLimit,
            base: timecodeSubFramesBase,
            format: timecodeStringFormat
        )
    }
    
    /// `Timecode` struct template.
    public static func formTimecode(
        realTimeValue: Double,
        at rate: TimecodeFrameRate
    ) throws -> Timecode {
        try Timecode(
            realTime: realTimeValue,
            at: rate,
            limit: timecodeUpperLimit,
            base: timecodeSubFramesBase,
            format: timecodeStringFormat
        )
    }
}
