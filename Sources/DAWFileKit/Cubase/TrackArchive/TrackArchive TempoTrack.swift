//
//  TrackArchive TempoTrack.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension Cubase.TrackArchive {
    
    /// Represents a cycle marker event and its contents
    public struct TempoTrack: CubaseTrackArchiveTrack {
        
        public var name: String?
        public var events: [Event] = []
        
    }
    
}

extension Cubase.TrackArchive.TempoTrack {
    
    public struct Event {
        
        public var startTimeAsPPQ: Cubase.PPQ
        public var tempo: Cubase.Tempo
        public var type: TempoEventType
        
    }
    
}

extension Cubase.TrackArchive.TempoTrack.Event {
    
    public enum TempoEventType {
        
        case jump
        case ramp
        
    }
    
}

#endif
