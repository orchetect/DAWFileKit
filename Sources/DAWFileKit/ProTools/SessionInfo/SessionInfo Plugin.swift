//
//  SessionInfo Plugin.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation

extension ProTools.SessionInfo {
    /// Represents a plug-in used in the session
    public struct Plugin: Equatable, Hashable {
        public internal(set) var manufacturer: String = ""
        public internal(set) var name: String = ""
        public internal(set) var version: String = ""
        public internal(set) var format: String = ""
        public internal(set) var stems: String = ""
        public internal(set) var numberOfInstances: String = ""
    }
}
