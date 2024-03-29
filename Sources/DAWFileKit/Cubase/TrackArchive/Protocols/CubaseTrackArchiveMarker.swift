//
//  CubaseTrackArchiveMarker.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

/// Protocol that DAWFileKit `Cubase.TrackArchive` markers conform to.
public protocol CubaseTrackArchiveMarker {
    var name: String { get set }
    
    var startTimecode: Timecode { get set }
    var startRealTime: TimeInterval? { get set }
}

#endif
