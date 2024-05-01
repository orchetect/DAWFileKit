//
//  FCPXML Clip Parsing.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2024 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import OTCore

extension XMLElement {
    /// FCPXML: Returns keywords applied to the element if the element is a clip,
    /// otherwise returns keywords applied to the first ancestor clip.
    func _fcpApplicableKeywords(
        constrainToKeywordRanges: Bool = true,
        breadcrumbs: [XMLElement],
        resources: XMLElement? = nil
    ) -> [FinalCutPro.FCPXML.Keyword] {
        // find nearest timeline and determine its absolute start timecode
        guard let (timeline, timelineAncestors) = fcpAncestorTimeline(
            ancestors: breadcrumbs,
            includingSelf: true
        )
        else { return [] }
        
        // get parent clip's keywords
        let keywords = timeline.children(whereFCPElement: .keyword)
        
        // if self is a timeline, just return all keywords
        if timeline == self { return Array(keywords) }
        
        // if we're not constraining to keyword ranges, just return all keywords
        if !constrainToKeywordRanges { return Array(keywords) }
        
        // otherwise, determine what keywords apply based on their ranges.
        // keywords can apply to a partial region of a clip, so check if element is in range.
        
        guard let absoluteStart = _fcpCalculateAbsoluteStart(
            ancestors: breadcrumbs,
            resources: resources
        ),
            let absoluteStartAsTimecode = try? _fcpTimecode(
                fromRealTime: absoluteStart,
                frameRateSource: .mainTimeline,
                breadcrumbs: breadcrumbs,
                resources: resources
            )
        else {
            // if marker timecode cannot be determined, just return all of the clip's keywords
            return Array(keywords)
        }
        
        // determine what keywords encompass the marker's position
        
        /// Returns the absolute timecode range the keyword applies to.
        func absRange(for keyword: FinalCutPro.FCPXML.Keyword) -> ClosedRange<Timecode>? {
            guard let kwAbsStart = keyword.element._fcpCalculateAbsoluteStart(
                ancestors: [timeline] + timelineAncestors,
                resources: resources
            ),
                  let kwAbsStartTimecode = try? keyword.element._fcpTimecode(
                    fromRealTime: kwAbsStart,
                    frameRateSource: .mainTimeline,
                    breadcrumbs: [timeline] + timelineAncestors,
                    resources: resources
                  ),
                  let kwDuration = keyword.durationAsTimecode()
            else { return nil }
            
            let lbound = kwAbsStartTimecode
            let ubound = lbound + kwDuration
            
            return lbound ... ubound
        }
        
        var applicableKeywords: [FinalCutPro.FCPXML.Keyword] = []
        for keyword in keywords {
            if let kwAbsRange = absRange(for: keyword) {
                if kwAbsRange.contains(absoluteStartAsTimecode) {
                    // marker is within keyword range
                    applicableKeywords.append(keyword)
                }
            } else {
                // keyword range cannot be determined
                // applicableKeywords.append(keyword)
            }
        }
        
        return applicableKeywords
    }
}

#endif
