//
//  SessionInfo TimeValue.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation

extension ProTools.SessionInfo {
    public enum TimeValueFormat: Equatable, Hashable, CaseIterable {
        /// Timecode at the project frame rate.
        ///
        /// Pro Tools always uses a subframe base of 100 subframes per frame.
        case timecode
        
        /// Min:Secs time format.
        /// This can either be `MM:SS` or `MM:SS.sss` (where `sss` is milliseconds).
        case minSecs
        
        /// Elapsed audio samples since the project start.
        ///
        /// Refer to ``ProTools/SessionInfo/main-swift.property``.``ProTools/SessionInfo/Main-swift.struct/sampleRate``
        /// for project sample rate.
        case samples
        
        /// Bars and Beats (musical).
        /// Ticks (quarter note division) is only present when the _Show Subframes_ option is
        /// enabled in Pro Tools' Export Session Text window while exporting. Pro Tools uses a PPQ
        /// base of 960 ticks per quarter.
        case barsAndBeats
        
        /// Feet and Frames.
        ///
        /// This can either be `FT:FR` or `FT:FR.sf` (where `sf` is subframes).
        ///
        /// SubFrames is only present when the _Show Subframes_ option is enabled in Pro Tools'
        /// Export Session Text window while exporting. Pro Tools uses a PPQ base of 960 ticks per
        /// quarter.
        case feetAndFrames
    }
}

extension ProTools.SessionInfo.TimeValueFormat: Identifiable {
    public var id: Self { self }
}

extension ProTools.SessionInfo.TimeValueFormat: Sendable { }

extension ProTools.SessionInfo.TimeValueFormat: CustomStringConvertible {
    public var description: String {
        name
    }
}

extension ProTools.SessionInfo.TimeValueFormat {
    /// Returns human-readable name of the time value format type suitable for UI or debugging.
    public var name: String {
        switch self {
        case .timecode: return "Timecode"
        case .minSecs: return "Min:Secs"
        case .samples: return "Samples"
        case .barsAndBeats: return "Bars|Beats"
        case .feetAndFrames: return "Feet+Frames"
        }
    }
}

// MARK: - Internal Methods

extension ProTools.SessionInfo.TimeValueFormat {
    /// Employs a format detection heuristic to attempt to determine the time format of the given
    /// time string.
    /// This does not perform exhaustive validation on the values themselves, but matches against
    /// expected formatting.
    /// Returns `nil` if no matches can be ascertained.
    init(heuristic source: String) throws {
        // as a performance optimization, the formats here
        // are ordered from most common to least common
        
        if Self.isTimecode(source) {
            self = .timecode
            return
        }
        if Self.isMinSecs(source) {
            self = .minSecs
            return
        }
        if Self.isBarsAndBeats(source) {
            self = .barsAndBeats
            return
        }
        if Self.isSamples(source) {
            self = .samples
            return
        }
        if Self.isFeetAndFrames(source) {
            self = .feetAndFrames
            return
        }
        
        throw ProTools.SessionInfo.ParseError.general(
            "Not a valid time value."
        )
    }
    
    private static func isTimecode(
        _ source: String
    ) -> Bool {
        let regExPattern = #"^\d{2}:\d{2}:\d{2}[:|;]\d{2}(.\d{2}){0,1}$"#
        return source.regexMatches(pattern: regExPattern).count == 1
    }
    
    private static func isMinSecs(
        _ source: String
    ) -> Bool {
        let regExPattern = #"^(\d+):(\d{2})(.\d{3}){0,1}$"#
        return source.regexMatches(pattern: regExPattern).count == 1
    }
    
    private static func isSamples(
        _ source: String
    ) -> Bool {
        let regExPattern = #"^\d+$"#
        return source.regexMatches(pattern: regExPattern).count == 1
    }
    
    private static func isBarsAndBeats(
        _ source: String
    ) -> Bool {
        let regExPattern = #"^\d+\|\d+(\|[\s\d]{1}\d{3}){0,1}$"#
        return source.regexMatches(pattern: regExPattern).count == 1
    }
    
    private static func isFeetAndFrames(
        _ source: String
    ) -> Bool {
        let regExPattern = #"^(\d+)\+(\d{2})(.\d{2}){0,1}$"#
        return source.regexMatches(pattern: regExPattern).count == 1
    }
}
