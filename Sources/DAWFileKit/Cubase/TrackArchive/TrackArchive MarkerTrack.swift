//
//  TrackArchive MarkerTrack.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension Cubase.TrackArchive {
    
    /// Represents a track and its contents.
    public struct MarkerTrack: CubaseTrackArchiveTrack {
        
        public var name: String?
        
        public var events: [CubaseTrackArchiveMarker] = []
        
        public init() { }
        
    }
    
}

#endif
