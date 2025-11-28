//
//  TrackArchive CycleMarker.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import SwiftTimecodeCore

extension Cubase.TrackArchive {
    /// Represents a cycle marker event and its contents.
    public struct CycleMarker: CubaseTrackArchiveMarker {
        public var name: String = ""
        
        public var startTimecode: Timecode
        public var startRealTime: TimeInterval?
        
        public var lengthTimecode: Timecode
        public var lengthRealTime: TimeInterval?
        
        public init(
            name: String,
            startTimecode: Timecode,
            startRealTime: TimeInterval? = nil,
            lengthTimecode: Timecode,
            lengthRealTime: TimeInterval? = nil
        ) {
            self.name = name
            
            self.startTimecode = startTimecode
            self.startRealTime = startRealTime
            
            self.lengthTimecode = lengthTimecode
            self.lengthRealTime = lengthRealTime
        }
    }
}

extension Cubase.TrackArchive.CycleMarker: Equatable { }

extension Cubase.TrackArchive.CycleMarker: Hashable { }

extension Cubase.TrackArchive.CycleMarker: Sendable { }

#endif
