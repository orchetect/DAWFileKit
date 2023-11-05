//
//  FCPXML Utilities.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
@_implementationOnly import OTCore
import TimecodeKit

// MARK: - Generic XML Utils

extension FinalCutPro.FCPXML {
    // TODO: refactor to new FCPXML protocol?
    static func getRefAttribute(
        from xmlLeaf: XMLElement
    ) -> String {
        xmlLeaf.attributeStringValue(forName: "ref") ?? ""
    }
    
    // TODO: refactor to new FCPXML protocol?
    static func getNameAttribute(
        from xmlLeaf: XMLElement
    ) -> String {
        xmlLeaf.attributeStringValue(forName: "name") ?? ""
    }
}

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

// MARK: - Frame Rate Utils

extension FinalCutPro.FCPXML {
    /// Convenience: returns the video frame rate for the given resource ID.
    static func videoFrameRate(
        forResourceID id: String,
        in resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) -> VideoFrameRate? {
        guard case let .format(fmt) = resources[id] else { return nil }
        let interlaced = fmt.fieldOrder != nil
        guard let parsed = parse(rationalTimeString: fmt.frameDuration),
              case let .rational(frac) = parsed
        else { return nil }
        let fRate = VideoFrameRate(
            frameDuration: frac,
            interlaced: interlaced
        )
        return fRate
    }
    
    /// Convenience: returns the timecode frame rate for the given resource ID & `tcFormat`.
    static func timecodeFrameRate(
        forResourceID id: String,
        tcFormat: FinalCutPro.FCPXML.TimecodeFormat?,
        in resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) -> TimecodeFrameRate? {
        guard let videoRate = FinalCutPro.FCPXML.videoFrameRate(forResourceID: id, in: resources),
              let frameRate = videoRate.timecodeFrameRate(drop: tcFormat?.isDrop ?? false)
        else { return nil }
        return frameRate
    }
}

// MARK: - Timecode Utils

extension FinalCutPro.FCPXML {
    /// Utility:
    /// Convert raw attribute value string to `Timecode`.
    static func timecode(
        fromRational rawString: String,
        tcFormat: FinalCutPro.FCPXML.TimecodeFormat?,
        resourceID: String,
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) throws -> Timecode? {
        guard let frameRate = timecodeFrameRate(
            forResourceID: resourceID,
            tcFormat: tcFormat,
            in: resources
        )
        else { return nil }
        
        return try timecode(fromRational: rawString, frameRate: frameRate)
    }
    
    /// Utility:
    /// Convert raw attribute value string to `Timecode`.
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
    
    /// Utility:
    /// Convert raw attribute value string to `TimecodeInterval`.
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
