//
//  FCPXML FrameDataPreset.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2024 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    /// FCPXML extraction preset that extracts markers,.
    public struct FrameDataPreset: FCPXMLExtractionPreset {
        public init() { }
        
        public func perform(
            on extractable: XMLElement,
            scope: FinalCutPro.FCPXML.ExtractionScope
        ) async -> FinalCutPro.FCPXML.ExtractedFrameData {
            let extracted = await extractable.fcpExtract(
                types: .allClipCases,
                scope: scope
            )
            
            let clips: [ExtractedClip] = extracted.compactMap {
                guard let start = $0.value(forContext: .absoluteStartAsTimecode()),
                      let end = $0.value(forContext: .absoluteEndAsTimecode())
                else { return nil }
                
                return (
                    start: start,
                    end: end,
                    clip: $0
                )
            }
            
            let frameRate = extractable._fcpTimecodeFrameRate() ?? .fps24
            let timelineStart = extractable._fcpTimelineStartAsTimecode()
                ?? Timecode(.zero, at: frameRate)
            
            return FinalCutPro.FCPXML.ExtractedFrameData(
                timelineStart: timelineStart,
                clips: clips
            )
        }
        
        public typealias ExtractedClip = (start: Timecode,
                                          end: Timecode,
                                          clip: FinalCutPro.FCPXML.ExtractedElement)
    }
}

extension FCPXMLExtractionPreset where Self == FinalCutPro.FCPXML.FrameDataPreset {
    /// FCPXML extraction preset that extracts data for each frame.
    public static var frameData: FinalCutPro.FCPXML.FrameDataPreset {
        FinalCutPro.FCPXML.FrameDataPreset()
    }
}

extension FinalCutPro.FCPXML {
    // TODO: XMLElement is not Sendable
    
    /// An extracted frame with associated data.
    public struct ExtractedFrameData: @unchecked Sendable {
        public let timelineStart: Timecode
        public let clips: [FrameDataPreset.ExtractedClip]
        
        init(
            timelineStart: Timecode,
            clips: [FrameDataPreset.ExtractedClip]
        ) {
            self.timelineStart = timelineStart
            self.clips = clips
        }
        
        /// Returns the clip that contains the given timecode.
        public func clip(for timecode: Timecode) -> FinalCutPro.FCPXML.ExtractedElement? {
            clips
                .first {
                    timecode >= $0.start &&
                    timecode < $0.end
                }?
                .clip
        }
        
        // convenience
        
        public struct FrameData {
            public let timecode: Timecode
            public let localTimecode: Timecode
            public let clipName: String
            public let keywords: [String]
            public let markers: [FinalCutPro.FCPXML.ExtractedMarker]
            public let metadata: [FinalCutPro.FCPXML.Metadata.Metadatum]
        }
        
        public func data(for timecode: Timecode) async -> FrameData? {
            guard let clip = clip(for: timecode) else { return nil }
            
            let timecodeRoundedDown = timecode.roundedDown(toNearest: .frames)
            guard let timecodeNextFrame = try? timecodeRoundedDown.adding(.frames(1)) else { return nil }
            let frameRange = timecodeRoundedDown ..< timecodeNextFrame
            
            let localTimecode: Timecode
            if let clipStart = clip.value(forContext: .absoluteStartAsTimecode(frameRateSource: .mainTimeline)),
               let clipLocalStart = clip.value(forContext: .absoluteStartAsTimecode(frameRateSource: .localToElement)) 
            {
                let offsetIntoClip = timecode - clipStart
                localTimecode = clipLocalStart + offsetIntoClip
            } else {
                // failsafe
                localTimecode = Timecode(.zero, using: timecode.properties)
            }
            
            let clipName = clip.element.fcpName ?? ""
            
            let keywords: [FinalCutPro.FCPXML.Keyword] = clip.value(forContext: .keywords())
                .filter {
                    guard let kwRange = $0.absoluteRangeAsTimecode(
                        timeline: clip.element,
                        timelineAncestors: clip.breadcrumbs.asAnySequence,
                        resources: clip.resources
                    )
                    else { return true }
                    
                    return kwRange.contains(timecode)
                }
            let keywordsFlat = keywords.flattenedKeywords()
            
            let markers = await clip.element
                .fcpExtract(preset: .markers, scope: .mainTimeline)
                .filter {
                    // keep markers that match the current frame's timecode
                    guard let markerTimecode = $0.value(forContext: .absoluteStartAsTimecode())
                    else { return false }
                    
                    return frameRange.contains(markerTimecode)
                }
            
            let md = clip.value(forContext: .metadata)
            
            return FrameData(
                timecode: timecode,
                localTimecode: localTimecode,
                clipName: clipName,
                keywords: keywordsFlat,
                markers: markers,
                metadata: md
            )
        }
    }
}

#endif
