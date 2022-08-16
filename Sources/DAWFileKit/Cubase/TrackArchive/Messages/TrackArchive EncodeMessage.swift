//
//  TrackArchive EncodeMessage.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension Cubase.TrackArchive {
    public enum EncodeMessage: Error {
        /// Info message.
        /// Can be disregarded and only useful for debugging.
        case info(String)
        
        /// Error message.
        /// Something was malformed or data format was not expected.
        case error(String)
    }
}

// MARK: - Extensions

extension Collection where Element == Cubase.TrackArchive.EncodeMessage {
    /// Returns all `.info` cases as enum-unwrapped Strings.
    public var infos: [String] {
        reduce(into: [String]()) {
            switch $1 {
            case let .info(message):
                $0.append(message)
            default:
                break
            }
        }
    }
    
    /// Returns all `.error` cases as enum-unwrapped Strings.
    public var errors: [String] {
        reduce(into: [String]()) {
            switch $1 {
            case let .error(message):
                $0.append(message)
            default:
                break
            }
        }
    }
}

#endif
