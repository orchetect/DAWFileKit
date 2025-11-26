//
//  TrackArchive.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

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
        public var tracks: [AnyTrack]? // TODO: refactor as non-Optional
        
        // MARK: - Default init
        
        public init() { }
    }
}

extension Cubase.TrackArchive: Equatable { }

extension Cubase.TrackArchive: Hashable { }

extension Cubase.TrackArchive: Sendable { }

#endif
