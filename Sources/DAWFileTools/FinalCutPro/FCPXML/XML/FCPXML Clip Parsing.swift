//
//  FCPXML Clip Parsing.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2024 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKitCore
import SwiftExtensions

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
        
        var applicableKeywords: [FinalCutPro.FCPXML.Keyword] = []
        for keyword in keywords {
            if let kwAbsRange = keyword.absoluteRangeAsTimecode(
                timeline: timeline,
                timelineAncestors: timelineAncestors,
                resources: resources
            ) {
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
        
        // special case: `mc-clip`
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
        //     1. get `mc-clip` local metadata
        //     2. get metadata from the clip within the multicam angle it points to
        //     3. also get metadata from the resource the clip references
        //   - is an `asset-clip`, regardless of whether it's in a main timeline or it's within a multicam resource's angle
        //     - parse using default behavior for other clip types (fall through):
        //       1. get local clip metadata
        //       2. get the clip's resource's metadata
        if let mcClip = timeline.fcpAsMCClip {
            // let multicam = mcClip.multicamResource
            
            // 1. get `mc-clip` local metadata
            let mcClipMetadataFlat = flatten(metadataIn: mcClip.element)
            
            // 2. get metadata from the clip within the multicam angle it points to
            let (_ /* audioMCAngle */, videoMCAngle) = mcClip.audioVideoMCAngles
            let angleTimeline = videoMCAngle?.element._fcpFirstChildTimelineElement(excluding: [.gap])
            let angleMetadataFlat = flatten(metadataIn: angleTimeline)
            
            // 3. also get metadata from the resource the clip references
            let angleResource = angleTimeline?.fcpResource()
            let angleResourceMetadataFlat = flatten(metadataIn: angleResource)
            
            // combine
            let combinedMetadataFlat = Array(angleResourceMetadataFlat) + Array(angleMetadataFlat) + Array(mcClipMetadataFlat)
            return combinedMetadataFlat
        }
        
        // special case: `sync-clip`
        //
        // - `sync-clip` can contain local metadata
        // - metadata needs to be also pulled from the first internal video timeline from the `sync-clip`'s resource
        if let syncClip = timeline.fcpAsSyncClip {
            // get local clip metadata
            let timelineMetadataFlat = flatten(metadataIn: syncClip.element)
            
            // get media metadata
            let firstInteriorClip = syncClip.element._fcpFirstChildTimelineElement()
            let resource = firstInteriorClip?.fcpResource()
            let resourceMetadataFlat = flatten(metadataIn: resource)
            
            // combine
            let combinedMetadataFlat = Array(resourceMetadataFlat) + Array(timelineMetadataFlat)
            return combinedMetadataFlat
        }
        
        // special case: `ref-clip`
        //
        // - `ref-clip` itself may contain metadata
        // - the `media` resource it references can contain a `metadata` child within its `sequence`
        if let refClip = timeline.fcpAsRefClip {
            // get clip metadata
            let refClipMetadataFlat = flatten(metadataIn: refClip.element)
            
            // get `media` metadata
            let sequence = refClip.mediaSequence
            let sequenceMetadataFlat = flatten(metadataIn: sequence?.element)
            
            // combine
            let combinedMetadataFlat = Array(sequenceMetadataFlat) + Array(refClipMetadataFlat)
            return combinedMetadataFlat
        }
        
        // fall through to default behavior for other clip types:
        
        // get clip metadata
        let timelineMetadataFlat = flatten(metadataIn: timeline)
        
        // get media metadata
        let resource = self.fcpResource()
        let resourceMetadataFlat = flatten(metadataIn: resource)
        
        // combine
        let combinedMetadataFlat = Array(resourceMetadataFlat) + Array(timelineMetadataFlat)
        return combinedMetadataFlat
    }
}

#endif
