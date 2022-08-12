//
//  TrackArchive ParseError.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension Cubase.TrackArchive {
    /// Cubase track archive XML parsing error.
    public enum ParseError: Error {
        case general(String)
    }
}

#endif
