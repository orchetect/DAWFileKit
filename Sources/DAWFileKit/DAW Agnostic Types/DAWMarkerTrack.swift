//
//  DAWMarkerTrack.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2024 Steffan Andrews • Licensed under MIT License
//

import Foundation

/// DAW-agnostic timeline capable of containing markers only.
public struct DAWMarkerTrack: Codable {
    // MARK: Contents
    
    /// Track name.
    public var name: String = ""
    
    public var trackType: DAWTrackType
    
    /// Markers contained in the track.
    public var markers: [DAWMarker]
    
    // MARK: init
    
    public init(
        trackType: DAWTrackType,
        name: String = "",
        markers: [DAWMarker] = []
    ) {
        self.trackType = trackType
        self.name = name
        self.markers = markers
    }
}
