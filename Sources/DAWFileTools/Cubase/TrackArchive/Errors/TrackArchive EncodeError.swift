//
//  TrackArchive EncodeError.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
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
