//
//  SessionInfo ParseError.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation

extension ProTools.SessionInfo {
    /// Pro Tools session info text file parsing error.
    public enum ParseError: Error {
        case general(String)
    }
}
