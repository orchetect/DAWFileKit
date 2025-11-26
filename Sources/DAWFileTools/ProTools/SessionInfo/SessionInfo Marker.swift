//
//  SessionInfo Marker.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation
import TimecodeKitCore

extension ProTools.SessionInfo {
    /// Represents a single marker and its related info.
    ///
    /// Pro Tools includes Markers in a bin of items called Memory Locations.
    /// Memory Locations include **Markers** and **Selections** (a selection which has in and out
    /// points). Both of these may be defined in two different timebases:
    ///
    /// - **Absolute** (an exact timecode in the project unaffected by tempo track etc.)
    /// - **Bar | Beat** (tied to a musical position which may change if the tempo track changes and
    ///   is not guaranteed to always be the same timecode).
    ///
    /// Pro Tools will only export Markers in its text file export. Selections are not included at
    /// all.
    ///
    /// When Pro Tools exports Markers to the text file, primary location is always included (in the
    /// time format selected while exporting the text file, which defaults to Timecode format) but
    /// there is also a secondary "Time Reference" for each Marker included that depends on the
    /// Marker type.
    ///
    /// - For **Absolute** Markers, elapsed audio samples is included.
    ///
    ///   Refer to ``ProTools/SessionInfo/main-swift.property``.``ProTools/SessionInfo/Main-swift.struct/sampleRate``
    ///   for project sample rate.
    ///
    /// - For **Bar | Beat** Markers, the bar and beat number are included.
    ///
    ///   Beat divisions (ticks) are omitted unless the _Show Subframes_ option is enabled in Pro
    ///   Tools' Export Session Text window while exporting. Pro Tools uses a PPQ base of 960 ticks
    ///   per quarter.
    public struct Marker: Equatable, Hashable {
        /// Marker number.
        /// This is the Memory Location number assigned to the Marker in the Pro Tools project.
        public let number: Int
        
        /// Location.
        public let location: TimeValue?
        
        /// Time Reference (secondary location information based on the Marker type).
        ///
        /// - For **Absolute** Markers, elapsed audio samples is included.
        ///
        ///   Refer to ``ProTools/SessionInfo/main-swift.property``.``ProTools/SessionInfo/Main-swift.struct/sampleRate``
        ///   for project sample rate.
        ///
        /// - For **Bar | Beat** Markers, the bar and beat number are included.
        ///
        ///   Beat divisions (ticks) are omitted unless the _Show Subframes_ option is enabled in
        ///   Pro Tools' Export Session Text window while exporting. Pro Tools uses a PPQ base of
        ///   960 ticks per quarter.
        public let timeReference: TimeValue
        
        /// Marker name.
        public let name: String
        
        /// Track name.
        ///
        /// For marker rulers, the ruler name will be returned: "Markers", "Markers 2", "Markers 3", "Markers 4" or "Markers 5".
        ///
        /// For track markers, this will return the name of the track the marker was inserted on.
        ///
        /// > Note:
        /// >
        /// > Pro Tools 2023.12 introduced exporting track name information in the session info text file.
        public let trackName: String
        
        /// Marker track type.
        ///
        /// > Note:
        /// >
        /// > Pro Tools 2023.6 added the ability to insert markers directly on tracks using a marker lane.
        /// >
        /// > Pro Tools 2023.12 introduced exporting track type information in the session info text file.
        public let trackType: TrackType
        
        /// Marker comment, if present.
        public let comment: String?
        
        // MARK: - Init
        
        init(
            number: Int,
            location: TimeValue?,
            timeReference: TimeValue,
            name: String,
            trackName: String = "Markers",
            trackType: TrackType = .ruler,
            comment: String? = nil
        ) {
            self.number = number
            self.location = location
            self.timeReference = timeReference
            self.name = name
            self.trackName = trackName
            self.trackType = trackType
            self.comment = comment
        }
    }
}

extension ProTools.SessionInfo.Marker: Sendable { }

extension ProTools.SessionInfo.Marker {
    /// Marker track type.
    public enum TrackType: String, Equatable, Hashable {
        /// Marker ruler.
        ///
        /// > Note:
        /// >
        /// > Pro Tools 2023.12 added four additional session marker rulers for a total of five.
        /// >
        /// > Prior to Pro Tools 2023.12, only one session marker ruler was available.
        case ruler = "Ruler"
        
        /// Track.
        ///
        /// > Note:
        /// >
        /// > Pro Tools 2023.6 added the ability to insert markers directly on tracks using a marker lane.
        /// >
        /// > Prior to Pro Tools 2023.6, only one session marker ruler was available and markers could
        /// > not be inserted directly on tracks.
        case track = "Track"
    }
}

extension ProTools.SessionInfo.Marker.TrackType: Sendable { }
