//
//  FCPXML Utilities.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
@_implementationOnly import OTCore
import TimecodeKit

// MARK: - FCPXML Utils

extension FinalCutPro.FCPXML {
    // TODO: refactor to new FCPXML protocol?
    static func getIDAttribute(
        from xmlLeaf: XMLElement?
    ) -> String? {
        xmlLeaf?.attributeStringValue(forName: "id")
    }
    
    // TODO: refactor to new FCPXML protocol?
    static func getUIDAttribute(
        from xmlLeaf: XMLElement?
    ) -> String? {
        xmlLeaf?.attributeStringValue(forName: "uid")
    }
    
    // TODO: refactor to new FCPXML protocol?
    static func getRefAttribute(
        from xmlLeaf: XMLElement?
    ) -> String? {
        xmlLeaf?.attributeStringValue(forName: "ref")
    }
    
    // TODO: refactor to new FCPXML protocol?
    static func getNameAttribute(
        from xmlLeaf: XMLElement?
    ) -> String? {
        xmlLeaf?.attributeStringValue(forName: "name")
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
    // TODO: Refactor using AnyResource and/or resource protocol. I think more than just `format` resource can contain frame rate info?
    /// Convenience: returns the video frame rate for the given resource ID.
    static func videoFrameRate(
        forResourceID id: String,
        in resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) -> VideoFrameRate? {
        guard case let .format(resource) = resources[id] else { return nil }
        return videoFrameRate(for: resource)
    }
    
    // TODO: Refactor using AnyResource and/or resource protocol. I think more than just `format` resource can contain frame rate info?
    /// Convenience: returns the video frame rate for the given resource ID.
    static func videoFrameRate(
        for format: Format
    ) -> VideoFrameRate? {
        let interlaced = format.fieldOrder != nil
        guard let frameDuration = format.frameDuration,
              let parsed = parse(rationalTimeString: frameDuration),
              case let .rational(frac) = parsed
        else { return nil }
        let fRate = VideoFrameRate(frameDuration: frac, interlaced: interlaced)
        return fRate
    }
    
    /// Convenience: returns the timecode frame rate for the given resource ID.
    /// Traverses parents to determine `tcFormat`.
    static func timecodeFrameRate(
        for xmlLeaf: XMLElement,
        resourceID id: String,
        in resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) -> TimecodeFrameRate? {
        guard let tcFormat = tcFormat(forElementOrAncestors: xmlLeaf)
        else { return nil }
        
        return timecodeFrameRate(forResourceID: id, tcFormat: tcFormat, in: resources)
    }
    
    /// Convenience: returns the timecode frame rate for the given resource ID & `tcFormat`.
    static func timecodeFrameRate(
        forResourceID id: String,
        tcFormat: FinalCutPro.FCPXML.TimecodeFormat,
        in resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) -> TimecodeFrameRate? {
        guard let videoRate = FinalCutPro.FCPXML.videoFrameRate(forResourceID: id, in: resources),
              let frameRate = videoRate.timecodeFrameRate(drop: tcFormat.isDrop)
        else { return nil }
        return frameRate
    }
    
    /// Convenience: returns the timecode frame rate for the given resource ID & `tcFormat`.
    static func timecodeFrameRate(
        for format: Format,
        tcFormat: FinalCutPro.FCPXML.TimecodeFormat
    ) -> TimecodeFrameRate? {
        guard let videoRate = FinalCutPro.FCPXML.videoFrameRate(for: format),
              let frameRate = videoRate.timecodeFrameRate(drop: tcFormat.isDrop)
        else { return nil }
        return frameRate
    }
    
    /// Convenience: returns the timecode frame rate for the given resource ID.
    /// Traverses parents to determine `format` (resource ID) and `tcFormat`.
    static func timecodeFrameRate(
        for xmlLeaf: XMLElement,
        in resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) -> TimecodeFrameRate? {
        guard let format = firstDefinedFormat(forElementOrAncestors: xmlLeaf, in: resources),
              let tcFormat = tcFormat(forElementOrAncestors: xmlLeaf)
        else { return nil }
        
        return timecodeFrameRate(for: format, tcFormat: tcFormat)
    }
    
    /// Traverses the parents of the given XML leaf and returns the resource corresponding to the
    /// nearest `format` attribute if found.
    static func firstFormat(
        forElementOrAncestors xmlLeaf: XMLElement,
        in resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) -> FinalCutPro.FCPXML.Format? {
        if let (resourceID, _) = xmlLeaf.attributeStringValueTraversingAncestors(forName: "format") {
            return format(forResourceID: resourceID, in: resources)
        }
        // ref could point to any resource and not just format, ie: asset or effect. we need to
        // continue drilling into it.
        if let (refID, _) = xmlLeaf.attributeStringValueTraversingAncestors(forName: "ref") {
            if let refResource = resources[refID] {
                return format(for: refResource, in: resources)
            }
        }
        return nil
    }
    
    /// Traverses the parents of the given XML leaf and returns the nearest defined resource.
    static func firstDefinedFormat(
        forElementOrAncestors xmlLeaf: XMLElement,
        in resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) -> FinalCutPro.FCPXML.Format? {
        // note that an audio clip may point to a resource with name `FFVideoFormatRateUndefined`.
        // this should not be an error case; instead, continue traversing.
        
        let result = xmlLeaf.walkAncestors(
            includingSelf: true,
            returning: FinalCutPro.FCPXML.Format.self
        ) { element in
            guard let foundFormat = firstFormat(forElementOrAncestors: element, in: resources)
            else { return .failure }
            
            if foundFormat.name == "FFVideoFormatRateUndefined" {
                return .continue
            }
            return .return(withValue: foundFormat)
        }
        
        switch result {
        case .exhaustedAncestors:
            return nil
        case .value(let r):
            return r
        case .failure:
            return nil
        }
    }
    
    static func format(
        forResourceID resourceID: String,
        in resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) -> FinalCutPro.FCPXML.Format? {
        guard let resource = resources[resourceID]
        else { return nil }
        
        return format(for: resource, in: resources)
    }
    
    static func format(
        for resource: AnyResource,
        in resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) -> FinalCutPro.FCPXML.Format? {
        switch resource {
        case let .asset(asset):
            // an asset should contain a format attribute that we can use to look up the actual
            // format resource
            guard let assetFormatID = asset.format else { return nil }
            return format(forResourceID: assetFormatID, in: resources)
            
        case .media(_):
            // TODO: finish this
            print("Error: 'media' resource parsing not yet implemented.")
            return nil
            
        case let .format(format):
            return format
            
        case .effect(_):
            return nil // effects don't carry format info
            
        case .locator(_):
            // TODO: finish this
            print("Error: 'locator' resource parsing not yet implemented.")
            return nil
            
        case .objectTracker(_):
            // TODO: finish this
            print("Error: 'objectTracker' resource parsing not yet implemented.")
            return nil
            
        case .trackingShape(_):
            // TODO: finish this
            print("Error: 'trackingShape' resource parsing not yet implemented.")
            return nil
        }
    }
    
    /// Traverses the parents of the given XML leaf and returns the nearest `tcFormat` attribute if found.
    static func tcFormat(
        forElementOrAncestors xmlLeaf: XMLElement
    ) -> FinalCutPro.FCPXML.TimecodeFormat? {
        let keyName = FinalCutPro.FCPXML.TimecodeFormat.Attributes.tcFormat.rawValue
        guard let (tcFormatValue, _) = xmlLeaf.attributeStringValueTraversingAncestors(forName: keyName),
              let tcFormat = FinalCutPro.FCPXML.TimecodeFormat(rawValue: tcFormatValue)
        else { return nil }
        
        return tcFormat
    }
}

// MARK: - Timecode Utils

extension FinalCutPro.FCPXML {
    /// Utility:
    /// Convert raw attribute value string to `Timecode`.
    static func timecode(
        fromRational rawString: String,
        tcFormat: FinalCutPro.FCPXML.TimecodeFormat,
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
    /// Traverses the parents of the given XML leaf to determine frame rate.
    static func timecode(
        fromRational rawString: String,
        xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) throws -> Timecode? {
        guard let frameRate = timecodeFrameRate(
            for: xmlLeaf,
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
}

// MARK: - Timecode Interval Utils

extension FinalCutPro.FCPXML {
    /// Utility:
    /// Convert raw attribute value string to `TimecodeInterval`.
    /// Traverses the parents of the given XML leaf to determine frame rate.
    static func timecodeInterval(
        fromRational rawString: String,
        xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) throws -> TimecodeInterval? {
        guard let frameRate = timecodeFrameRate(
            for: xmlLeaf,
            in: resources
        )
        else { return nil }
        
        return try timecodeInterval(fromRational: rawString, frameRate: frameRate)
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
