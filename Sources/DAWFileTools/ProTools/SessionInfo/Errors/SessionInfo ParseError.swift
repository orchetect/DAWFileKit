//
//  SessionInfo ParseError.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation

extension ProTools.SessionInfo {
    /// Pro Tools session info text file parsing error.
    public enum ParseError: Error {
        case general(String)
    }
}
