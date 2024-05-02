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
        breadcrumbs: [XMLElement]? = nil,
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
                
                // if start and duration attributes are missing, assume the keyword
                // applies to the entire clip
                if keyword.element.fcpStart == nil,
                    keyword.element.fcpDuration == nil
                {
                    applicableKeywords.append(keyword)
                }
            }
        }
        
        return applicableKeywords
    }
    
    /// FCPXML: Returns metadata applicable to the element.
    func _fcpApplicableMetadata(
        breadcrumbs: [XMLElement]? = nil,
        resources: XMLElement? = nil
    ) -> [FinalCutPro.FCPXML.Metadata.Metadatum] {
        // find nearest timeline and determine its absolute start timecode
        guard let (timeline, _ /* timelineAncestors */) = fcpAncestorTimeline(
            ancestors: breadcrumbs,
            includingSelf: true
        )
        else { return [] }
        
        func flatten(metadataIn e: XMLElement?) -> [FinalCutPro.FCPXML.Metadata.Metadatum] {
            e?.children(whereFCPElement: .metadata)
                .flatMap(\.metadatumContents)
            ?? []
        }
        
        // special case: multicam/mc-clip
        //
        // - markers:
        //     - can exist as children in `mc-clip`
        // - markers and/or metadata:
        //     - can also exist as children in `multicam` -> `mc-angle` -> <first non-gap clip>
        // - metadata never seems to exist within the `mc-clip` itself however
        //
        // which means:
        // - if ancestor clip (or if self is a clip):
        //   - is a `mc-clip`
        //     - grab metadata from the clip within the multicam angle it points to
        //     - also grab metadata from the resource the clip references
        //   - is an `asset-clip`, regardless of whether it's in a main timeline or it's within a multicam resource's angle
        //     - parse using default behavior for other clip types:
        //       - grab local clip metadata
        //       - grab the clip's resource's metadata
        if let mcClip = timeline.fcpAsMCClip {
            // let multicam = mcClip.multicamResource
            
            // 1. grab metadata from the clip within the multicam angle it points to
            let (_ /* audioMCAngle */, videoMCAngle) = mcClip.audioVideoMCAngles
            let angleTimeline = videoMCAngle?.element._fcpFirstChildTimelineElement(excluding: [.gap])
            let angleMetadataFlat = flatten(metadataIn: angleTimeline)
            
            // 2. also grab metadata from the resource the clip references
            let angleResource = angleTimeline?.fcpResource()
            let angleResourceMetadataFlat = flatten(metadataIn: angleResource)
            
            let combinedMetadataFlat = Array(angleResourceMetadataFlat) + Array(angleMetadataFlat)
            
            return combinedMetadataFlat
        }
        
        // get clip metadata
        let timelineMetadata = timeline.children(whereFCPElement: .metadata)
        let timelineMetadataFlat = timelineMetadata.flatMap(\.metadatumContents)
        
        // get media metadata
        let resource = self.fcpResource()
        let resourceMetadata = resource?.children(whereFCPElement: .metadata)
        let resourceMetadataFlat: [FinalCutPro.FCPXML.Metadata.Metadatum] = {
            if let resourceMetadata {
                return resourceMetadata.flatMap(\.metadatumContents)
            } else {
                return []
            }
        }()
        
        let combinedMetadataFlat = Array(resourceMetadataFlat) + Array(timelineMetadataFlat)
        
        return combinedMetadataFlat
    }
}

#endif
