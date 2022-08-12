//
//  SessionInfo ParseError.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//

import Foundation

extension ProTools.SessionInfo {
    /// Pro Tools session info text file encoding error.
    public enum EncodeError: Error {
        case general(String)
    }
}
