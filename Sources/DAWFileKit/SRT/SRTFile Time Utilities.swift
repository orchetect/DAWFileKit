//
//  SRTFile Time Utilities.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation
import OTCore

extension Time {
    /// Decode from SRT file timestamp format.
    init?<S: StringProtocol>(srtEncodedString: S) {
        let pattern = #"(\d{2}):(\d{2}):(\d{2}),(\d{3})"#
        let matches = srtEncodedString.regexMatches(
            captureGroupsFromPattern: pattern,
            options: [],
            matchesOptions: []
        )
        guard matches.count == 5 else { return nil }
        guard let h = matches[1]?.int,
              let m = matches[2]?.int,
              let s = matches[3]?.int,
              let ms = matches[4]?.int
        else { return nil }
        
        self.init(hours: h, minutes: m, seconds: s, milliseconds: ms)
    }
    
    /// Encode to SRT file timestamp format.
    func srtEncodedString() -> String {
        hours.string(paddedTo: 2)
        + ":"
        + minutes.string(paddedTo: 2)
        + ":"
        + seconds.string(paddedTo: 2)
        + ","
        + milliseconds.string(paddedTo: 3)
    }
}
