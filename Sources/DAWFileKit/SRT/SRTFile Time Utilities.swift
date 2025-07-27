//
//  SRTFile Time Utilities.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation
import OTCore

extension Time {
    static func decodeRegExPattern(strict: Bool, matchLine: Bool) -> String {
        let pattern = strict
            ? #"(\d{2}):(\d{2}):(\d{2}),(\d{3})"#
            : #"\s*(\d{1,3})\s*[:;]\s*(\d{1,3})\s*[:;]\s*(\d{1,3})\s*[\.,]\s*(\d{1,3})\s*"#
        return matchLine
            ? "^" + pattern + "$"
            : pattern
    }
    
    /// Decode from SRT file timestamp format.
    ///
    /// - Parameters:
    ///   - srtEncodedString: Timestamp string to parse.
    ///   - strict: Enable strict parsing mode. When strict, only the "00:00:00,000" format is accepted.
    ///     When non-strict, a very loose heuristic is used to allow for superfluous whitespace, the
    ///     use of non-standard time separator characters and non-enforcement of character zero-padding.
    public init?<S: StringProtocol>(srtEncodedString: S, strict: Bool = false) {
        let pattern = Self.decodeRegExPattern(strict: strict, matchLine: true)
        let matches = srtEncodedString.regexMatches(
            captureGroupsFromPattern: pattern,
            options: [],
            matchesOptions: []
        )
        guard matches.count == 5 else { return nil }
        guard let h = matches[1]?.int,
              let m = matches[2]?.int,
              let s = matches[3]?.int,
              let msString = matches[4],
              strict ? msString.count == 3 : (1 ... 3).contains(msString.count),
              let ms = msString.int
        else { return nil }
        
        self.init(hours: h, minutes: m, seconds: s, milliseconds: ms)
    }
    
    /// Encode to SRT file timestamp format.
    public func srtEncodedString() -> String {
        hours.string(paddedTo: 2)
            + ":"
            + minutes.string(paddedTo: 2)
            + ":"
            + seconds.string(paddedTo: 2)
            + ","
            + milliseconds.string(paddedTo: 3)
    }
}
