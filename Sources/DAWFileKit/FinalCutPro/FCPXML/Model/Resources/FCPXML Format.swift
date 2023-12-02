//
//  FCPXML Format.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

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
    public enum Format { }
}

extension FinalCutPro.FCPXML.Format {
    public static let resourceType: FinalCutPro.FCPXML.ResourceType = .format
    
    public enum Attributes: String, XMLParsableAttributesKey {
        // shared resource attributes
        case id // required
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
}

#endif
