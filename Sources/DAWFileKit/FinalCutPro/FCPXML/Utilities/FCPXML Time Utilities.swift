//
//  FCPXML Time Utilities.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import OTCore

// MARK: - Rational Time Value Utils

extension FinalCutPro.FCPXML {
    enum ParsedRational {
        case value(Int)
        case rational(Fraction)
    }
    
    /// Parse a raw rational time string (ie: "100/3000s", "-11/30s" or "10s").
    /// Note that the string may be either a rational fraction or a whole number.
    /// It may also be negative when a minus sign ("-") prefixes the string.
    static func parse(
        rationalTimeString: String
    ) -> ParsedRational? {
        // first test for rational fraction
        let fractionPattern = #"^([\-]{0,1}[0-9]+)/([0-9]+)s$"#
        
        var groups = rationalTimeString
            .regexMatches(captureGroupsFromPattern: fractionPattern)
        
        if groups.count == 3,
           let n = groups[1]?.int,
           let d = groups[2]?.int
        {
            return .rational(Fraction(n, d))
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
}

// MARK: - Timecode Utils

extension XMLElement {
    /// FCPXML: Convert raw time attribute value string to `Timecode`.
    func fcpTimecode(
        fromRational rawString: String,
        tcFormat: FinalCutPro.FCPXML.TimecodeFormat,
        resourceID: String,
        resources: XMLElement? = nil
    ) throws -> Timecode? {
        guard let frameRate = fcpTimecodeFrameRate(
            forResourceID: resourceID,
            tcFormat: tcFormat,
            in: resources
        )
        else { return nil }
        
        return try FinalCutPro.FCPXML.timecode(fromRational: rawString, frameRate: frameRate)
    }
    
    /// FCPXML: Convert raw time attribute value string to `Timecode`.
    /// Traverses the parents of the given XML leaf to determine frame rate.
    func fcpTimecode(
        fromRational rawString: String,
        xmlLeaf: XMLElement,
        resources: XMLElement? = nil
    ) throws -> Timecode? {
        guard let frameRate = fcpTimecodeFrameRate(in: resources)
        else { return nil }
        
        return try FinalCutPro.FCPXML.timecode(fromRational: rawString, frameRate: frameRate)
    }
}

extension FinalCutPro.FCPXML {
    /// FCPXML: Convert raw time attribute value string to `Timecode`.
    static func timecode(
        fromRational rawString: String,
        frameRate: TimecodeFrameRate
    ) throws -> Timecode? {
        guard let parsedStr = FinalCutPro.FCPXML.parse(rationalTimeString: rawString)
        else { return nil }
        
        switch parsedStr {
        case let .rational(fraction):
            return try FinalCutPro.formTimecode(rational: fraction, at: frameRate)
            
        case let .value(value):
            // this could also work using Timecode(.realTime(), at:)
            return try FinalCutPro.formTimecode(rational: Fraction(value, 1), at: frameRate)
        }
    }
}

// MARK: - Timecode Interval Utils

extension XMLElement {
    /// FCPXML: Convert raw time attribute value string to `TimecodeInterval`.
    /// Traverses the parents of the given XML leaf to determine frame rate.
    func fcpTimecodeInterval(
        fromRational rawString: String,
        resources: XMLElement? = nil
    ) throws -> TimecodeInterval? {
        guard let frameRate = fcpTimecodeFrameRate(in: resources)
        else { return nil }
        
        return try FinalCutPro.FCPXML.timecodeInterval(fromRational: rawString, frameRate: frameRate)
    }
}

extension FinalCutPro.FCPXML {
    /// Utility:
    /// Convert raw time attribute value string to `TimecodeInterval`.
    static func timecodeInterval(
        fromRational rawString: String,
        frameRate: TimecodeFrameRate
    ) throws -> TimecodeInterval? {
        guard let parsedStr = FinalCutPro.FCPXML.parse(rationalTimeString: rawString)
        else { return nil }
        
        switch parsedStr {
        case let .rational(fraction):
            return try FinalCutPro.formTimecodeInterval(rational: fraction, at: frameRate)
            
        case let .value(value):
            // this could also work using Timecode(.realTime(), at:)
            return try FinalCutPro.formTimecodeInterval(rational: Fraction(value, 1), at: frameRate)
        }
    }
}

#endif
