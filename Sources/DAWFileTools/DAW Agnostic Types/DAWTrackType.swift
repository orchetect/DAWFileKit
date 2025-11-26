//
//  DAWTrackType.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2024 Steffan Andrews • Licensed under MIT License
//

import Foundation

public enum DAWTrackType {
    /// Ruler.
    /// Typically pinned to the GUI's top edge of the timeline.
    case ruler
    
    /// Track.
    /// A track used in a timeline. Usually reorder-able, deletable, and duplicatable.
    case track
}

extension DAWTrackType: Equatable { }

extension DAWTrackType: Hashable { }

extension DAWTrackType: Identifiable {
    public var id: Self { self }
}

extension DAWTrackType: Sendable { }

extension DAWTrackType: Codable { }

