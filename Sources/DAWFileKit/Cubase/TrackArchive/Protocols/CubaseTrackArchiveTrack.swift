//
//  CubaseTrackArchiveTrack.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

/// Protocol that DAWFileKit `Cubase.TrackArchive` tracks conform to.
public protocol CubaseTrackArchiveTrack {
    var name: String? { get set }
}

#endif
