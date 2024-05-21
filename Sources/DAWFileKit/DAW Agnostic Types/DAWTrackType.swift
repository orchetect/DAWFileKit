//
//  DAWTrackType.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2024 Steffan Andrews • Licensed under MIT License
//

import Foundation

public enum DAWTrackType: Equatable, Hashable, Codable {
    /// Ruler.
    /// Typically pinned to the GUI's top edge of the timeline.
    case ruler
    
    /// Track.
    /// A track used in a timeline. Usually reorder-able, deletable, and duplicatable.
    case track
}
