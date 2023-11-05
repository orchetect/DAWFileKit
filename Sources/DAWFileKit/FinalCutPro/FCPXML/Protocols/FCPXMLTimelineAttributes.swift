//
//  FCPXMLTimelineAttributes.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
@_implementationOnly import OTCore

/// Story element that can contain [Timeline Attributes](
/// https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/story_elements/timeline_attributes
/// ).
///
/// - `format` (required)
/// - `tcFormat`
/// - `tcStart`
/// - `duration`
///
/// Equivalent to `%media_attrs` in the DTD.
///
/// Applies to `sequence` and `multicam` containers.
///
/// > Final Cut Pro FCPXML 1.11 Reference:
/// >
/// > Define characteristics of a timeline.
/// >
/// > The `sequence` element creates a new timeline. Use the timeline attributes to define its
/// > characteristics. Use the attributes with the `clip` element, when it appears as a top-level
/// > story element, to describe a browser clip in an event.
public protocol FCPXMLTimelineAttributes {
    // a.k.a. resource ID
    /// A reference to the video format defined by the `format` element.
    var format: String { get }
    
    // `tcStart`, also parses `tcFormat`
    /// The timecode origin represented as a time value.
    var start: Timecode? { get }
    
    /// The timeline's extent (length) in parent time.
    var duration: Timecode? { get }
}

public enum FCPXMLTimelineAttributesKey: String, XMLParsableAttributesKey {
    case format
    case tcFormat // once parsed, can be determined from `startTimecode.isDrop` property
    case tcStart
    case duration
}

extension FCPXMLTimelineAttributes {
    fileprivate typealias Key = FCPXMLTimelineAttributesKey
    
    // MARK: - Raw Values
    
    static func parseTimelineAttributesRawValues(
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) -> [FCPXMLTimelineAttributesKey: String] {
        xmlLeaf.parseAttributesRawValues(key: Key.self)
    }
    
    // MARK: - Typed Values
    
    /// Parse attributes if present, and return typed values.
    /// If required keys are not present and are not defaultable, this method returns `nil`.
    static func parseTimelineAttributes(
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) -> (
        format: String,
        timecodeFormat: FinalCutPro.FCPXML.TimecodeFormat?,
        start: Timecode?,
        duration: Timecode?
    )? {
        let rawValues = parseTimelineAttributesRawValues(from: xmlLeaf, resources: resources)
        
        // `format`
        guard let format = rawValues[.format] else { return nil }
        
        // `tcFormat`
        let tcFormat = FinalCutPro.FCPXML.TimecodeFormat(rawValue: rawValues[.tcFormat] ?? "")
        
        // `tcStart`
        let start = try? FinalCutPro.FCPXML.timecode(
            fromRational: rawValues[.tcStart] ?? "",
            tcFormat: tcFormat,
            resourceID: format,
            resources: resources
        )
        
        // `duration`
        let duration = try? FinalCutPro.FCPXML.timecode(
            fromRational: rawValues[.duration] ?? "",
            tcFormat: tcFormat,
            resourceID: format,
            resources: resources
        )
        
        return (
            format: format,
            timecodeFormat: tcFormat,
            start: start,
            duration: duration
        )
    }
}

#endif
