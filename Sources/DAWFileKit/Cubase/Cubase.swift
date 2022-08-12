//
//  Cubase.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//

import Foundation
import TimecodeKit

/// Collection of methods and structures related to Cubase.
/// Do not instance; use methods within directly.
public enum Cubase {
    public typealias PPQ = Double
    public typealias Tempo = Double
    
    /// `Timecode` setting for `.subFramesBase`.
    /// Cubase uses 80 subframes per frame.
    public static let kTimecodeSubFramesBase: Timecode.SubFramesBase = ._80SubFrames
    
    /// `Timecode` setting for `.upperLimit`.
    /// Cubase allows for up to 100 days, not confined to a 24-hour SMPTE timecode clock.
    public static let kTimecodeUpperLimit: Timecode.UpperLimit = ._100days
    
    /// `Timecode` setting for `.stringFormat`.
    public static let kTimecodeStringFormat: Timecode.StringFormat = []
    
    /// `Timecode` struct template.
    public static func kTimecode(
        realTimeValue: Double,
        at rate: Timecode.FrameRate
    ) -> Timecode? {
        try? Timecode(
            realTimeValue: realTimeValue,
            at: rate,
            limit: kTimecodeUpperLimit,
            base: kTimecodeSubFramesBase,
            format: kTimecodeStringFormat
        )
    }
}
