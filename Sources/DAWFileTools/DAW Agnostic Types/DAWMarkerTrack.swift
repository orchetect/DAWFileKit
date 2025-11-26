//
//  DAWMarkerTrack.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2024 Steffan Andrews • Licensed under MIT License
//

import Foundation

/// DAW-agnostic timeline capable of containing markers only.
public struct DAWMarkerTrack {
    // MARK: Contents
    
    /// Track name.
    public var name: String = ""
    
    public var trackType: DAWTrackType
    
    /// Markers contained in the track.
    public var markers: [DAWMarker]
    
    // MARK: Init
    
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

extension DAWMarkerTrack: Equatable { }

extension DAWMarkerTrack: Hashable { }

extension DAWMarkerTrack: Sendable { }

extension DAWMarkerTrack: Codable { }

// MARK: - Collection Methods

extension Collection where Element == DAWMarkerTrack {
    public func first(trackNamed name: String, trackType: DAWTrackType) -> Element? {
        guard let index = firstIndex(trackNamed: name, trackType: trackType) else { return nil }
        return self[index]
    }
    
    public func firstIndex(trackNamed name: String, trackType: DAWTrackType) -> Index? {
        firstIndex {
            $0.name == name && $0.trackType == trackType
        }
    }
    
    public func first(trackNamed name: String) -> Element? {
        guard let index = firstIndex(trackNamed: name) else { return nil }
        return self[index]
    }
    
    public func firstIndex(trackNamed name: String) -> Index? {
        firstIndex { $0.name == name }
    }
}
