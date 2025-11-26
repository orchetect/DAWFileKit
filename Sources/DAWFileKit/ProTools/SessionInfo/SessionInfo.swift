//
//  SessionInfo.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation
import TimecodeKitCore

// MARK: - ProTools.SessionInfo

extension ProTools {
    /// Contains parsed data after reading a Pro Tools Session Info text file.
    public struct SessionInfo: Equatable, Hashable {
        /// Meta data contained in the main header of the data file.
        public internal(set) var main = Main()
        
        /// Files listing (online).
        public internal(set) var onlineFiles: [File]?
        
        /// Files listing (offline).
        public internal(set) var offlineFiles: [File]?
        
        /// Clips listing (online).
        public internal(set) var onlineClips: [Clip]?
        
        /// Clips listing (offline).
        public internal(set) var offlineClips: [Clip]?
        
        /// Plugin listing.
        public internal(set) var plugins: [Plugin]?
        
        /// Tracks listing.
        public internal(set) var tracks: [Track]?
        
        /// Markers listing.
        public internal(set) var markers: [Marker]?
        
        /// Holds any extraneous sections or data that was not recognized while parsing the file.
        public internal(set) var orphanData: [OrphanData]?
    }
}

extension ProTools.SessionInfo: Sendable { }

// MARK: - Constants

extension ProTools.SessionInfo {
    /// Array of file types for use with NSOpenPanel / NSSavePanel
    public static let fileTypes = ["public.txt", "txt"]
}
