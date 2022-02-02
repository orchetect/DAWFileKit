//
//  TrackArchive.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
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
        /// (Essentially, a session can contain only one tempo track, but there is not a "tempo track" in the XML file; instead, tempo events are written to the first actual track.)
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
    public static let fileTypes = ["public.xml" ,"xml"]
    
    /// Frame rates and their numeric identifier as stored in the XML.
    internal static var frameRateTable: [Int : Timecode.FrameRate] =
    [
        02 : ._24,
        03 : ._25,
        04 : ._29_97,
        05 : ._30,
        06 : ._29_97_drop,
        07 : ._30_drop,
        12 : ._23_976,
        13 : ._24_98,
        14 : ._50,
        15 : ._59_94,
        16 : ._60
    ]
    
    internal static var TrackTypeTable: [String : CubaseTrackArchiveTrack.Type] =
    [
        "MMarkerTrackEvent" : MarkerTrack.self
    ]
    
}

#endif
