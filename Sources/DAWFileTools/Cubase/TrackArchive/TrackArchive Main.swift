//
//  TrackArchive Main.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import SwiftTimecodeCore

extension Cubase.TrackArchive {
    /// Contains the global session meta-data.
    public struct Main {
        public var startTimecode: Timecode?        // 'Start'.'Time' (float, load as double)
        public var startTimeSeconds: TimeInterval? // 'Start'.'Time' (float, load as double)
        
        // public var startTimeDomain: ?           // 'Start'.'Domain'.'Type' &
                                                   // 'Start'.'Domain'.'Period'
        public var lengthTimecode: Timecode?       // 'Length'.'Time' (float, load as double)
        // public var lengthTimeDomain: ?          // 'Length'.'Domain'.'Type' &
                                                   // 'Start'.'Domain'.'Period'
        
        public var frameRate: TimecodeFrameRate?   // 'FrameType'
        
        // public var timeType: ?                  // 'TimeType'
        public var barOffset: Int?                 // 'BarOffset'
        
        public var sampleRate: Double?             // 'SampleRate'
        public var bitDepth: Int?                  // 'SampleSize'
        
        // SampleFormatSize
        
        // 'RecordFile'
        // 'RecordFileType' ...
        
        // 'PanLaw'
        // 'VolumeMax'
        
        // 'HmtType'
        public var hmtDepth: Int?                  // 'HmtDepth' (percentage)
        
        // NOTE: Intentionally no public initializer.
        internal init() { }
    }
}

extension Cubase.TrackArchive.Main: Equatable { }

extension Cubase.TrackArchive.Main: Hashable { }

extension Cubase.TrackArchive.Main: Sendable { }

#endif
