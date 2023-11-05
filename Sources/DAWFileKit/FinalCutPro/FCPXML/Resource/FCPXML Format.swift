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
        public let name: String
        public let id: String
        
        // format attributes
        public let frameDuration: String
        public let fieldOrder: String?
        public let width: Int
        public let height: Int
        public let paspH: String? // TODO: should this be Int or Double?
        public let paspV: String? // TODO: should this be Int or Double?
        public let colorSpace: String
        public let projection: String?
        public let stereoscopic: String?
        
        // TODO: add missing attributes
        
        init(
            name: String,
            id: String,
            frameDuration: String,
            fieldOrder: String?,
            width: Int,
            height: Int,
            paspH: String?,
            paspV: String?,
            colorSpace: String,
            projection: String?,
            stereoscopic: String?
        ) {
            // shared resource attributes
            self.name = name
            self.id = id
            
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
        
        init(from xmlLeaf: XMLElement) {
            // shared resource attributes
            name = xmlLeaf.attributeStringValue(forName: Attributes.name.rawValue) ?? ""
            id = xmlLeaf.attributeStringValue(forName: Attributes.id.rawValue) ?? ""
            
            // format attributes
            frameDuration = xmlLeaf.attributeStringValue(forName: Attributes.frameDuration.rawValue) ?? ""
            fieldOrder = xmlLeaf.attributeStringValue(forName: Attributes.fieldOrder.rawValue)
            width = Int(xmlLeaf.attributeStringValue(forName: Attributes.width.rawValue) ?? "") ?? 0
            height = Int(xmlLeaf.attributeStringValue(forName: Attributes.height.rawValue) ?? "") ?? 0
            paspH = xmlLeaf.attributeStringValue(forName: Attributes.paspH.rawValue)
            paspV = xmlLeaf.attributeStringValue(forName: Attributes.paspV.rawValue)
            colorSpace = xmlLeaf.attributeStringValue(forName: Attributes.colorSpace.rawValue) ?? ""
            projection = xmlLeaf.attributeStringValue(forName: Attributes.projection.rawValue)
            stereoscopic = xmlLeaf.attributeStringValue(forName: Attributes.stereoscopic.rawValue)
        }
    }
}

extension FinalCutPro.FCPXML.Format {
    public enum Attributes: String {
        // shared resource attributes
        case name
        case id
        
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
}

#endif
