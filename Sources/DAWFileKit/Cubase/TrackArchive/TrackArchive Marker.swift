//
//  TrackArchive Marker.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension Cubase.TrackArchive {
    
    /// Represents a marker event and its contents.
    public struct Marker: CubaseTrackArchiveMarker {
        
        public var name: String = ""
        
        public var startTimecode: Timecode
        public var startRealTime: TimeInterval?
        
        public init(name: String,
                    startTimecode: Timecode,
                    startRealTime: TimeInterval? = nil)
        {
            
            self.name = name
            
            self.startTimecode = startTimecode
            self.startRealTime = startRealTime
            
        }
        
    }
    
}

#endif
