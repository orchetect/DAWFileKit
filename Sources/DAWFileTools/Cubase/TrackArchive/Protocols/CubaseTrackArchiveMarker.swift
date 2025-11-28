//
//  CubaseTrackArchiveMarker.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import SwiftTimecodeCore

/// Protocol that DAWFileTools `Cubase.TrackArchive` markers conform to.
public protocol CubaseTrackArchiveMarker: Equatable, Hashable, Sendable {
    var name: String { get set }
    
    var startTimecode: Timecode { get set }
    var startRealTime: TimeInterval? { get set }
}

#endif
