//
//  FinalCutPro.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation
import TimecodeKit

/// Collection of methods and structures related to Final Cut Pro.
/// Do not instance; use methods within directly.
public enum FinalCutPro {
    /// `Timecode` setting for `.subFramesBase`.
    /// Final Cut Pro uses 100 subframes per frame.
    public static let timecodeSubFramesBase: Timecode.SubFramesBase = ._100SubFrames
    
    /// `Timecode` setting for `.upperLimit`.
    /// Final Cut Pro is confined to a 24-hour SMPTE timecode clock.
    public static let timecodeUpperLimit: Timecode.UpperLimit = ._24hours
    
    /// `Timecode` setting for `.stringFormat`.
    public static let timecodeStringFormat: Timecode.StringFormat = []
    
    /// `Timecode` struct template.
    public static func formTimecode(
        rational: (numerator: Int, denominator: Int),
        at rate: TimecodeFrameRate
    ) throws -> Timecode {
        try Timecode(
            rational: rational,
            at: rate,
            limit: timecodeUpperLimit,
            base: timecodeSubFramesBase,
            format: timecodeStringFormat
        )
    }
    
    /// `Timecode` struct template.
    public static func formTimecode(
        at rate: TimecodeFrameRate
    ) -> Timecode {
        Timecode(
            at: rate,
            limit: timecodeUpperLimit,
            base: timecodeSubFramesBase,
            format: timecodeStringFormat
        )
    }
}
