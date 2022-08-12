//
//  TrackArchive ParseError.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension Cubase.TrackArchive {
    public enum EncodeError: Error {
        case general(String)
    }
}

#endif
