//
//  FCPXML Time Utilities.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import OTCore

// MARK: - Timecode Utils

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
        
        return try FinalCutPro.FCPXML._timecode(fromRational: rawString, frameRate: frameRate)
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
        
        return try FinalCutPro.FCPXML._timecode(fromRational: fraction, frameRate: frameRate)
    }
    
    /// FCPXML: Convert raw time attribute value string to `Timecode`.
    /// Traverses the parents of the given XML leaf to determine frame rate.
    func _fcpTimecode(
        fromRational rawString: String,
        resources: XMLElement? = nil
    ) throws -> Timecode? {
        guard let fraction = Fraction(fcpxmlString: rawString)
        else { return nil }
        
        return try _fcpTimecode(
            fromRational: fraction,
            resources: resources
        )
    }
    
    /// FCPXML: Convert raw time attribute value string to `Timecode`.
    /// Traverses the parents of the given XML leaf to determine frame rate.
    func _fcpTimecode(
        fromRational fraction: Fraction,
        resources: XMLElement? = nil
    ) throws -> Timecode? {
        guard let frameRate = _fcpTimecodeFrameRate(in: resources)
        else { return nil }
        
        return try FinalCutPro.FCPXML._timecode(fromRational: fraction, frameRate: frameRate)
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
        
        return try _timecode(fromRational: fraction, frameRate: frameRate)
    }
    
    /// FCPXML: Convert raw time attribute value string to `Timecode`.
    static func _timecode(
        fromRational fraction: Fraction,
        frameRate: TimecodeFrameRate
    ) throws -> Timecode? {
        try FinalCutPro.formTimecode(rational: fraction, at: frameRate)
    }
}

// MARK: - Timecode Interval Utils

extension XMLElement {
    /// FCPXML: Convert raw time attribute value string to `TimecodeInterval`.
    /// Traverses the parents of the given XML leaf to determine frame rate.
    func _fcpTimecodeInterval(
        fromRational rawString: String,
        resources: XMLElement? = nil
    ) throws -> TimecodeInterval? {
        guard let fraction = Fraction(fcpxmlString: rawString)
        else { return nil }
        
        return try _fcpTimecodeInterval(fromRational: fraction, resources: resources)
    }
    
    /// FCPXML: Convert raw time attribute value string to `TimecodeInterval`.
    /// Traverses the parents of the given XML leaf to determine frame rate.
    func _fcpTimecodeInterval(
        fromRational fraction: Fraction,
        resources: XMLElement? = nil
    ) throws -> TimecodeInterval? {
        guard let frameRate = _fcpTimecodeFrameRate(in: resources)
        else { return nil }
        
        return try FinalCutPro.FCPXML._timecodeInterval(fromRational: fraction, frameRate: frameRate)
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
        
        return try _timecodeInterval(fromRational: fraction, frameRate: frameRate)
    }
    
    /// Utility:
    /// Convert raw time attribute value string to `TimecodeInterval`.
    static func _timecodeInterval(
        fromRational fraction: Fraction,
        frameRate: TimecodeFrameRate
    ) throws -> TimecodeInterval? {
        try FinalCutPro.formTimecodeInterval(rational: fraction, at: frameRate)
    }
}

#endif
