//
//  SessionInfo TimeLocation.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation
import TimecodeKit

extension ProTools.SessionInfo {
    public enum TimeLocation: Equatable, Hashable {
        /// Timecode at the project frame rate.
        ///
        /// Pro Tools always uses a subframe base of 100 subframes per frame.
        case timecode(Timecode)
        
        /// Min:Secs time format.
        /// This can either be `MM:SS` or `MM:SS.sss` (where `sss` is milliseconds).
        case minSecs(min: Int, sec: Int, ms: Int?)
        
        /// Elapsed audio samples since the project start.
        ///
        /// Refer to ``ProTools/SessionInfo/main-swift.property``.``ProTools/SessionInfo/Main-swift.struct/sampleRate`` for project sample rate.
        case samples(Int)
        
        /// Bars and Beats (musical).
        /// Ticks (quarter note division) is only present when the _Show Subframes_ option is enabled in Pro Tools' Export Session Text window while exporting. Pro Tools uses a PPQ base of 960 ticks per quarter.
        case barsAndBeats(bar: Int, beat: Int, ticks: Int?)
        
        /// Feet and Frames.
        ///
        /// This can either be `FT:FR` or `FT:FR.sf` (where `sf` is subframes).
        ///
        /// SubFrames is only present when the _Show Subframes_ option is enabled in Pro Tools' Export Session Text window while exporting. Pro Tools uses a PPQ base of 960 ticks per quarter.
        case feetAndFrames(feet: Int, frames: Int, subFrames: Int?)
    }
    
    public enum TimeLocationFormat: Equatable, Hashable, CaseIterable {
        /// Timecode at the project frame rate.
        ///
        /// Pro Tools always uses a subframe base of 100 subframes per frame.
        case timecode
        
        /// Min:Secs time format.
        /// This can either be `MM:SS` or `MM:SS.sss` (where `sss` is milliseconds).
        case minSecs
        
        /// Elapsed audio samples since the project start.
        ///
        /// Refer to ``ProTools/SessionInfo/main-swift.property``.``ProTools/SessionInfo/Main-swift.struct/sampleRate`` for project sample rate.
        case samples
        
        /// Bars and Beats (musical).
        /// Ticks (quarter note division) is only present when the _Show Subframes_ option is enabled in Pro Tools' Export Session Text window while exporting. Pro Tools uses a PPQ base of 960 ticks per quarter.
        case barsAndBeats
        
        /// Feet and Frames.
        ///
        /// This can either be `FT:FR` or `FT:FR.sf` (where `sf` is subframes).
        ///
        /// SubFrames is only present when the _Show Subframes_ option is enabled in Pro Tools' Export Session Text window while exporting. Pro Tools uses a PPQ base of 960 ticks per quarter.
        case feetAndFrames
    }
}

// MARK: - Internal Methods

extension ProTools.SessionInfo {
    /// Form a ``TimeLocation/timecode(_:)`` instance from timecode string.
    /// Timecode is validated at the given frame rate and an error is thrown if invalid.
    /// Ancillary timecode metadata is automatically derived from ``ProTools`` constants.
    static func formTimeLocation(
        timecodeString: String,
        at frameRate: Timecode.FrameRate
    ) throws -> TimeLocation {
        let timecode = try ProTools.formTimecode(timecodeString, at: frameRate)
        return .timecode(timecode)
    }
    
    /// Form a ``TimeLocation/minSecs(min:sec:)`` instance from timecode string.
    /// This can either be `MM:SS` or `MM:SS.sss` (where `sss` is milliseconds).
    /// An error is thrown if the string is malformed.
    static func formTimeLocation(
        minSecsString: String
    ) throws -> TimeLocation {
        // first two capture groups are mandatory: HH and SS
        // the fourth capture group will be milliseconds if present, or empty if not present
        let regExPattern = #"(\d+):(\d{2})(.){0,1}(\d{3}){0,1}"#
        
        let captures = minSecsString.regexMatches(captureGroupsFromPattern: regExPattern)
        
        guard captures.count == 4 else {
            throw ParseError.general(
                "Min:Secs value is malformed."
            )
        }
        guard let min = captures[0]?.int,
              let sec = captures[1]?.int
        else {
            throw ParseError.general(
                "Min:Secs value is malformed."
            )
        }
        
        let ms: Int?
        if captures[3] == "" {
            ms = nil
        } else if let msInt = captures[3]?.int {
            ms = msInt
        } else {
            throw ParseError.general(
                "Min:Secs value is malformed. Milliseconds component was present but was not a valid integer."
            )
        }
        
        return .minSecs(min: min, sec: sec, ms: ms)
    }
    
    /// Form a ``TimeLocation/samples(_:)`` instance from a samples number string.
    /// An error is thrown if the string is not a valid integer.
    static func formTimeLocation(
        samplesString: String
    ) throws -> TimeLocation {
        guard let samples = Int(samplesString) else {
            throw ParseError.general(
                "Samples value was not an integer."
            )
        }
        return .samples(samples)
    }
    
    /// Form a ``TimeLocation/barsAndBeats(bar:beat:ticks:)`` instance from a bars and beats string.
    /// Expected formats: "Bar|Beat" or "Bar|Beat|Ticks".
    /// (ie: "5|3" or "17|2|685" or "17|2| 24")
    /// An error is thrown if the string is malformed.
    static func formTimeLocation(
        barsAndBeatsString: String
    ) throws -> TimeLocation {
        let slices = barsAndBeatsString
            .split(separator: "|")
            .map(\.trimmed)
            .map { Int($0) }
        
        guard (2 ... 3).contains(slices.count),
              let bar = slices[0],
              let beat = slices[1]
        else {
            throw ParseError.general(
                "Value was not recognized as either Bar|Beat or Bar|Beat|Ticks format: \(barsAndBeatsString.quoted)."
            )
        }
        
        // beat subdivision (ticks) may not be present but that is not an error condition.
        // instead of providing 0, provide nil.
        // the reasons is that if ticks are not present in the text file, it is because
        // are simply omitted by Pro Tools and they may not necessarily be 0 in the actual project
        let ticks = slices.count > 2 ? slices[2] : nil
        
        return .barsAndBeats(bar: bar, beat: beat, ticks: ticks)
    }
    
    /// Form a ``TimeLocation/feetAndFrames(feet:frames:subFrames:)`` instance from raw string.
    /// This can either be `FT+FR` or `FT+FR.sf` (where `sf` is subframes).
    /// An error is thrown if the string is malformed.
    static func formTimeLocation(
        feetAndFramesString: String
    ) throws -> TimeLocation {
        // first two capture groups are mandatory: FT and FR
        // the fourth capture group will be milliseconds if present, or empty if not present
        let regExPattern = #"(\d+)+(\d{2})(.){0,1}(\d{2}){0,1}"#
        
        let captures = feetAndFramesString.regexMatches(captureGroupsFromPattern: regExPattern)
        
        guard captures.count == 4 else {
            throw ParseError.general(
                "Feet+Frames value is malformed."
            )
        }
        guard let feet = captures[0]?.int,
              let frames = captures[1]?.int
        else {
            throw ParseError.general(
                "Feet+Frames value is malformed."
            )
        }
        
        let subFrames: Int?
        if captures[3] == "" {
            subFrames = nil
        } else if let subFramesInt = captures[3]?.int {
            subFrames = subFramesInt
        } else {
            throw ParseError.general(
                "Feet+Frames value is malformed. Subframes component was present but was not a valid integer."
            )
        }
        
        return .feetAndFrames(feet: feet, frames: frames, subFrames: subFrames)
    }
}
