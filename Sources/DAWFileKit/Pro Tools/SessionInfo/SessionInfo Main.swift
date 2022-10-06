//
//  SessionInfo Main.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation
import TimecodeKit

extension ProTools.SessionInfo {
    /// Contains the global session meta data
    /// (from the Session Info Text file header)
    public struct Main: Equatable, Hashable {
        public var name: String?
        
        public var sampleRate: Double?
        public var bitDepth: String?
        
        public var startTimecode: Timecode?
        public var frameRate: Timecode.FrameRate?
        
        public var audioTrackCount: Int?
        public var audioClipCount: Int?
        public var audioFileCount: Int?
    }
}
