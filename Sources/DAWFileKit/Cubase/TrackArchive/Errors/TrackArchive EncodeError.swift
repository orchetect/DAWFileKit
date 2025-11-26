//
//  TrackArchive EncodeError.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension Cubase.TrackArchive {
    public enum EncodeError: Error {
        case general(String)
    }
}

extension Cubase.TrackArchive.EncodeError: Equatable { }

extension Cubase.TrackArchive.EncodeError: Hashable { }

extension Cubase.TrackArchive.EncodeError: Sendable { }

#endif
