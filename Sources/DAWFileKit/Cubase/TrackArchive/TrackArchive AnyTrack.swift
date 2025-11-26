//
//  TrackArchive AnyTrack.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension Cubase.TrackArchive {
    /// Type-erased box for a Cubase track archive track.
    public enum AnyTrack {
        // case tempo(TempoTrack) // tempo track is a special case, handled separately
        case marker(MarkerTrack)
        case orphan(OrphanTrack)
    }
}

extension Cubase.TrackArchive.AnyTrack: Equatable { }

extension Cubase.TrackArchive.AnyTrack: Hashable { }

extension Cubase.TrackArchive.AnyTrack: Sendable { }

extension Cubase.TrackArchive.AnyTrack: CubaseTrackArchiveTrack {
    public var name: String? {
        get {
            switch self {
            // case let .tempo(track): track.name
            case let .marker(track): track.name
            case let .orphan(track): track.name
            }
        }
        set {
            switch self {
            // case var .tempo(track):
            //     track.name = newValue
            //     self = .tempo(track)
            case var .marker(track):
                track.name = newValue
                self = .marker(track)
            case var .orphan(track):
                track.name = newValue
                self = .orphan(track)
            }
        }
    }
}

#endif
