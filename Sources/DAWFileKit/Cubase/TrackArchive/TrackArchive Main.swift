//
//  TrackArchive Main.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension Cubase.TrackArchive {
    /// Contains the global session meta-data.
    public struct Main {
        public var startTimecode: Timecode?        // 'Start'.'Time' (float, load as double)
        public var startTimeSeconds: Double?       // 'Start'.'Time' (float, load as double)
        
        // public var startTimeDomain: ?            // 'Start'.'Domain'.'Type' & 'Start'.'Domain'.'Period'
        public var lengthTimecode: Timecode?       // 'Length'.'Time' (float, load as double)
        // public var lengthTimeDomain: ?           // 'Length'.'Domain'.'Type' & 'Start'.'Domain'.'Period'
        
        public var frameRate: Timecode.FrameRate?  // 'FrameType'
        
        // public var timeType: ?                   // 'TimeType'
        public var barOffset: Int?                 // 'BarOffset'
        
        public var sampleRate: Double?             // 'SampleRate'
        public var bitDepth: Int?                  // 'SampleSize'
        
        // SampleFormatSize
        
        // 'RecordFile'
        // 'RecordFileType' ...
        
        // 'PanLaw'
        // 'VolumeMax'
        
        // 'HmtType'
        public var hmtDepth: Int?                   // 'HmtDepth' (percentage)
    }
}

#endif
