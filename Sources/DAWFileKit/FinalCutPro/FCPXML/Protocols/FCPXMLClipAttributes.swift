//
//  FCPXMLClipAttributes.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

/// Attributes common to all story elements.
///
/// - `lane` (from `FCPXMLAnchorableAttributes`)
/// - `offset` (from `FCPXMLAnchorableAttributes`)
/// - `name`
/// - `start`
/// - `duration`
/// - `enabled`
///
/// Equivalent to `%clip_attrs` in the DTD.
///
/// Where applicable the duration attribute is implied, and comes from the underlying media.
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
public protocol FCPXMLClipAttributes: FCPXMLAnchorableAttributes {
    /// Clip name.
    var name: String? { get }
    
    /// The start of the element’s local timeline used to schedule its contained and anchored items.
    var start: Timecode? { get }
    
    /// An element’s extent (length) in parent time.
    var duration: Timecode? { get }
    
    /// Enabled state.
    /// Default is `true`, and the absence of this attribute implies this default.
    var enabled: Bool { get }
}

public enum FCPXMLClipAttributesKey: String, XMLParsableAttributesKey {
    case name
    case start
    case duration
    case enabled
}

extension FCPXMLClipAttributes {
    fileprivate typealias Key = FCPXMLClipAttributesKey
    
    // MARK: - Raw Values
    
    static func parseClipAttributesRawValues(
        from xmlLeaf: XMLElement
    ) -> [FCPXMLClipAttributesKey: String] {
        xmlLeaf.parseAttributesRawValues(key: Key.self)
    }
    
    // MARK: - Typed Values
    
    /// Parse attributes if present, and return typed values.
    /// Defaultable values will be returned as non-optional whether present in the XML or not.
    static func parseClipAttributes(
        frameRate: TimecodeFrameRate,
        from xmlLeaf: XMLElement
    ) -> (
        lane: Int?,
        offset: Timecode?,
        name: String?,
        start: Timecode?,
        duration: Timecode?,
        enabled: Bool
    ) {
        // FCPXMLAnchorableAttributes keys
        
        let anchorableValues = parseAnchorableAttributes(frameRate: frameRate, from: xmlLeaf)
        
        // `lane`
        let lane = anchorableValues.lane
        
        // `offset`
        let offset = anchorableValues.offset
        
        // FCPXMLClipAttributes keys
        
        let rawValues = parseClipAttributesRawValues(from: xmlLeaf)
        
        // `name`
        let name = rawValues[.name]
        
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
        
        let enabled: Bool = {
            guard let zeroOrOne = rawValues[.enabled] else { return true }
            switch zeroOrOne {
            case "0": return false
            case "1": return true
            default:
                print("Unexpected enabled value: \(zeroOrOne)")
                return true
            }
        }()
        
        return (
            lane: lane,
            offset: offset,
            name: name,
            start: start,
            duration: duration,
            enabled: enabled
        )
    }
    
    // TODO: not used?
    static func parseClipAttributes<C: FCPXMLTimelineAttributes>(
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource],
        timelineContext: C.Type,
        timelineContextInstance: C
    ) -> (
        lane: Int?,
        offset: Timecode?,
        name: String?,
        start: Timecode?,
        duration: Timecode?,
        enabled: Bool
    )? {
        guard let frameRate = FinalCutPro.FCPXML.parseTimecodeFrameRate(
            from: xmlLeaf,
            resources: resources,
            timelineContext: timelineContext,
            timelineContextInstance: timelineContextInstance
        ) else { return nil }
        return parseClipAttributes(frameRate: frameRate, from: xmlLeaf)
    }
}

#endif
