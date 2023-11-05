//
//  FCPXMLTimingAttributes.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

/// Story element that can contain [Timing Attributes](
/// https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/story_elements/timing_attributes
/// ).
///
/// - `offset`
/// - `start`
/// - `duration`
///
/// > Final Cut Pro FCPXML 1.11 Reference:
/// >
/// > Schedule the element and its contained or anchored items in a timeline.
/// >
/// > Typically, timing attribute values are a multiple of the frame duration for the respective
/// > timeline. Otherwise, Final Cut Pro inserts a gap to maintain the specified timing upon import.
/// > A warning message appears when this happens.
/// >
/// > The parent elements limit the time range for contained items. But, they don’t limit the time
/// > range for anchored items. However, an ancestor that either directly or indirectly contains the
/// > parent may limit anchored items.
public protocol FCPXMLTimingAttributes {
    /// An element’s location in parent time, or base element’s time for an anchor.
    var offset: Timecode { get }
    
    /// The start of an element’s local timeline used to schedule its contained and anchored items.
    var start: Timecode { get }
    
    /// An element’s extent (length) in parent time.
    var duration: Timecode { get }
}

public enum FCPXMLTimingAttributesKey: String, XMLParsableAttributesKey {
    case offset
    case start
    case duration
}

extension FCPXMLTimingAttributes {
    fileprivate typealias Key = FCPXMLTimingAttributesKey
    
    // MARK: - Raw Values
    
    static func parseTimingAttributesRawValues(
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.Resource]
    ) -> [FCPXMLTimingAttributesKey: String] {
        xmlLeaf.parseAttributesRawValues(key: Key.self)
    }
    
    // MARK: - Typed Values
    
    /// Parse attributes if present, and return typed values.
    static func parseTimingAttributes(
        frameRate: TimecodeFrameRate,
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.Resource]
    ) -> (
        offset: Timecode?,
        start: Timecode?,
        duration: Timecode?
    ) {
        let rawValues = parseTimingAttributesRawValues(from: xmlLeaf, resources: resources)
        
        // `offset`
        let offset = try? FinalCutPro.FCPXML.timecode(
            fromRational: rawValues[.offset] ?? "", 
            frameRate: frameRate
        )
        
        // `start`
        let start = try? FinalCutPro.FCPXML.timecode(
            fromRational: rawValues[.start] ?? "", 
            frameRate: frameRate
        )
        
        // `duration`
        let duration = try? FinalCutPro.FCPXML.timecode(
            fromRational: rawValues[.duration] ?? "", 
            frameRate: frameRate
        )
        
        return (
            offset: offset,
            start: start,
            duration: duration
        )
    }
    
    // MARK: - Defaults and Validation
    
    /// Parse attributes if present, and return typed values.
    /// A default will be provided for any missing attributes, and any errors or missing values
    /// will be logged to the console.
    static func parseTimingAttributesDefaulted(
        frameRate: TimecodeFrameRate,
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.Resource],
        logErrors: Bool = true
    ) -> (
        offset: Timecode,
        start: Timecode,
        duration: Timecode
    ) {
        let attrs = parseTimingAttributes(
            frameRate: frameRate,
            from: xmlLeaf,
            resources: resources
        )
        
        let offset = validateTimingAttributes(offset: attrs.offset, frameRate: frameRate, logErrors: logErrors)
        let start = validateTimingAttributes(start: attrs.start, frameRate: frameRate, logErrors: logErrors)
        let duration = validateTimingAttributes(duration: attrs.duration, frameRate: frameRate, logErrors: logErrors)
        
        return (
            offset: offset,
            start: start,
            duration: duration
        )
    }
    
    /// Provides suitable default if necessary.
    static func validateTimingAttributes(
        offset timecode: Timecode?,
        frameRate: TimecodeFrameRate,
        logErrors: Bool = true
    ) -> Timecode {
        guard let timecode = timecode else {
            let defaultTimecode = FinalCutPro.formTimecode(at: frameRate)
            if logErrors {
                print("Error: offset could not be decoded. Defaulting to \(defaultTimecode.stringValue()) @ \(frameRate.stringValueVerbose).")
            }
            return defaultTimecode
        }
        return timecode
    }
    
    /// Provides suitable default if necessary.
    static func validateTimingAttributes(
        start timecode: Timecode?,
        frameRate: TimecodeFrameRate,
        logErrors: Bool = true
    ) -> Timecode {
        guard let timecode = timecode else {
            let defaultTimecode = FinalCutPro.formTimecode(at: frameRate)
            if logErrors {
                print("Error: start could not be decoded. Defaulting to \(defaultTimecode.stringValue()) @ \(frameRate.stringValueVerbose).")
            }
            return defaultTimecode
        }
        return timecode
    }
    
    /// Provides suitable default if necessary.
    static func validateTimingAttributes(
        duration timecode: Timecode?,
        frameRate: TimecodeFrameRate,
        logErrors: Bool = true
    ) -> Timecode {
        guard let timecode = timecode else {
            let defaultTimecode = FinalCutPro.formTimecode(at: frameRate)
            if logErrors {
                print("Error: duration could not be decoded. Defaulting to \(defaultTimecode.stringValue()) @ \(frameRate.stringValueVerbose).")
            }
            return defaultTimecode
        }
        return timecode
    }
}

#endif
