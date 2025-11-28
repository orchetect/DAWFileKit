//
//  ProTools.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation
import SwiftTimecodeCore

/// Collection of methods and structures related to Pro Tools.
public enum ProTools {
    /// `Timecode` setting for `.subFramesBase`.
    /// Pro Tools uses 100 subframes per frame.
    public static let timecodeSubFramesBase: Timecode.SubFramesBase = .max100SubFrames
    
    /// `Timecode` setting for `.upperLimit`.
    /// Pro Tools uses a 24-hour SMPTE timecode clock.
    public static let timecodeUpperLimit: Timecode.UpperLimit = .max24Hours
    
    /// `Timecode` setting for `.stringFormat`.
    public static let timecodeStringFormat: Timecode.StringFormat = []
}

extension ProTools {
    /// `Timecode` struct template.
    public static func formTimecode(
        _ exactly: Timecode.Components,
        at rate: TimecodeFrameRate
    ) throws -> Timecode {
        try Timecode(
            .components(exactly),
            at: rate,
            base: timecodeSubFramesBase,
            limit: timecodeUpperLimit
        )
    }
    
    /// `Timecode` struct template.
    public static func formTimecode(
        _ exactly: String,
        at rate: TimecodeFrameRate
    ) throws -> Timecode {
        try Timecode(
            .string(exactly),
            at: rate,
            base: timecodeSubFramesBase,
            limit: timecodeUpperLimit
        )
    }
    
    /// `Timecode` struct template.
    public static func formTimecode(
        realTimeValue: TimeInterval,
        at rate: TimecodeFrameRate
    ) throws -> Timecode {
        try Timecode(
            .realTime(seconds: realTimeValue),
            at: rate,
            base: timecodeSubFramesBase,
            limit: timecodeUpperLimit
        )
    }
}
