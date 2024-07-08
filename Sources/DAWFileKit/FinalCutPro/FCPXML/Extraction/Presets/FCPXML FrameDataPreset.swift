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
                types: .allTimelineCases,
                scope: scope
            )
            
            let clips: [ExtractedClip] = extracted.compactMap {
                guard let start = $0.value(forContext: .absoluteStartAsTimecode()),
                      let dur = $0.value(forContext: .parentDurationAsTimecode())
                else { return nil }
                
                return (
                    start: start,
                    duration: dur,
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
                                          duration: Timecode,
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
                    $0.start >= timecode &&
                    ($0.start + $0.duration) < timecode
                }?
                .clip
        }
    }
}

#endif
