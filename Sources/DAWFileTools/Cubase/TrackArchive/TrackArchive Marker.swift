//
//  TrackArchive Marker.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import SwiftTimecodeCore

extension Cubase.TrackArchive {
    /// Represents a marker event and its contents.
    public struct Marker: CubaseTrackArchiveMarker {
        public var name: String = ""
        
        public var startTimecode: Timecode
        public var startRealTime: TimeInterval?
        
        public init(
            name: String,
            startTimecode: Timecode,
            startRealTime: TimeInterval? = nil
        ) {
            self.name = name
            
            self.startTimecode = startTimecode
            self.startRealTime = startRealTime
        }
    }
}

extension Cubase.TrackArchive.Marker: Equatable { }

extension Cubase.TrackArchive.Marker: Hashable { }

extension Cubase.TrackArchive.Marker: Sendable { }

#endif
