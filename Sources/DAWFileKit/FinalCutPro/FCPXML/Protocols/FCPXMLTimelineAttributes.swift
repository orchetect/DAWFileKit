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
/// - `format`
/// - `tcFormat`
/// - `tcStart`
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
    
    // "tcStart", also parses "tcFormat"
    /// The timecode origin represented as a time value.
    var startTimecode: Timecode { get }
}

public enum FCPXMLTimelineAttributesKey: String, XMLParsableAttributesKey {
    case format
    case tcFormat // once parsed, can be determined from `startTimecode.isDrop` property
    case tcStart
}

extension FCPXMLTimelineAttributes {
    fileprivate typealias Key = FCPXMLTimelineAttributesKey
    
    // MARK: - Raw Values
    
    static func parseTimelineAttributesRawValues(
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.Resource]
    ) -> [FCPXMLTimelineAttributesKey: String] {
        xmlLeaf.parseAttributesRawValues(key: Key.self)
    }
    
    // MARK: - Typed Values
    
    /// Parse attributes if present, and return typed values.
    static func parseTimelineAttributes(
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.Resource]
    ) -> (
        format: String?,
        timecodeFormat: FinalCutPro.FCPXML.TimecodeFormat?,
        startTimecode: Timecode?
    ) {
        let rawValues = parseTimelineAttributesRawValues(from: xmlLeaf, resources: resources)
        
        // `format`
        let format = rawValues[.format]
        
        // `tcFormat`
        let tcFormat = FinalCutPro.FCPXML.TimecodeFormat(rawValue: rawValues[.tcFormat] ?? "")
        
        // `tcStart`
        let startTimecode = try? FinalCutPro.FCPXML.timecode(
            fromRational: rawValues[.tcStart] ?? "",
            tcFormat: tcFormat,
            resourceID: format ?? "",
            resources: resources
        )
        
        return (
            format: format,
            timecodeFormat: tcFormat,
            startTimecode: startTimecode
        )
    }
    
    // MARK: - Defaults and Validation
    
    /// Parse attributes if present, and return typed values.
    /// A default will be provided for any missing attributes, and any errors or missing values
    /// will be logged to the console.
    static func parseTimelineAttributesDefaulted(
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.Resource]
    ) -> (
        format: String,
        timecodeFormat: FinalCutPro.FCPXML.TimecodeFormat,
        startTimecode: Timecode
    ) {
        let attrs = parseTimelineAttributes(
            from: xmlLeaf, 
            resources: resources
        )
        
        let format = validateTimelineAttributes(format: attrs.format)
        let timecodeFormat = validateTimelineAttributes(timecodeFormat: attrs.timecodeFormat)
        let startTimecode = validateTimelineAttributes(startTimecode: attrs.startTimecode)
        
        return (
            format: format,
            timecodeFormat: timecodeFormat,
            startTimecode: startTimecode
        )
    }
    
    /// Provides suitable default if necessary.
    static func validateTimelineAttributes(
        format: String?
    ) -> String {
        format ?? ""
    }
    
    /// Provides suitable default if necessary.
    static func validateTimelineAttributes(
        timecodeFormat: FinalCutPro.FCPXML.TimecodeFormat?
    ) -> FinalCutPro.FCPXML.TimecodeFormat {
        guard let timecodeFormat = timecodeFormat else {
            print("Error: tcFormat could not be decoded. Defaulting to non-drop (NDF).")
            return .nonDropFrame
        }
        return timecodeFormat
    }
    
    /// Provides suitable default if necessary.
    static func validateTimelineAttributes(
        startTimecode: Timecode?
    ) -> Timecode {
        guard let startTimecode = startTimecode else {
            let defaultTimecode = FinalCutPro.formTimecode(at: .fps30)
            print("Error: tcStart could not be decoded. Defaulting to \(defaultTimecode.stringValue()) @ 30fps.")
            return defaultTimecode
        }
        return startTimecode
    }
}

#endif
