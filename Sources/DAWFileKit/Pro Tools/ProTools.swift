//
//  ProTools.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//

import TimecodeKit

/// Collection of methods and structures related to Pro Tools.
/// Do not instance; use methods within directly.
public class ProTools {
    
    /// `Timecode` setting for `.subFramesBase`.
    /// Pro Tools uses 100 subframes per frame.
    public static let kTimecodeSubFramesBase: Timecode.SubFramesBase = ._100SubFrames
    
    /// `Timecode` setting for `.upperLimit`.
    /// Pro Tools uses a 24-hour SMPTE timecode clock.
    public static let kTimecodeUpperLimit: Timecode.UpperLimit = ._24hours
    
    /// `Timecode` setting for `.stringFormat`.
    public static let kTimecodeStringFormat: Timecode.StringFormat = []
    
    /// `Timecode` struct template.
    public static func kTimecode(_ exactly: Timecode.Components,
                                 at rate: Timecode.FrameRate) -> Timecode? {
        
        Timecode(exactly,
                 at: rate,
                 limit: kTimecodeUpperLimit,
                 base: kTimecodeSubFramesBase,
                 format: kTimecodeStringFormat)
        
    }
    
    /// `Timecode` struct template.
    public static func kTimecode(_ exactly: String,
                                 at rate: Timecode.FrameRate) -> Timecode? {
        
        Timecode(exactly,
                 at: rate,
                 limit: kTimecodeUpperLimit,
                 base: kTimecodeSubFramesBase,
                 format: kTimecodeStringFormat)
        
    }
    
    /// `Timecode` struct template.
    public static func kTimecode(realTimeValue: Double,
                                 at rate: Timecode.FrameRate) -> Timecode? {
        
        Timecode(realTimeValue: realTimeValue,
                 at: rate,
                 limit: kTimecodeUpperLimit,
                 base: kTimecodeSubFramesBase,
                 format: kTimecodeStringFormat)
        
    }
    
    private init() { }
    
}
