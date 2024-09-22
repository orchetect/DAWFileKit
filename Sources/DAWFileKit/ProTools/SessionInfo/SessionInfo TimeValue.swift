//
//  SessionInfo TimeValue.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation
import TimecodeKit

extension ProTools.SessionInfo {
    public enum TimeValue: Equatable, Hashable {
        /// Timecode at the project frame rate.
        ///
        /// Pro Tools always uses a subframe base of 100 subframes per frame.
        case timecode(Timecode)
        
        /// Min:Secs time format.
        /// This can either be `MM:SS` or `MM:SS.sss` (where `sss` is milliseconds).
        case minSecs(min: Int, sec: Int, ms: Int?)
        
        /// Elapsed audio samples since the project start.
        ///
        /// Refer to ``ProTools/SessionInfo/main-swift.property``.``ProTools/SessionInfo/Main-swift.struct/sampleRate``
        /// for project sample rate.
        case samples(Int)
        
        /// Bars and Beats (musical).
        /// Ticks (quarter note division) is only present when the _Show Subframes_ option is
        /// enabled in Pro Tools' Export Session Text window while exporting. Pro Tools uses a PPQ
        /// base of 960 ticks per quarter.
        case barsAndBeats(bar: Int, beat: Int, ticks: Int?)
        
        /// Feet and Frames.
        ///
        /// This can either be `FT:FR` or `FT:FR.sf` (where `sf` is subframes).
        ///
        /// SubFrames is only present when the _Show Subframes_ option is enabled in Pro Tools'
        /// Export Session Text window while exporting. Pro Tools uses a PPQ base of 960 ticks per
        /// quarter.
        case feetAndFrames(feet: Int, frames: Int, subFrames: Int?)
    }
}

extension ProTools.SessionInfo.TimeValue: Identifiable {
    public var id: Self { self }
}

extension ProTools.SessionInfo.TimeValue: Sendable { }

extension ProTools.SessionInfo.TimeValue {
    /// Returns the corresponding ``TimeValueFormat`` case for the time value.
    public var format: ProTools.SessionInfo.TimeValueFormat {
        switch self {
        case .timecode: return .timecode
        case .minSecs: return .minSecs
        case .samples: return .samples
        case .barsAndBeats: return .barsAndBeats
        case .feetAndFrames: return .feetAndFrames
        }
    }
}

// MARK: - Umbrella Methods

extension ProTools.SessionInfo {
    /// Form a ``TimeValue`` instance from a time string with unknown format.
    /// Employs a format detection heuristic to attempt to determine the time format of the given
    /// time string.
    static func formTimeValue(
        heuristic source: String,
        at frameRate: TimecodeFrameRate?
    ) throws -> TimeValue {
        let detectedFormat = try TimeValueFormat(heuristic: source)
        return try formTimeValue(
            source: source,
            at: frameRate,
            format: detectedFormat
        )
    }
    
    /// Form a ``TimeValue`` instance from a time string with a known format.
    /// This is simply a proxy method that calls the specific time format method.
    static func formTimeValue(
        source: String,
        at frameRate: TimecodeFrameRate?,
        format: TimeValueFormat
    ) throws -> TimeValue {
        switch format {
        case .timecode:
            guard let frameRate = frameRate else {
                throw ParseError.general("Frame rate is required to form timecode.")
            }
            return try formTimeValue(timecodeString: source, at: frameRate)
        case .minSecs:
            return try formTimeValue(minSecsString: source)
        case .barsAndBeats:
            return try formTimeValue(barsAndBeatsString: source)
        case .samples:
            return try formTimeValue(samplesString: source)
        case .feetAndFrames:
            return try formTimeValue(feetAndFramesString: source)
        }
    }
}

// MARK: - Format-Specific Methods

extension ProTools.SessionInfo {
    /// Form a ``TimeValue/timecode(_:)`` instance from timecode string.
    /// Timecode is validated at the given frame rate and an error is thrown if invalid.
    /// Ancillary timecode metadata is automatically derived from ``ProTools`` constants.
    static func formTimeValue(
        timecodeString: String,
        at frameRate: TimecodeFrameRate
    ) throws -> TimeValue {
        let timecode = try ProTools.formTimecode(timecodeString, at: frameRate)
        return .timecode(timecode)
    }
    
