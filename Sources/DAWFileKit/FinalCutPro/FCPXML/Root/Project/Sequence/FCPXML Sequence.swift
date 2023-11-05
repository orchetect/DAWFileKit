//
//  FCPXML Sequence.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import CoreMedia
@_implementationOnly import OTCore

extension FinalCutPro.FCPXML {
    // <sequence format="r1" duration="1920919/30000s" tcStart="0s" tcFormat="NDF" audioLayout="stereo" audioRate="48k">
    public struct Sequence {
        // FCPXMLTimelineAttributes
        public let format: String
        public let start: Timecode
        
        // FCPXMLTimingAttributes
        public let duration: Timecode
        
        public let audioLayout: AudioLayout
        public let audioRate: AudioRate
        
        public let storyElements: [AnyStoryElement]
    }
}

extension FinalCutPro.FCPXML.Sequence: FCPXMLTimelineAttributes {
    internal init(
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.Resource]
    ) {
        // parses `format`, `tcStart`, `tcFormat`, `duration`
        let timelineAttributes = Self.parseTimelineAttributesDefaulted(
            from: xmlLeaf, resources: resources
        )
        
        // `format`
        format = timelineAttributes.format
        
        // `tcStart`
        
        start = timelineAttributes.start
        
        // `duration`
        duration = timelineAttributes.duration
        
        // `audioLayout`
        let al = FinalCutPro.FCPXML.AudioLayout(
            rawValue: xmlLeaf.attributeStringValue(forName: Attributes.audioLayout.rawValue) ?? ""
        )
        if let al = al {
            audioLayout = al
        } else {
            print("Error: audioLayout missing or unrecognized. Defaulting to stereo.")
            audioLayout = .stereo
        }
        
        // `audioRate`
        if let ar = FinalCutPro.FCPXML.AudioRate(
            rawValue: xmlLeaf.attributeStringValue(forName: Attributes.audioRate.rawValue) ?? ""
        ) {
            audioRate = ar
        } else {
            print("Error: audioLayout missing or unrecognized. Defaulting to 48kHz.")
            audioRate =  .rate48kHz
        }
        
        let frameRate = Self.fRate(
            forResourceID: format,
            tcFormat: timelineAttributes.timecodeFormat,
            in: resources
        )
        
        // TODO: not sure if it's ever possible to have more than one spine? keep them separate? is there always a spine in a timeline/sequence?
        let spines = Self.spines(in: xmlLeaf)
        
        storyElements = spines.reduce(into: [FinalCutPro.FCPXML.AnyStoryElement]()) { clips, spineLeaf in
            let spineClips = FinalCutPro.FCPXML.parseStoryElements(
                from: spineLeaf,
                frameRate: frameRate,
                resources: resources
            )
            clips.append(contentsOf: spineClips)
        }
    }
    
    static func spines(in xmlLeaf: XMLElement) -> [XMLElement] {
        xmlLeaf.children?.lazy
            .filter { $0.name == "spine" }
            .compactMap { $0 as? XMLElement } ?? []
    }
    
    // TODO: Stupid workaround. Swift compiler was complaining when this was within the body of the init.
    static func fRate(
        forResourceID id: String,
        tcFormat: FinalCutPro.FCPXML.TimecodeFormat?,
        in resources: [String: FinalCutPro.FCPXML.Resource]
    ) -> TimecodeFrameRate {
        if let fr = FinalCutPro.FCPXML.timecodeFrameRate(
            forResourceID: id,
            tcFormat: tcFormat,
            in: resources
        ) {
            return fr
        } else {
            print("Error: Could not determine frame rate. Defaulting to 30fps.")
            return .fps30
        }
    }
}

#endif
