//
//  FCPXML ElementContext Items.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

// MARK: - Built-In Context

extension FinalCutPro.FCPXML.ElementContext {
    /// The absolute start timecode of the element in seconds.
    public static var absoluteStart: FinalCutPro.FCPXML.ElementContext<TimeInterval?> {
        FinalCutPro.FCPXML.ElementContext { _, _, _, tools in
            tools.absoluteStart
        }
    }
    
    /// The absolute start timecode of the element expressed as timecode.
    public static func absoluteStartAsTimecode(
        frameRateSource: FinalCutPro.FCPXML.FrameRateSource = .mainTimeline
    ) -> FinalCutPro.FCPXML.ElementContext<Timecode?> {
        FinalCutPro.FCPXML.ElementContext { _, _, _, tools in
            tools.absoluteStartAsTimecode(frameRateSource: frameRateSource)
        }
    }
    
    /// The absolute end timecode of the element in seconds.
    public static var absoluteEnd: FinalCutPro.FCPXML.ElementContext<TimeInterval?> {
        FinalCutPro.FCPXML.ElementContext { _, _, _, tools in
            tools.absoluteEnd
        }
    }
    
    /// The absolute end timecode of the element expressed as timecode.
    public static func absoluteEndAsTimecode(
        frameRateSource: FinalCutPro.FCPXML.FrameRateSource = .mainTimeline
    ) -> FinalCutPro.FCPXML.ElementContext<Timecode?> {
        FinalCutPro.FCPXML.ElementContext { _, _, _, tools in
            tools.absoluteEndAsTimecode(frameRateSource: frameRateSource)
        }
    }
    
    /// The element's local roles, if applicable or present.
    /// These roles are either attached to the element itself or in some cases are acquired from
    /// the element's contents.
    /// Includes default roles if none are specified and if applicable.
    public static var localRoles: FinalCutPro.FCPXML.ElementContext<[FinalCutPro.FCPXML.AnyRole]> {
        FinalCutPro.FCPXML.ElementContext { _, _, _, tools in
            tools.localRoles(includeDefaultRoles: true)
        }
    }
    
    /// Returns the effective roles of the element inherited from ancestors.
    /// Includes default roles if none are specified and if applicable.
    public static var inheritedRoles: FinalCutPro.FCPXML.ElementContext<[FinalCutPro.FCPXML.AnyInterpolatedRole]> {
        FinalCutPro.FCPXML.ElementContext { _, _, _, tools in
            tools.inheritedRoles
        }
    }
    
    /// Returns the occlusion information for the element in relation to its parent.
    public static var occlusion: FinalCutPro.FCPXML.ElementContext<FinalCutPro.FCPXML.ElementOcclusion> {
        FinalCutPro.FCPXML.ElementContext { _, _, _, tools in
            tools.occlusion
        }
    }
    
    /// Returns the effective occlusion information for the element in relation to the main
    /// timeline.
    public static var effectiveOcclusion: FinalCutPro.FCPXML.ElementContext<FinalCutPro.FCPXML.ElementOcclusion> {
        FinalCutPro.FCPXML.ElementContext { _, _, _, tools in
            tools.effectiveOcclusion
        }
    }
    
    /// Contains an event name if the element is a descendent of an event.
    public static var ancestorEventName: FinalCutPro.FCPXML.ElementContext<String?> {
        FinalCutPro.FCPXML.ElementContext { _, _, _, tools in
            tools.ancestorEventName
        }
    }
    
    /// Contains a project name if the element is a descendent of a project.
    public static var ancestorProjectName: FinalCutPro.FCPXML.ElementContext<String?> {
        FinalCutPro.FCPXML.ElementContext { _, _, _, tools in
            tools.ancestorProjectName
        }
    }
    
    /// The parent clip's type.
    public static var parentType: FinalCutPro.FCPXML.ElementContext<FinalCutPro.FCPXML.ElementType?> {
        FinalCutPro.FCPXML.ElementContext { _, _, _, tools in
            tools.parentType
        }
    }
    
    /// The parent clip's name.
    public static var parentName: FinalCutPro.FCPXML.ElementContext<String?> {
        FinalCutPro.FCPXML.ElementContext { _, _, _, tools in
            tools.parentName
        }
    }
    
    /// The parent clip's absolute start time in seconds.
    public static var parentAbsoluteStart: FinalCutPro.FCPXML.ElementContext<TimeInterval?> {
        FinalCutPro.FCPXML.ElementContext { _, _, _, tools in
            tools.parentAbsoluteStart
        }
    }
    
    /// The parent element's absolute start time expressed as timecode.
    public static func parentAbsoluteStartAsTimecode(
        frameRateSource: FinalCutPro.FCPXML.FrameRateSource = .mainTimeline
    ) -> FinalCutPro.FCPXML.ElementContext<Timecode?> {
        FinalCutPro.FCPXML.ElementContext { _, _, _, tools in
            tools.parentAbsoluteStartAsTimecode(frameRateSource: frameRateSource)
        }
    }
    
    /// The parent clip's absolute end time in seconds.
    public static var parentAbsoluteEnd: FinalCutPro.FCPXML.ElementContext<TimeInterval?> {
        FinalCutPro.FCPXML.ElementContext { _, _, _, tools in
            tools.parentAbsoluteEnd
        }
    }
    
    /// The parent element's absolute end time expressed as timecode.
    public static func parentAbsoluteEndAsTimecode(
        frameRateSource: FinalCutPro.FCPXML.FrameRateSource = .mainTimeline
    ) -> FinalCutPro.FCPXML.ElementContext<Timecode?> {
        FinalCutPro.FCPXML.ElementContext { _, _, _, tools in
            tools.parentAbsoluteEndAsTimecode(frameRateSource: frameRateSource)
        }
    }
    
    /// The parent clip's duration in seconds.
    public static var parentDuration: FinalCutPro.FCPXML.ElementContext<TimeInterval?> {
        FinalCutPro.FCPXML.ElementContext { _, _, _, tools in
            tools.parentDuration
        }
    }
    
    /// The parent element's duration expressed as timecode.
    public static func parentDurationAsTimecode(
        frameRateSource: FinalCutPro.FCPXML.FrameRateSource = .mainTimeline
    ) -> FinalCutPro.FCPXML.ElementContext<Timecode?> {
        FinalCutPro.FCPXML.ElementContext { _, _, _, tools in
            tools.parentDurationAsTimecode(frameRateSource: frameRateSource)
        }
    }
}

#endif