    /// Form a ``TimeValue/minSecs(min:sec:)`` instance from timecode string.
    /// This can either be `MM:SS` or `MM:SS.sss` (where `sss` is milliseconds).
    /// An error is thrown if the string is malformed.
    static func formTimeValue(
        minSecsString: String
    ) throws -> TimeValue {
        // first two capture groups are mandatory: HH and SS
        // the fifth capture group will be milliseconds if present, or empty if not present
        let regExPattern = #"^(\d+):(\d{2})((.)(\d{3})){0,1}$"#
        
        // regexMatches() - the first array element is the entire match,
        // so capture groups begin at array index 1
        let captures = minSecsString.regexMatches(captureGroupsFromPattern: regExPattern)
        
        guard captures.count == 6 else {
            throw ParseError.general(
                "Min:Secs value is malformed."
            )
        }
        guard let min = captures[1]?.uInt?.intExactly, // UInt avoids negative ints
              let sec = captures[2]?.uInt?.intExactly  // UInt avoids negative ints
        else {
            throw ParseError.general(
                "Min:Secs value is malformed."
            )
        }
        
        let ms: Int?
        if captures[5] == nil || captures[5] == "" {
            ms = nil
        } else {
            if let msInt = captures[5]?.uInt?.int { // UInt avoids negative ints
                ms = msInt
            } else {
                throw ParseError.general(
                    "Min:Secs value is malformed. Milliseconds component was present but was not a valid integer."
                )
            }
        }
        
        return .minSecs(min: min, sec: sec, ms: ms)
    }
    
    /// Form a ``TimeValue/samples(_:)`` instance from a samples number string.
    /// An error is thrown if the string is not a valid integer.
    static func formTimeValue(
        samplesString: String
    ) throws -> TimeValue {
        guard let samples = samplesString.uInt?.intExactly // UInt avoids negative ints
        else {
            throw ParseError.general(
                "Samples value was not an integer."
            )
        }
        return .samples(samples)
    }
    
    /// Form a ``TimeValue/barsAndBeats(bar:beat:ticks:)`` instance from a bars and beats string.
    /// Expected formats: "Bar|Beat" or "Bar|Beat|Ticks".
    /// (ie: "5|3" or "17|2|685" or "17|2| 24")
    /// An error is thrown if the string is malformed.
    static func formTimeValue(
        barsAndBeatsString: String
    ) throws -> TimeValue {
        let slices = barsAndBeatsString
            .split(separator: "|", omittingEmptySubsequences: false)
        
        guard (2 ... 3).contains(slices.count),
              !slices[0].isEmpty,
              !slices[1].isEmpty,
              let bar = slices[0].uInt?.intExactly, // UInt avoids negative ints
              let beat = slices[1].uInt?.intExactly // UInt avoids negative ints
        else {
            throw ParseError.general(
                "Value was not recognized as either Bar|Beat or Bar|Beat|Ticks format: \(barsAndBeatsString.quoted)."
            )
        }
        
        // beat subdivision (ticks) may not be present but that is not an error condition.
        // instead of providing 0, provide nil.
        // the reasons is that if ticks are not present in the text file, it is because
        // are simply omitted by Pro Tools and they may not necessarily be 0 in the actual project
        let ticks: Int?
        if slices.count > 2 {
            if slices[2].count == 4,
               slices[2].trimmed.count == 3,
               let t = slices[2].trimmed.uInt?.intExactly // UInt avoids negative ints
            {
                ticks = t
            } else {
                throw ParseError.general(
                    "Value was not recognized as either Bar|Beat or Bar|Beat|Ticks format: \(barsAndBeatsString.quoted)."
                )
            }
        } else {
            ticks = nil
        }
        
        return .barsAndBeats(bar: bar, beat: beat, ticks: ticks)
    }
    
    /// Form a ``TimeValue/feetAndFrames(feet:frames:subFrames:)`` instance from raw string.
    /// This can either be `FT+FR` or `FT+FR.sf` (where `sf` is subframes).
    /// An error is thrown if the string is malformed.
    static func formTimeValue(
        feetAndFramesString: String
    ) throws -> TimeValue {
        // first two capture groups are mandatory: FT and FR
        // the fifth capture group will be subframes if present, or empty if not present
        let regExPattern = #"^(\d+)\+(\d{2})((.)(\d{2})){0,1}$"#
        
        // regexMatches() - the first array element is the entire match,
        // so capture groups begin at array index 1
        let captures = feetAndFramesString.regexMatches(captureGroupsFromPattern: regExPattern)
        
        guard captures.count == 6 else {
            throw ParseError.general(
                "Feet+Frames value is malformed: invalid number of value components."
            )
        }
        guard let feet = captures[1]?.uInt?.int, // UInt avoids negative ints
              let frames = captures[2]?.uInt?.int // UInt avoids negative ints
        else {
            throw ParseError.general(
                "Feet+Frames value is malformed: not valid integer(s)."
            )
        }
        
        let subFrames: Int?
        if captures[5] == nil || captures[5] == "" {
            subFrames = nil
        } else {
            if let subFramesInt = captures[5]?.uInt?.int { // UInt avoids negative ints
                subFrames = subFramesInt
            } else {
                throw ParseError.general(
                    "Feet+Frames value is malformed. Subframes component was present but was not a valid integer."
                )
            }
        }
        
        return .feetAndFrames(feet: feet, frames: frames, subFrames: subFrames)
    }
}
