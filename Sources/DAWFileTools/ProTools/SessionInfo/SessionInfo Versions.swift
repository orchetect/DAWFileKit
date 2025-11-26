//
//  SessionInfo Versions.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2023 Steffan Andrews • Licensed under MIT License
//

import Foundation

extension ProTools.SessionInfo {
    public enum MarkersListingVersion: Equatable, Hashable {
        /// Pro Tools versions prior to 2023.12.
        case legacy
        
        /// Pro Tools 2023.12 and up.
        case pt2023_12
    }
}

extension ProTools.SessionInfo.MarkersListingVersion: Sendable { }

extension ProTools.SessionInfo.MarkersListingVersion {
    public var columnCount: Int {
        switch self {
        case .legacy: return 6
        case .pt2023_12: return 8
        }
    }
    
    public var commentColumnIndex: Int {
        switch self {
        case .legacy: return 5
        case .pt2023_12: return 7
        }
    }
}
