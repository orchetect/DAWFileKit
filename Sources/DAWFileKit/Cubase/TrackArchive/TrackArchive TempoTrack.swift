//
//  TrackArchive TempoTrack.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension Cubase.TrackArchive {
    /// Represents a cycle marker event and its contents.
    public struct TempoTrack: CubaseTrackArchiveTrack {
        public var name: String?
        public var events: [Event]
        
        public init(name: String? = nil, events: [Event] = []) {
            self.name = name
            self.events = events
        }
    }
}

extension Cubase.TrackArchive.TempoTrack: Equatable { }

extension Cubase.TrackArchive.TempoTrack: Hashable { }

extension Cubase.TrackArchive.TempoTrack: Sendable { }

// MARK: - Event

extension Cubase.TrackArchive.TempoTrack {
    /// A tempo track event.
    public struct Event {
        public var startTimeAsPPQ: Cubase.PPQ
        public var tempo: Cubase.Tempo
        public var type: TempoEventType
        
        public init(startTimeAsPPQ: Cubase.PPQ, tempo: Cubase.Tempo, type: TempoEventType) {
            self.startTimeAsPPQ = startTimeAsPPQ
            self.tempo = tempo
            self.type = type
        }
    }
}

extension Cubase.TrackArchive.TempoTrack.Event: Equatable { }

extension Cubase.TrackArchive.TempoTrack.Event: Hashable { }

extension Cubase.TrackArchive.TempoTrack.Event: Sendable { }

// MARK: - Event TempoEventType

extension Cubase.TrackArchive.TempoTrack.Event {
    /// A tempo track event type.
    public enum TempoEventType {
        case jump
        case ramp
    }
}

extension Cubase.TrackArchive.TempoTrack.Event.TempoEventType: Equatable { }

extension Cubase.TrackArchive.TempoTrack.Event.TempoEventType: Hashable { }

extension Cubase.TrackArchive.TempoTrack.Event.TempoEventType: CaseIterable { }

extension Cubase.TrackArchive.TempoTrack.Event.TempoEventType: Sendable { }

#endif
