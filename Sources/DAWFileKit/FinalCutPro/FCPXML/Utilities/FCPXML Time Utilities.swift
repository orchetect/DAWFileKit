//
//  FCPXML Time Utilities.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import OTCore
import TimecodeKit

// MARK: - Time -> Timecode, from resource

extension XMLElement {
    /// FCPXML: Convert raw time attribute value string to `Timecode`.
    func _fcpTimecode(
        fromRational rawString: String,
        tcFormat: FinalCutPro.FCPXML.TimecodeFormat,
        resourceID: String,
        resources: XMLElement? = nil
    ) throws -> Timecode? {
        guard let frameRate = _fcpTimecodeFrameRate(
            forResourceID: resourceID,
            tcFormat: tcFormat,
            in: resources
        )
        else { return nil }
        
        return try FinalCutPro.FCPXML._timecode(
            fromRational: rawString,
            frameRate: frameRate
        )
    }
    
    /// FCPXML: Convert raw time attribute value string to `Timecode`.
    func _fcpTimecode(
        fromRational fraction: Fraction,
        tcFormat: FinalCutPro.FCPXML.TimecodeFormat,
        resourceID: String,
        resources: XMLElement? = nil
    ) throws -> Timecode? {
        guard let frameRate = _fcpTimecodeFrameRate(
            forResourceID: resourceID,
            tcFormat: tcFormat,
            in: resources
        )
        else { return nil }
        
        return try FinalCutPro.FCPXML._timecode(
            fromRational: fraction,
            frameRate: frameRate
        )
    }
}

// MARK: - Time -> Timecode, with timeline source

extension XMLElement {
    /// FCPXML: Convert time value to `Timecode`.
    /// Traverses the parents of the given XML leaf to determine frame rate.
    func _fcpTimecode(
        fromRational rawString: String,
        frameRateSource: FinalCutPro.FCPXML.FrameRateSource,
        breadcrumbs: [XMLElement]? = nil,
        resources: XMLElement? = nil
    ) throws -> Timecode? {
        guard let fraction = Fraction(fcpxmlString: rawString)
        else { return nil }
        
        return try _fcpTimecode(
            fromRational: fraction,
            frameRateSource: frameRateSource,
            breadcrumbs: breadcrumbs,
            resources: resources
        )
    }
    
    /// FCPXML: Convert raw time attribute value string to `Timecode`.
    /// Traverses the parents of the given XML leaf to determine frame rate.
    func _fcpTimecode(
        fromRational fraction: Fraction,
        frameRateSource: FinalCutPro.FCPXML.FrameRateSource,
        breadcrumbs: [XMLElement]? = nil,
        resources: XMLElement? = nil
    ) throws -> Timecode? {
        try _fcpTimecode(
            fromRealTime: fraction.doubleValue,
            frameRateSource: frameRateSource,
            breadcrumbs: breadcrumbs,
            resources: resources
        )
    }
    
    /// FCPXML: Convert raw time in seconds to `Timecode`.
    func _fcpTimecode(
        fromRealTime seconds: TimeInterval,
        frameRateSource: FinalCutPro.FCPXML.FrameRateSource,
        breadcrumbs: [XMLElement]? = nil,
        resources: XMLElement? = nil
    ) throws -> Timecode? {
        guard let frameRate = _fcpTimecodeFrameRate(
            source: frameRateSource,
            breadcrumbs: breadcrumbs,
            resources: resources
        ) else { return nil }
        
        return try FinalCutPro.formTimecode(realTime: seconds, at: frameRate)
    }
}

extension FinalCutPro.FCPXML {
    /// FCPXML: Convert raw time attribute value string to `Timecode`.
    static func _timecode(
        fromRational rawString: String,
        frameRate: TimecodeFrameRate
    ) throws -> Timecode? {
        guard let fraction = Fraction(fcpxmlString: rawString)
        else { return nil }
        
        return try _timecode(
            fromRational: fraction,
            frameRate: frameRate
        )
    }
    
