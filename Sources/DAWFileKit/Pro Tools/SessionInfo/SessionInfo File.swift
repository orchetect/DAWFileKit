//
//  SessionInfo File.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation

extension ProTools.SessionInfo {
    /// Represents a file used in the session
    public struct File: Equatable, Hashable {
        public internal(set) var filename: String = ""
        public internal(set) var path: String = ""
        
        /// Flag determining if file was online (true) or offline (false)
        public internal(set) var online: Bool = true
    }
}
