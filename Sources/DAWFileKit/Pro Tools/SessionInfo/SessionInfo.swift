//
//  SessionInfo.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//

import Foundation
import TimecodeKit

// MARK: - ProTools.SessionInfo

extension ProTools {
    
    /// Contains parsed data after reading a Pro Tools Session Info text file.
    public struct SessionInfo {
        
        /// Meta data contained in the main header of the data file.
        public var main = Main()
        
        /// Files listing (online).
        public var onlineFiles: [File]?
        
        /// Files listing (offline).
        public var offlineFiles: [File]?
        
        /// Clips listing (online).
        public var onlineClips: [Clip]?
        
        /// Clips listing (offline).
        public var offlineClips: [Clip]?
        
        /// Plugin listing.
        public var plugins: [Plugin]?
        
        /// Tracks listing.
        public var tracks: [Track]?
        
        /// Markers listing.
        public var markers: [Marker]?
        
        /// Holds any extraneous sections or data that was not recognized while parsing the file.
        public var orphanData: [(heading: String, content: [String])]?
        
        // MARK: - Default init
        
        public init() { }
        
    }
    
}

// MARK: - Constants

extension ProTools.SessionInfo {
    
    /// Array of file types for use with NSOpenPanel / NSSavePanel
    public static let fileTypes = ["public.txt", "txt"]
    
}
