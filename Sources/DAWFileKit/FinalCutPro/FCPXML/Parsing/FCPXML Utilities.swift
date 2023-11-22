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
    // TODO: I think more than just `format` resource can contain frame rate info?
    /// Utility:
    /// Convenience: returns the video frame rate for the given resource ID.
    static func videoFrameRate(
        forResourceID id: String,
        in resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) -> VideoFrameRate? {
        guard case let .format(resource) = resources[id] else { return nil }
        return videoFrameRate(for: resource)
    }
    
    /// Utility:
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
    
    /// Utility:
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
    
    /// Utility:
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
    
    /// Utility:
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
    
    /// Utility:
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
}

// MARK: - Format Resource Utils

extension FinalCutPro.FCPXML {
    /// Utility:
    /// Traverses the parents of the given XML leaf and returns the resource corresponding to the
    /// nearest `format` attribute if found.
    static func firstResource(
        forElementOrAncestors xmlLeaf: XMLElement,
        in resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) -> AnyResource? {
        if let (resourceID, _) = xmlLeaf.attributeStringValueTraversingAncestors(forName: "ref") {
            return resources[resourceID]
        }
        // ref could point to any resource and not just format, ie: asset or effect. we need to
        // continue drilling into it.
        if let (resourceID, _) = xmlLeaf.attributeStringValueTraversingAncestors(forName: "format") {
            return resources[resourceID]
        }
        return nil
    }
}

// MARK: - Resource Utils

extension FinalCutPro.FCPXML {
    /// Utility:
    /// Looks up the resource for the element and returns its ``MediaRep`` instance, if any.
    static func mediaRep(
        for xmlLeaf: XMLElement,
        in resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) -> MediaRep? {
        guard let resource = firstResource(forElementOrAncestors: xmlLeaf, in: resources)
        else { return nil }
        
        switch resource {
        case let .asset(asset): return asset.mediaRep
        case .effect(_): return nil
        case .format(_): return nil
        case .locator(_): return nil // contains a URL but not a MediaRep
        case .media(_): return nil // TODO: can contain sequence or multicam
        case .objectTracker(_): return nil
        case .trackingShape(_): return nil
        }
    }
    
    /// Utility:
    /// Looks up the resource for the element and returns its media url, if any.
    static func mediaURL(
        for xmlLeaf: XMLElement,
        in resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) -> URL? {
        guard let resource = firstResource(forElementOrAncestors: xmlLeaf, in: resources)
        else { return nil }
        
        switch resource {
        case let .asset(asset): return asset.mediaRep?.src
        case .effect(_): return nil
        case .format(_): return nil
        case let .locator(locator): return locator.url
        case .media(_): return nil // TODO: can contain sequence or multicam
        case .objectTracker(_): return nil
        case .trackingShape(_): return nil
        }
    }
    
}

// MARK: - Format Resource Utils

extension FinalCutPro.FCPXML {
    /// Utility:
    /// Traverses the parents of the given XML leaf and returns the resource corresponding to the
    /// nearest `format` attribute if found.
    static func firstFormat(
        forElementOrAncestors xmlLeaf: XMLElement,
        in resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) -> Format? {
        if let (resourceID, _) = xmlLeaf.attributeStringValueTraversingAncestors(forName: "format") {
            return format(forResourceID: resourceID, in: resources)
        }
        // ref could point to any resource and not just format, ie: asset or effect. we need to
        // continue drilling into it.
        if let (resourceID, _) = xmlLeaf.attributeStringValueTraversingAncestors(forName: "ref") {
            if let refResource = resources[resourceID] {
                return format(for: refResource, in: resources)
            }
        }
        return nil
    }
    
