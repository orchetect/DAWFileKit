//
//  TrackArchive AnyMarker.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKitCore

extension Cubase.TrackArchive {
    /// Type-erased box for a Cubase marker.
    public enum AnyMarker {
        case marker(Marker)
        case cycleMarker(CycleMarker)
    }
}

extension Cubase.TrackArchive.AnyMarker: Equatable { }

extension Cubase.TrackArchive.AnyMarker: Hashable { }

extension Cubase.TrackArchive.AnyMarker: Sendable { }

extension Cubase.TrackArchive.AnyMarker: CubaseTrackArchiveMarker {
    public var name: String {
        get {
            switch self {
            case let .marker(marker): marker.name
            case let .cycleMarker(marker): marker.name
            }
        }
        set {
            switch self {
            case var .marker(marker):
                marker.name = newValue
                self = .marker(marker)
            case var .cycleMarker(marker):
                marker.name = newValue
                self = .cycleMarker(marker)
            }
        }
    }
    
    public var startTimecode: Timecode {
        get {
            switch self {
            case let .marker(marker): marker.startTimecode
            case let .cycleMarker(marker): marker.startTimecode
            }
        }
        set {
            switch self {
            case var .marker(marker):
                marker.startTimecode = newValue
                self = .marker(marker)
            case var .cycleMarker(marker):
                marker.startTimecode = newValue
                self = .cycleMarker(marker)
            }
        }
    }
    
    public var startRealTime: TimeInterval? {
        get {
            switch self {
            case let .marker(marker): marker.startRealTime
            case let .cycleMarker(marker): marker.startRealTime
            }
        }
        set {
            switch self {
            case var .marker(marker):
                marker.startRealTime = newValue
                self = .marker(marker)
            case var .cycleMarker(marker):
                marker.startRealTime = newValue
                self = .cycleMarker(marker)
            }
        }
    }
}

extension Cubase.TrackArchive.AnyMarker {
    public init(_ marker: Cubase.TrackArchive.Marker) {
        self = .marker(marker)
    }
    
    public init(_ marker: Cubase.TrackArchive.CycleMarker) {
        self = .cycleMarker(marker)
    }
}

#endif
