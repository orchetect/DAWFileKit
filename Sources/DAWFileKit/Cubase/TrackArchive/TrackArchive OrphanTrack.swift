//
//  TrackArchive OrphanTrack.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension Cubase.TrackArchive {
    /// An orphan track that could not be parsed.
    public struct OrphanTrack: CubaseTrackArchiveTrack {
        public var name: String?
        
        public let rawXMLContent: String
    }
}

#endif
