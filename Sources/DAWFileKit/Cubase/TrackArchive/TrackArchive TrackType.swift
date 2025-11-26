//
//  TrackArchive TrackType.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension Cubase.TrackArchive {
    /// Track types. Raw values represent their corresponding XML node name.
    public enum TrackType: String {
        case tempo = "MTempoTrackEvent"
        case marker = "MMarkerTrackEvent"
        case orphan = "" // any other unrecognized/unhandled track types
    }
}

extension Cubase.TrackArchive.TrackType: Equatable { }

extension Cubase.TrackArchive.TrackType: Hashable { }

extension Cubase.TrackArchive.TrackType: CaseIterable { }

extension Cubase.TrackArchive.TrackType: Sendable { }

#endif
