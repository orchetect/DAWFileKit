//
//  FCPXML Format.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    /// Format shared resource.
    ///
    /// > Final Cut Pro FCPXML 1.11 Reference:
    /// >
    /// > Reference a video-format definition.
    /// >
    /// > Use this element to reference one of the video formats listed under Predefined Video
    /// > Formats through the name attribute, or use it to describe a custom video format using the
    /// > Format Element Attributes. For audio only assets, use the `FFFrameRateUndefined` format.
    /// >
    /// > When Format Element Attributes exist, they override the predefined format value identified
    /// > by the name attribute.
    /// >
    /// > See [`format`](https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/format).
    public struct Format: Equatable, Hashable {
        // shared resource attributes
        public var id: String // required
        public var name: String?
        
        // format attributes
        public var frameDuration: String?
        public var fieldOrder: String?
        public var width: Int?
        public var height: Int?
        public var paspH: String? // TODO: should this be Int or Double?
        public var paspV: String? // TODO: should this be Int or Double?
        public var colorSpace: String?
        public var projection: String?
        public var stereoscopic: String?
        
        public init(
            id: String,
            name: String?,
            frameDuration: String?,
            fieldOrder: String?,
            width: Int?,
            height: Int?,
            paspH: String?,
            paspV: String?,
            colorSpace: String?,
            projection: String?,
            stereoscopic: String?
        ) {
            // shared resource attributes
            self.id = id
            self.name = name
            
            // format attributes
            self.frameDuration = frameDuration
            self.fieldOrder = fieldOrder
            self.width = width
            self.height = height
            self.paspH = paspH
            self.paspV = paspV
            self.colorSpace = colorSpace
            self.projection = projection
            self.stereoscopic = stereoscopic
        }
    }
}

extension FinalCutPro.FCPXML.Format: FCPXMLResource {
    /// Attributes unique to ``Format``.
    public enum Attributes: String, XMLParsableAttributesKey {
        // shared resource attributes
        case id
        case name
        
        // format attributes
        case frameDuration
        case fieldOrder // only present if video is interlaced
        case width
        case height
        case paspH
        case paspV
        case colorSpace
        case projection
        case stereoscopic // note that Apple docs misspell it as "sterioscopic"
    }
    
    public init?(from xmlLeaf: XMLElement) {
        let rawValues = xmlLeaf.parseRawAttributeValues(key: Attributes.self)
        
        // shared resource attributes
        guard let id = rawValues[.id] else { return nil }
        self.id = id
        name = rawValues[.name]
        
        // format attributes
        frameDuration = rawValues[.frameDuration]
        fieldOrder = rawValues[.fieldOrder]
        width = Int(rawValues[.width] ?? "")
        height = Int(rawValues[.height] ?? "")
        paspH = rawValues[.paspH]
        paspV = rawValues[.paspV]
        colorSpace = rawValues[.colorSpace]
        projection = rawValues[.projection]
        stereoscopic = rawValues[.stereoscopic]
        
        // validate element name
        // (we have to do this last, after all properties are initialized in order to access self)
        guard xmlLeaf.name == resourceType.rawValue else { return nil }
    }
    
    public var resourceType: FinalCutPro.FCPXML.ResourceType { .format }
    public func asAnyResource() -> FinalCutPro.FCPXML.AnyResource { .format(self) }
}

#endif
