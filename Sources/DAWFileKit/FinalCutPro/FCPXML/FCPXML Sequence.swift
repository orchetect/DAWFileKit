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
    
    public enum ClipTypes: String {
        case title
        
        // TODO: add additional clip types
    }
    
    /// Sequence Clip.
    public enum Clip {
        case title(Title)
        
        // TODO: add additional clip types
        
        // <title ref="r2" offset="0s" name="Basic Title" start="0s" duration="1920919/30000s">
        /// Title Clip.
        public struct Title {
            public let ref: String // resource ID
            public let offset: Timecode
            public let name: String
            public let start: Timecode
            public let duration: Timecode
            
            /// Title clip XML Attributes.
            public enum Attributes: String {
                case ref // resource ID
                case offset
                case name
                case start
                case duration
            }
        }
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
        let tcFormat = FinalCutPro.FCPXML.TimecodeFormat(rawValue: tcFormatString)
        if tcFormat == nil {
            print("Error: tcFormat could not be decoded.")
        }
        
        // "tcStart"
        if let startString = xmlLeaf.attributeStringValue(forName: Attributes.tcStart.rawValue),
           let tc = try? Self.timecode(
            fromString: startString,
            tcFormat: tcFormat,
            resourceID: format,
            resources: resources
           )
        {
            startTimecode = tc
        } else {
            print("Error: tcStart could not be decoded. Defaulting to 00:00:00:00 @ 30fps.")
            startTimecode = .init(at: ._30)
        }
        
        // "duration"
        if let durString = xmlLeaf.attributeStringValue(forName: Attributes.duration.rawValue),
           let tc = try? Self.timecode(
               fromString: durString,
               tcFormat: tcFormat,
               resourceID: format,
               resources: resources
           )
        {
            duration = tc
        } else {
            print("Error: duration could not be decoded. Defaulting to 00:00:00:00 @ 30fps.")
            duration = .init(at: ._30)
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
        let ar = FinalCutPro.FCPXML.AudioRate(
            rawValue: xmlLeaf.attributeStringValue(forName: Attributes.audioRate.rawValue) ?? ""
        )
        if let ar = ar {
            audioRate = ar
        } else {
            print("Error: audioLayout missing or unrecognized. Defaulting to 48kHz.")
            audioRate =  .rate48kHz
        }
        
        // clips
        
        clips = [] // TODO: replace this
        
        #warning("> finish parsing clips")
    }
    
    /// Utility:
    /// Convert raw "tcStart" or "duration" attribute string to Timecode.
    static func timecode(
        fromString rawString: String,
        tcFormat: FinalCutPro.FCPXML.TimecodeFormat?,
        resourceID: String,
        resources: [String: FinalCutPro.FCPXML.Resource]
    ) throws -> Timecode? {
        guard let parsedStr = FinalCutPro.FCPXML.parse(rationalTimeString: rawString),
              let videoRate = FinalCutPro.FCPXML.videoFrameRate(forResourceID: resourceID, in: resources),
              let fRate = videoRate.timecodeFrameRate(drop: tcFormat?.isDrop ?? false)
        else { return nil }
        
        switch parsedStr {
        case .rational(let fraction):
            return try FinalCutPro.formTimecode(rational: fraction, at: fRate)
            
        case .value(let value):
            // this could also work using Timecode(realTime:)
            return try FinalCutPro.formTimecode(rational: (value, 1), at: fRate)
        }
    }
}

#endif
