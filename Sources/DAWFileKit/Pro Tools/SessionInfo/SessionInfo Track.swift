//
//  SessionInfo Track.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//

import TimecodeKit

extension ProTools.SessionInfo {
    
    /// Represents a track and its contents.
    public struct Track {
        
        public var name: String = ""
        public var comments: String = ""
        
        public var userDelay: Int = 0
        
        public var state: Set<State> = []
        
        public var plugins: [String] = []
        
        public var clips: [Clip] = []
        
    }
    
}

extension ProTools.SessionInfo.Track {
    
    /// A track's state.
    public enum State: String {
        
        case inactive    = "Inactive"
        case hidden      = "Hidden"
        case muted       = "Muted"
        case solo        = "Solo"
        case soloSafe    = "SoloSafe"
        
    }
    
}

extension ProTools.SessionInfo.Track {
    
    /// Represents a clip contained on a track.
    public struct Clip {
        
        public var channel: Int = 0
        public var event: Int = 0
        public var name: String = ""
        public var startTimecode: Timecode?
        public var endTimecode: Timecode?
        public var duration: Timecode?
        public var state: State = .unmuted
        
        /// A clip's state (such as 'Muted', 'Unmuted')
        public enum State: String {
            
            // ***** there may be more states possible than this -- need to test
            case muted        = "Muted"
            case unmuted    = "Unmuted"
            
        }
        
    }
    
}
