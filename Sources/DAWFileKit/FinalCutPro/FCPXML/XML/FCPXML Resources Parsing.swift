//
//  FCPXML Resources Parsing.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import OTCore
import TimecodeKit

extension XMLElement {
    /// FCPXML: Returns the root-level `fcpxml/resources` element.
    /// This may be called on any element within a FCPXML.
    public var fcpRootResources: XMLElement? {
        fcpRoot?
            .firstChildElement(named: FinalCutPro.FCPXML.Children.resources.rawValue)
    }
    
    /// FCPXML: Returns the resource element for the given resource ID from within the root-level
    /// `fcpxml/resources` element.
    /// This may be called on any element within a FCPXML.
    ///
    /// - Parameters:
    ///   - resourceID: Resource identifier string. (ie: "r1")
    ///   - resources: Optionally supply a resources element.
    ///     If `nil`, the resources from the XML document will be located and used.
    ///     This may be useful with isolated testing when a full FCPXML document is not loaded and
    ///     the document does not contain any resources to be found.
    /// - Returns: Resource element corresponding to the given resource ID.
    public func fcpResource(
        forID resourceID: String,
        in resources: XMLElement? = nil
    ) -> XMLElement? {
        (resources ?? fcpRootResources)?
            .childElements
            .first(whereAttribute: "id", hasValue: resourceID)
    }
    
    /// FCPXML: Returns the resource element referenced by the current element.
    public func fcpResource(
        in resources: XMLElement? = nil
    ) -> XMLElement? {
        _fcpFirstResourceForElementOrAncestors(in: resources)
    }
    
}

// MARK: - Video Frame Rate (from Format Resource)

extension XMLElement {
    /// FCPXML: Returns the video frame rate for the given resource ID.
    /// The resource ID should be for a `format` resource.
    /// This may be called on any element.
    func _fcpVideoFrameRate(
        forResourceID id: String,
        in resources: XMLElement? = nil
    ) -> VideoFrameRate? {
        guard let resource = fcpResource(forID: id, in: resources) else { return nil }
        
        // TODO: More than just `format` resource can contain frame rate info?
        guard resource.fcpElementType == .resource(.format) else { return nil }
        
        return resource._fcpVideoFrameRate()
    }
    
    /// FCPXML: Returns the video frame rate for the given resource ID.
    /// Call this on a `format` resource element.
    func _fcpVideoFrameRate() -> VideoFrameRate? {
        // TODO: More than just `format` resource can contain frame rate info?
        guard fcpElementType == .resource(.format) else { return nil }
        
        let format = fcpAsFormat
        
        let interlaced = format.fieldOrder != nil
        
        guard let frameDuration = format.frameDuration
        else { return nil }
        
        let fRate = VideoFrameRate(frameDuration: frameDuration, interlaced: interlaced)
        return fRate
    }
}

// MARK: - Timecode Frame Rate

extension XMLElement {
    /// FCPXML: Returns the timecode frame rate for the given resource ID.
    /// Traverses parents to determine `tcFormat`.
    func _fcpTimecodeFrameRate(
        resourceID id: String,
        in resources: XMLElement? = nil
    ) -> TimecodeFrameRate? {
        guard let tcFormat = _fcpTCFormatForElementOrAncestors()
        else { return nil }
        
        return _fcpTimecodeFrameRate(forResourceID: id, tcFormat: tcFormat, in: resources)
    }
    
    /// FCPXML: Returns the timecode frame rate for the given resource ID & `tcFormat`.
    func _fcpTimecodeFrameRate(
        forResourceID id: String,
        tcFormat: FinalCutPro.FCPXML.TimecodeFormat,
        in resources: XMLElement? = nil
    ) -> TimecodeFrameRate? {
        guard let videoRate = _fcpVideoFrameRate(forResourceID: id, in: resources),
              let frameRate = videoRate.timecodeFrameRate(drop: tcFormat.isDrop)
        else { return nil }
        return frameRate
    }
    
    /// FCPXML: Returns the timecode frame rate for the given resource ID & `tcFormat`.
    /// Call this on a `format` resource element.
    func _fcpTimecodeFrameRate(
        tcFormat: FinalCutPro.FCPXML.TimecodeFormat
    ) -> TimecodeFrameRate? {
        guard let videoRate = _fcpVideoFrameRate(),
              let frameRate = videoRate.timecodeFrameRate(drop: tcFormat.isDrop)
        else { return nil }
        return frameRate
    }
    
    /// FCPXML: Returns the timecode frame rate for the given resource ID.
    /// Traverses parents to determine `format` (resource ID) and `tcFormat`.
    func _fcpTimecodeFrameRate(
        in resources: XMLElement? = nil
    ) -> TimecodeFrameRate? {
        guard let format = _fcpFirstDefinedFormatResourceForElementOrAncestors(in: resources),
              let tcFormat = _fcpTCFormatForElementOrAncestors()
        else { return nil }
        
        return format._fcpTimecodeFrameRate(tcFormat: tcFormat)
    }
}

// MARK: - Resource Utils

extension XMLElement {
    /// FCPXML: Traverses the parents of the element and returns the resource corresponding to the
    /// nearest `format` attribute if found.
    ///
    /// - Returns: A resource element.
    func _fcpFirstResourceForElementOrAncestors(
        in resources: XMLElement? = nil
    ) -> XMLElement? {
        if let (_, resourceID) = ancestorElements(includingSelf: true).first(withAttribute: "ref") {
            return fcpResource(forID: resourceID, in: resources)
        }
        
        // fall back to checking for format
        if let (_, resourceID) = ancestorElements(includingSelf: true).first(withAttribute: "format") {
            return fcpResource(forID: resourceID, in: resources)
        }
        
        return nil
    }
}

