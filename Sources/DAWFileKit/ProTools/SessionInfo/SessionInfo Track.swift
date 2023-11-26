//
//  SessionInfo Track.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation
import TimecodeKit

extension ProTools.SessionInfo {
    /// Represents a track and its contents.
    public struct Track: Equatable, Hashable {
        public internal(set) var name: String = ""
        public internal(set) var comments: String = ""
        public internal(set) var userDelay: Int = 0
        public internal(set) var state: Set<State> = []
        public internal(set) var plugins: [String] = []
        public internal(set) var clips: [Clip] = []
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
    public struct Clip: Equatable, Hashable {
        public internal(set) var channel: Int = 0
        public internal(set) var event: Int = 0
        public internal(set) var name: String = ""
        public internal(set) var startTime: ProTools.SessionInfo.TimeValue?
        public internal(set) var endTime: ProTools.SessionInfo.TimeValue?
        public internal(set) var duration: ProTools.SessionInfo.TimeValue?
        public internal(set) var state: State = .unmuted
        
        /// A clip's state (such as 'Muted', 'Unmuted')
        public enum State: String {
            // ***** there may be more states possible than this -- need to test
            case muted   = "Muted"
            case unmuted = "Unmuted"
        }
    }
}
