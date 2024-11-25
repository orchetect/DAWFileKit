//
//  TrackArchive.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

// MARK: - Cubase.TrackArchive

extension Cubase {
    /// Contains parsed data after reading a Cubase Track Archive XML file.
    public struct TrackArchive {
        // MARK: Contents
        
        /// Meta data contained in the main header of the data file.
        public var main = Main()
        
        /// Tempo track.
        /// (Essentially, a session can contain only one tempo track, but there is not a "tempo
        /// track" in the XML file; instead, tempo events are written to the first actual track.)
        public var tempoTrack = TempoTrack()
        
        /// Tracks listing.
        public var tracks: [CubaseTrackArchiveTrack]?
        
        // MARK: - Default init
        
        public init() { }
    }
}

// MARK: - Constants

extension Cubase.TrackArchive {
    /// Static PPQ value used in Track Archive XML files (allegedly, until proven otherwise?)
    /// Changing PPQbase in Cubase preferences has no effect on this value.
    internal static let xmlPPQ = 480
    
    /// Array of file types for use with `NSOpenPanel` / `NSSavePanel`.
    public static let fileTypes = ["public.xml", "xml"]
    
    /// Frame rates and their numeric identifier as stored in the XML.
    internal static let frameRateTable: [Int: TimecodeFrameRate] =
        [
            02: .fps24,
            03: .fps25,
            04: .fps29_97,
            05: .fps30,
            06: .fps29_97d,
            07: .fps30d,
            12: .fps23_976,
            13: .fps24_98,
            14: .fps50,
            15: .fps59_94,
            16: .fps60
        ]
    
    internal static let trackTypeTable: [String: CubaseTrackArchiveTrack.Type] = [
        "MMarkerTrackEvent": MarkerTrack.self
        // TODO: add additional track types in future
    ]
}

#endif
