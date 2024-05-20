//
//  FCPXMLElementMetaTimeline.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2024 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import OTCore
import TimecodeKit

/// A meta protocol that all timeline and pseudo-timeline elements conform to.
public protocol FCPXMLElementMetaTimeline: FCPXMLElement { }

extension FCPXMLElementMetaTimeline {
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
        if let localTC = _fcpTCStartAsTimecode(frameRateSource: .localToElement)
            ?? _fcpStartAsTimecode(frameRateSource: .localToElement)
        {
            return localTC
        }
        
        // cascade to inner timelines which may be necessary for clips like `ref-clip`
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
