//
//  SessionInfo Marker.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation
import TimecodeKit

extension ProTools.SessionInfo {
    /// Represents a single marker and its related info.
    ///
    /// Pro Tools includes Markers in a bin of items called Memory Locations.
    /// Memory Locations include **Markers** and **Selections** (a selection which has in and out points). Both of these may be defined in two different timebases:
    ///
    /// - **Absolute** (an exact timecode in the project unaffected by tempo track etc.)
    /// - **Bar | Beat** (tied to a musical position which may change if the tempo track changes and is not guaranteed to always be the same timecode).
    ///
    /// Pro Tools will only export Markers in its text file export. Selections are not included at all.
    ///
    /// When Pro Tools exports Markers to the text file, primary location is always included (in the time format selected while exporting the text file, which defaults to Timecode format) but there is also a secondary "Time Reference" for each Marker included that depends on the Marker type.
    ///
    /// - For **Absolute** Markers, elapsed audio samples is included.
    ///
    ///   Refer to ``ProTools/SessionInfo/main-swift.property``.``ProTools/SessionInfo/Main-swift.struct/sampleRate`` for project sample rate.
    ///
    /// - For **Bar | Beat** Markers, the bar and beat number are included.
    ///
    ///   Beat divisions (ticks) are omitted unless the _Show Subframes_ option is enabled in Pro Tools' Export Session Text window while exporting. Pro Tools uses a PPQ base of 960 ticks per quarter.
    public struct Marker {
        /// Marker number.
        /// This is the Memory Location number assigned to the Marker in the Pro Tools project.
        public let number: Int
        
        /// Location.
        public let location: TimeValue?
        
        /// Time Reference (secondary location information based on the Marker type).
        ///
        /// - For **Absolute** Markers, elapsed audio samples is included.
        ///
        ///   Refer to ``ProTools/SessionInfo/main-swift.property``.``ProTools/SessionInfo/Main-swift.struct/sampleRate`` for project sample rate.
        ///
        /// - For **Bar | Beat** Markers, the bar and beat number are included.
        ///
        ///   Beat divisions (ticks) are omitted unless the _Show Subframes_ option is enabled in Pro Tools' Export Session Text window while exporting. Pro Tools uses a PPQ base of 960 ticks per quarter.
        public let timeReference: TimeValue
        
        /// Marker name.
        public let name: String
        
        /// Marker comment, if present.
        public let comment: String?
        
        // MARK: - Init
        
        public init(
            number: Int,
            location: TimeValue?,
            timeReference: TimeValue,
            name: String,
            comment: String? = nil
        ) {
            self.number = number
            self.location = location
            self.timeReference = timeReference
            self.name = name
            self.comment = comment
        }
    }
}
