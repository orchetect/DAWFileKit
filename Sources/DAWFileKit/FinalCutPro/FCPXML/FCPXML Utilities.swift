//
//  FCPXML Utilities.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation
@_implementationOnly import OTCore
import TimecodeKit

extension FinalCutPro.FCPXML {
    enum ParsedRational {
        case value(Int)
        case rational((numerator: Int, denominator: Int))
    }
    
    /// Parse a raw rational time string (ie: "100/3000s" or "10s").
    /// Note that the string may be either a rational fraction or a whole number.
    static func parse(
        rationalTimeString: String
    ) -> ParsedRational? {
        // first test for rational fraction
        let fractionPattern = #"^([0-9]+)/([0-9]+)s$"#
        
        var groups = rationalTimeString
            .regexMatches(captureGroupsFromPattern: fractionPattern)
        
        if groups.count == 3,
              let n = groups[1]?.int,
              let d = groups[2]?.int
        {
            return .rational((numerator: n, denominator: d))
        }
        
        // otherwise, try as a single integer (not a fraction)
        
        let singleIntPattern = #"^([0-9]+)s$"#
        
        groups = rationalTimeString
            .regexMatches(captureGroupsFromPattern: singleIntPattern)
        
        if groups.count == 2,
           let value = groups[1]?.int
        {
            return .value(value)
        }
        
        return nil
    }
    
    /// Convenience: returns the video frame rate for the given resource ID.
    static func videoFrameRate(
        forResourceID id: String,
        in resources: [String: FinalCutPro.FCPXML.Resource]
    ) -> VideoFrameRate? {
        guard case let .format(fmt) = resources[id] else { return nil }
        let interlaced = fmt.fieldOrder != nil
        guard let parsed = parse(rationalTimeString: fmt.frameDuration),
              case let .rational(frac) = parsed
        else { return nil }
        let fRate = VideoFrameRate(
            rationalFrameDuration: frac,
            interlaced: interlaced
        )
        return fRate
    }
}
