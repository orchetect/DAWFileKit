//
//  SessionInfo Main.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation
import TimecodeKitCore

extension ProTools.SessionInfo {
    /// Contains the global session meta data
    /// (from the Session Info Text file header)
    public struct Main: Equatable, Hashable {
        public internal(set) var name: String?
        
        public internal(set) var sampleRate: Double?
        public internal(set) var bitDepth: String?
        
        public internal(set) var startTimecode: Timecode?
        public internal(set) var frameRate: TimecodeFrameRate?
        
        public internal(set) var audioTrackCount: Int?
        public internal(set) var audioClipCount: Int?
        public internal(set) var audioFileCount: Int?
    }
}

extension ProTools.SessionInfo.Main: Sendable { }
