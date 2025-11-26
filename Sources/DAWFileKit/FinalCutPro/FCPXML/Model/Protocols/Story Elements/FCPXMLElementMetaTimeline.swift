//
//  FCPXMLElementMetaTimeline.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2024 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import SwiftExtensions
import TimecodeKitCore

/// A meta protocol that all timeline and pseudo-timeline elements conform to.
///
/// This provides properties that can intelligently infer common properties such as timeline start
/// timecode or duration timecode.
public protocol FCPXMLElementMetaTimeline: FCPXMLElement {
    /// Returns the timeline model wrapped in a type-erased ``FinalCutPro/FCPXML/AnyTimeline`` instance.
    func asAnyTimeline() -> FinalCutPro.FCPXML.AnyTimeline
}

extension FCPXMLElementMetaTimeline {
    /// Returns the timeline's name.
    public var timelineName: String? {
        element.fcpName
    }
    
    /// Returns the timeline's local start as timecode.
    public func timelineStartAsTimecode() -> Timecode? {
        element._fcpTimelineStartAsTimecode()
    }
    
    /// Returns the timeline's local duration as timecode.
    public func timelineDurationAsTimecode() -> Timecode? {
        element._fcpTimelineDurationAsTimecode()
    }
}

// MARK: - XML Helpers

extension XMLElement {
    func _fcpTimelineStartAsTimecode() -> Timecode? {
        // TODO: this hasn't been fully unit tested for every timeline type; it's likely this method will need to be structured as a switch-case on timeline element type because there may be specific handling needed for various different timeline element types
        
        // check for parent project if local timeline is a sequence or spine
        if let fcpElementType,
           fcpElementType == .spine,
           let parent = parentElement,
           parent.fcpElementType == .sequence,
           var sequenceStart = parent._fcpTimelineStartAsTimecode()
        {
            if let offset = parent.fcpOffset {
                try? sequenceStart.add(.rational(offset))
            }
            return sequenceStart
        }
        
        // check for local `tcstart` or `start` attribute
        if let localTC = _fcpTCStartAsTimecode(frameRateSource: .localToElement)
            ?? _fcpStartAsTimecode(frameRateSource: .localToElement, default: nil)
        {
            return localTC
        }
        
        // check for local `offset` attribute, which transition uses
        if let fcpElementType,
           fcpElementType == .transition,
           let localOffset = _fcpOffsetAsTimecode(frameRateSource: .localToElement, default: nil)
        {
            return localOffset
        }
        
        // cascade to inner resource timelines which may be necessary for clips like `ref-clip`
        return fcpResource()?
            ._fcpFirstChildTimelineElement()?
            .fcpAsAnyTimeline?
            .timelineStartAsTimecode()
    }
    
    /// Returns the timeline's local duration as timecode.
    /// Should only be used on elements that are timelines.
    func _fcpTimelineDurationAsTimecode() -> Timecode? {
        if let localTC = _fcpDurationAsTimecode(frameRateSource: .localToElement) {
            return localTC
        }
        
        // cascade to inner timelines which may be necessary for clips like `ref-clip`
        return fcpResource()?
            ._fcpFirstChildTimelineElement()?
            .fcpAsAnyTimeline?
            .timelineDurationAsTimecode()
    }
}

#endif
