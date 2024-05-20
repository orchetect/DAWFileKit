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
        // check for local `tcstart` or `start` attribute
        if let localTC = _fcpTCStartAsTimecode(frameRateSource: .localToElement)
            ?? _fcpStartAsTimecode(frameRateSource: .localToElement)
        {
            return localTC
        }
        
        // check for parent project if local timeline is a sequence or spine
        if let fcpElementType,
           fcpElementType == .sequence || fcpElementType == .spine,
           let project = self.ancestorElements(includingSelf: false)
               .first(whereFCPElement: .project),
           let projectStart = project.startTimecode()
        {
            return projectStart
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
