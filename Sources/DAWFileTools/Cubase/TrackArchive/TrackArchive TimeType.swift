//
//  TrackArchive TimeType.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension Cubase.TrackArchive {
    /// Cubase Track Archive time type.
    public enum TimeType: Int {
        case secondsOrBarsAndBeats = 0 // seconds and bars+beats both show up as 0
        case timecode = 4 // and 13?
        case samples = 10
        case user = 11
    }
}

extension Cubase.TrackArchive.TimeType: Equatable { }

extension Cubase.TrackArchive.TimeType: Hashable { }

extension Cubase.TrackArchive.TimeType: Sendable { }

#endif
