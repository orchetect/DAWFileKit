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
        public let format: String
        public let startTimecode: Timecode
        public let duration: Timecode
        public let audioLayout: AudioLayout
        public let audioRate: AudioRate
        public let clips: [Clip]
    }
}

extension FinalCutPro.FCPXML.Sequence {
    /// Sequence XML Attributes.
    public enum Attributes: String {
        case format // resource ID
        case duration
        case tcStart
        case tcFormat
        case audioLayout
        case audioRate
    }
}

extension FinalCutPro.FCPXML.Sequence {
    internal init(
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.Resource]
    ) {
        // "format"
        format = xmlLeaf.attributeStringValue(forName: Attributes.format.rawValue) ?? ""
        
        // "tcFormat"
        let tcFormatString = xmlLeaf.attributeStringValue(forName: Attributes.tcFormat.rawValue) ?? ""
        let tcFormat: FinalCutPro.FCPXML.TimecodeFormat = {
            if let tcf = FinalCutPro.FCPXML.TimecodeFormat(rawValue: tcFormatString) {
                return tcf
            } else {
                print("Error: tcFormat could not be decoded. Defaulting to non-drop (NDF).")
                return .nonDropFrame
            }
        }()
        
        // "tcStart"
        if let startString = xmlLeaf.attributeStringValue(forName: Attributes.tcStart.rawValue),
           let tc = try? FinalCutPro.FCPXML.timecode(
            fromString: startString,
            tcFormat: tcFormat,
            resourceID: format,
            resources: resources
           )
        {
            startTimecode = tc
        } else {
            print("Error: tcStart could not be decoded. Defaulting to 00:00:00:00 @ 30fps.")
            startTimecode = FinalCutPro.formTimecode(at: ._30)
        }
        
        // "duration"
        if let durString = xmlLeaf.attributeStringValue(forName: Attributes.duration.rawValue),
           let tc = try? FinalCutPro.FCPXML.timecode(
            fromString: durString,
            tcFormat: tcFormat,
            resourceID: format,
            resources: resources
           )
        {
            duration = tc
        } else {
            print("Error: duration could not be decoded. Defaulting to 00:00:00:00 @ 30fps.")
            duration = FinalCutPro.formTimecode(at: ._30)
        }
        
        // "audioLayout"
        let al = FinalCutPro.FCPXML.AudioLayout(
            rawValue: xmlLeaf.attributeStringValue(forName: Attributes.audioLayout.rawValue) ?? ""
        )
        if let al = al {
            audioLayout = al
        } else {
            print("Error: audioLayout missing or unrecognized. Defaulting to stereo.")
            audioLayout =  .stereo
        }
        
        // "audioRate"
        
        if let ar = FinalCutPro.FCPXML.AudioRate(
            rawValue: xmlLeaf.attributeStringValue(forName: Attributes.audioRate.rawValue) ?? ""
        ) {
            audioRate = ar
        } else {
            print("Error: audioLayout missing or unrecognized. Defaulting to 48kHz.")
            audioRate =  .rate48kHz
        }
        
        // clips
        
        let frameRate = Self.fRate(
            forResourceID: format,
            tcFormat: tcFormat,
            in: resources
        )
        
        // TODO: not sure if it's ever possible to have more than one spine?
        let spines = Self.spines(in: xmlLeaf)
        
        clips = spines.reduce(into: [Clip]()) { clips, spineLeaf in
            let spineClips = Self.parseClips(
                from: spineLeaf,
                sequenceFrameRate: frameRate
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
            return ._30
        }
    }
}

#endif
