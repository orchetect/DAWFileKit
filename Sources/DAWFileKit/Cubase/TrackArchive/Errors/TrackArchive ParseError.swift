//
//  TrackArchive ParseError.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension Cubase.TrackArchive {
    /// Cubase track archive XML parsing error.
    public enum ParseError: Error {
        case general(String)
    }
}

extension Cubase.TrackArchive.ParseError: Equatable { }

extension Cubase.TrackArchive.ParseError: Hashable { }

extension Cubase.TrackArchive.ParseError: Sendable { }

#endif
