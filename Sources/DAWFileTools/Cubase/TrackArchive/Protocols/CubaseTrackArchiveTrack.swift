//
//  CubaseTrackArchiveTrack.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

/// Protocol that DAWFileTools `Cubase.TrackArchive` tracks conform to.
public protocol CubaseTrackArchiveTrack: Equatable, Hashable, Sendable {
    var name: String? { get set }
}

#endif