// MARK: - Format Resource Utils

extension XMLElement {
    /// FCPXML: If the resource with the given ID is a `format`, it is returned.
    /// Otherwise, references are followed until a `format` is found.
    /// This may be called on any element within a FCPXML.
    ///
    /// - Returns: `format` resource element.
    func _fcpFormatResource(
        forResourceID resourceID: String,
        in resources: XMLElement? = nil
    ) -> XMLElement? {
        guard let resource = fcpResource(forID: resourceID, in: resources)
        else { return nil }
        
        return resource._fcpFormatResource(in: resources)
    }
    
    /// FCPXML: If the resource is a `format`, it is returned.
    /// Otherwise, references are followed until a `format` is found.
    ///
    /// - Returns: `format` resource element.
    func _fcpFormatResource(
        in resources: XMLElement? = nil
    ) -> XMLElement? {
        guard let fcpResourceType = fcpResourceType else { return nil }
        switch fcpResourceType {
        case .asset:
            // an asset should contain a format attribute that we can use to look up the actual
            // format resource
            guard let assetFormatID = fcpFormat else { return nil }
            return _fcpFormatResource(forResourceID: assetFormatID, in: resources)
            
        case .media:
            // TODO: finish this
            print("Error: 'media' resource parsing not yet implemented.")
            return nil
            
        case .format:
            return self
            
        case .effect:
            return nil // effects don't carry format info
            
        case .locator:
            // TODO: finish this
            print("Error: 'locator' resource parsing not yet implemented.")
            return nil
            
        case .objectTracker:
            // TODO: finish this
            print("Error: 'objectTracker' resource parsing not yet implemented.")
            return nil
            
        case .trackingShape:
            // TODO: finish this
            print("Error: 'trackingShape' resource parsing not yet implemented.")
            return nil
        }
    }
    
    /// FCPXML: Traverses the parents of the element and returns the resource corresponding
    /// to the nearest `format` attribute if found.
    ///
    /// - Returns: `format` resource element.
    func _fcpFirstFormatResourceForElementOrAncestors(
        in resources: XMLElement? = nil
    ) -> XMLElement? {
        if let (_, resourceID) = ancestorElements(includingSelf: true).first(withAttribute: "format") {
            return fcpResource(forID: resourceID, in: resources)
        }
        
        // `ref` could point to any resource and not just format, ie: asset or effect.
        // we need to continue drilling into it.
        if let (_, refResourceID) = ancestorElements(includingSelf: true).first(withAttribute: "ref"),
           let refResource = fcpResource(forID: refResourceID, in: resources)
        {
            if refResource.fcpElementType == .resource(.format) {
                return refResource
            } else {
                // recurse
                return refResource._fcpFirstFormatResourceForElementOrAncestors(in: resources)
            }
        }
        
        return nil
    }
    
    /// FCPXML: Traverses the parents of the element and returns the nearest defined resource.
    ///
    /// - Returns: `format` resource element.
    func _fcpFirstDefinedFormatResourceForElementOrAncestors(
        in resources: XMLElement? = nil
    ) -> XMLElement? {
        // note that an audio clip may point to a resource with name `FFVideoFormatRateUndefined`.
        // this should not be an error case; instead, continue traversing.
        
        let result = walkAncestorElements(
            includingSelf: true,
            returning: XMLElement.self
        ) { element in
            guard let foundFormat = element._fcpFirstFormatResourceForElementOrAncestors(in: resources)
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
}

// MARK: - Media Resource Utils

extension XMLElement {
    /// Utility:
    /// If the resource with the given ID is a format, it is returned.
    /// Otherwise, references are followed until a format is found.
    ///
    /// - Returns: `media` resource element.
    func _fcpMediaResource(
        forResourceID resourceID: String,
        in resources: XMLElement? = nil
    ) -> XMLElement? {
        guard let resource = fcpResource(forID: resourceID, in: resources),
              resource.fcpResourceType == .media
        else { return nil }
        
        return resource
    }
    
    /// FCPXML: Looks up the resource for the element and returns its `media-rep` element, if any.
    ///
    /// - Returns: `media-rep` element.
    func _fcpMediaRep(
        in resources: XMLElement? = nil
    ) -> XMLElement? {
        guard let resource = _fcpFirstResourceForElementOrAncestors(in: resources),
              let resourceType = resource.fcpResourceType
        else { return nil }
        
        switch resourceType {
        case .asset: return resource.fcpAsAsset.mediaRep
        case .effect: return nil
        case .format: return nil
        case .locator: return nil // contains a URL but not a `media-rep`
        case .media: return nil // TODO: can contain `sequence` or `multicam`
        case .objectTracker: return nil
        case .trackingShape: return nil
        }
    }
    
    /// FCPXML: Looks up the resource for the element and returns its media url, if any.
    func fcpMediaURL(
        in resources: XMLElement? = nil
    ) -> URL? {
        guard let resource = _fcpFirstResourceForElementOrAncestors(in: resources),
              let resourceType = resource.fcpResourceType
        else { return nil }
        
        switch resourceType {
        case .asset: return resource.fcpAsAsset.mediaRep?.fcpAsMediaRep.src
        case .effect: return nil
        case .format: return nil
        case .locator: return resource.fcpAsLocator.url
        case .media: return nil // TODO: can contain `sequence` or `multicam`
        case .objectTracker: return nil
        case .trackingShape: return nil
        }
    }
}

#endif
