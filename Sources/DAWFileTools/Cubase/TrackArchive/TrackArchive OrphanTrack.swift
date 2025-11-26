//
//  TrackArchive OrphanTrack.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
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

extension Cubase.TrackArchive.OrphanTrack: Equatable { }

extension Cubase.TrackArchive.OrphanTrack: Hashable { }

extension Cubase.TrackArchive.OrphanTrack: Sendable { }

#endif
