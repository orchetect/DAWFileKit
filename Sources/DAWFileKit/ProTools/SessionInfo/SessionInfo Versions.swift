//
//  SessionInfo Versions.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
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