    /// Utility:
    /// Traverses the parents of the given XML leaf and returns the nearest defined resource.
    static func firstDefinedFormat(
        forElementOrAncestors xmlLeaf: XMLElement,
        in resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) -> Format? {
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
    
    /// Utility:
    /// If the resource with the given ID is a format, it is returned.
    /// Otherwise, references are followed until a format is found.
    static func format(
        forResourceID resourceID: String,
        in resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) -> Format? {
        guard let resource = resources[resourceID]
        else { return nil }
        
        return format(for: resource, in: resources)
    }
    
    /// Utility:
    /// If the resource is a format, it is returned.
    /// Otherwise, references are followed until a format is found.
    static func format(
        for resource: AnyResource,
        in resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) -> Format? {
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
    
    /// Utility:
    /// Traverses the parents of the given XML leaf and returns the nearest `tcFormat` attribute if found.
    static func tcFormat(
        forElementOrAncestors xmlLeaf: XMLElement
    ) -> TimecodeFormat? {
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

// MARK: - Roles

extension FinalCutPro.FCPXML {
    public enum Role: Equatable, Hashable {
        case audio(_ role: String)
        case video(_ role: String)
        case nonSpecific(_ role: String)
    }
    
    // TODO: include func parameter `includeDefaultRoles: Bool` to synthesize FCP's default audio and video roles when they don't exist?
    static func roles(
        of xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource],
        auditionMask: Audition.Mask // = .activeAudition
    ) -> Set<Role> {
        guard let elementType = ElementType(from: xmlLeaf) else { return [] }
        
        var roles: Set<Role> = []
        
        switch elementType {
        case let .story(storyElementType):
            switch storyElementType {
            case let .anyAnnotation(annotationType):
                switch annotationType {
                case .caption:
                    if let role = xmlLeaf.attributeStringValue(forName: Caption.Attributes.role.rawValue) {
                        roles.insert(.nonSpecific(role))
                    }
                    
                case .keyword:
                    break
                    
                case .marker, .chapterMarker:
                    break
                }
                
            case let .anyClip(clipType):
                switch clipType {
                case .assetClip:
                    var roles: [Role] = []
                    if let audioRole = xmlLeaf.attributeStringValue(forName: AssetClip.Attributes.audioRole.rawValue) {
                        roles.insert(.audio(audioRole))
                    }
                    if let videoRole = xmlLeaf.attributeStringValue(forName: AssetClip.Attributes.videoRole.rawValue) {
                        roles.insert(.video(videoRole))
                    }
                    
                case .audio:
                    if let audioRole = xmlLeaf.attributeStringValue(forName: Audio.Attributes.role.rawValue) {
                        return [.audio(audioRole)]
                    }
                    
                case .audition:
                    // contains clip(s) that may have their own roles but they are their own elements
                    // so we won't parse them here
                    break
                    
                case .clip:
                    break
                    
                case .gap:
                    break
                    
                case .liveDrawing:
                    // TODO: has role(s)?
                    break
                    
                case .mcClip:
                    // does not have roles itself. references multicam clip(s).
                    break
                    
                case .refClip:
                    // does not have video role itself. it references a sequence that may contain clips with their own roles.
                    // has audio subroles that are enable-able.
                    
                    let useAudioSubroles = xmlLeaf.attributeStringValue(forName: RefClip.Attributes.useAudioSubroles.rawValue) == "1"
                    if useAudioSubroles {
                        let audioRoleSources = FinalCutPro.FCPXML.RefClip.parseAudioRoleSources(from: xmlLeaf)
                        let audioRoles = audioRoleSources.map { $0.role }.map { Role.audio($0) }
                        roles.formUnion(audioRoles)
                    }
                    
                case .syncClip:
                    // does not have roles itself. contains story elements that may contain their own roles.
                    break
                    
                case .title:
                    if let videoRole = xmlLeaf.attributeStringValue(forName: Title.Attributes.role.rawValue) {
                        roles.insert(.video(videoRole))
                    }
                    
                case .video:
                    if let videoRole = xmlLeaf.attributeStringValue(forName: Video.Attributes.role.rawValue) {
                        roles.insert(.video(videoRole))
                    }
                }
                
            case .sequence:
                break
                
            case .spine:
                break
            }
            
        case .structure:
            // structure elements don't have roles
            break
        }
        
        return []
    }
    
    // TODO: include func parameter `includeDefaultRoles: Bool` to synthesize FCP's default audio and video roles when they don't exist?
    static func rolesOfElementAndAncestors(
        of xmlLeaf: XMLElement,
        breadcrumbs: [XMLElement],
        resources: [String: FinalCutPro.FCPXML.AnyResource],
        auditionMask: Audition.Mask // = .activeAudition
    ) -> Set<Role> {
        Set(
            breadcrumbs.flatMap {
                roles(of: $0, resources: resources, auditionMask: auditionMask)
            }
        )
    }
}

#endif
