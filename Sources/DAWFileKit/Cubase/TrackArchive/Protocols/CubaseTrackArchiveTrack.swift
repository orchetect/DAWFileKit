//
//  CubaseTrackArchiveTrack.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

public protocol CubaseTrackArchiveTrack {
    
    var name: String? { get set }
    
}

#endif