    /// FCPXML: Convert raw time attribute value string to `Timecode`.
    static func _timecode(
        fromRational fraction: Fraction,
        frameRate: TimecodeFrameRate
    ) throws -> Timecode? {
        try FinalCutPro.formTimecode(realTime: fraction.doubleValue, at: frameRate)
    }
    
    /// FCPXML: Convert raw time in seconds to `Timecode`.
    static func _timecode(
        fromRealTime seconds: TimeInterval,
        frameRate: TimecodeFrameRate
    ) throws -> Timecode? {
        try FinalCutPro.formTimecode(realTime: seconds, at: frameRate)
    }
}

// MARK: - Time -> TimecodeInterval

extension XMLElement {
    /// FCPXML: Convert raw time attribute value string to `TimecodeInterval`.
    /// Traverses the parents of the given XML leaf to determine frame rate.
    func _fcpTimecodeInterval(
        fromRational rawString: String,
        frameRateSource: FinalCutPro.FCPXML.FrameRateSource,
        breadcrumbs: [XMLElement]? = nil,
        resources: XMLElement? = nil
    ) throws -> TimecodeInterval? {
        guard let fraction = Fraction(fcpxmlString: rawString)
        else { return nil }
        
        return try _fcpTimecodeInterval(
            fromRational: fraction,
            frameRateSource: frameRateSource,
            breadcrumbs: breadcrumbs,
            resources: resources
        )
    }
    
    /// FCPXML: Convert raw time attribute value string to `TimecodeInterval`.
    /// Traverses the parents of the given XML leaf to determine frame rate.
    func _fcpTimecodeInterval(
        fromRational fraction: Fraction,
        frameRateSource: FinalCutPro.FCPXML.FrameRateSource,
        breadcrumbs: [XMLElement]? = nil,
        resources: XMLElement? = nil
    ) throws -> TimecodeInterval? {
        try _fcpTimecodeInterval(
            fromRealTime: fraction.doubleValue,
            frameRateSource: frameRateSource,
            breadcrumbs: breadcrumbs,
            resources: resources
        )
    }
    
    /// FCPXML: Convert raw time attribute value string to `TimecodeInterval`.
    /// Traverses the parents of the given XML leaf to determine frame rate.
    func _fcpTimecodeInterval(
        fromRealTime seconds: TimeInterval,
        frameRateSource: FinalCutPro.FCPXML.FrameRateSource,
        breadcrumbs: [XMLElement]? = nil,
        resources: XMLElement? = nil
    ) throws -> TimecodeInterval? {
        guard let frameRate = _fcpTimecodeFrameRate(
            source: frameRateSource,
            breadcrumbs: breadcrumbs,
            resources: resources
        ) else { return nil }
        
        return try FinalCutPro.FCPXML._timecodeInterval(
            fromRealTime: seconds,
            frameRate: frameRate
        )
    }
}

extension FinalCutPro.FCPXML {
    /// Utility:
    /// Convert raw time attribute value string to `TimecodeInterval`.
    static func _timecodeInterval(
        fromRational rawString: String,
        frameRate: TimecodeFrameRate
    ) throws -> TimecodeInterval? {
        guard let fraction = Fraction(fcpxmlString: rawString)
        else { return nil }
        
        return try _timecodeInterval(
            fromRational: fraction,
            frameRate: frameRate
        )
    }
    
    /// Utility:
    /// Convert raw time attribute value string to `TimecodeInterval`.
    static func _timecodeInterval(
        fromRational fraction: Fraction,
        frameRate: TimecodeFrameRate
    ) throws -> TimecodeInterval? {
        try _timecodeInterval(fromRealTime: fraction.doubleValue, frameRate: frameRate)
    }
    
    /// Utility:
    /// Convert raw time attribute value string to `TimecodeInterval`.
    static func _timecodeInterval(
        fromRealTime seconds: TimeInterval,
        frameRate: TimecodeFrameRate
    ) throws -> TimecodeInterval? {
        try FinalCutPro.formTimecodeInterval(realTime: seconds, at: frameRate)
    }
}

#endif
