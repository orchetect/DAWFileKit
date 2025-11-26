//
//  SessionInfo Clip.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation

extension ProTools.SessionInfo {
    /// Represents a clip used in the session.
    public struct Clip: Equatable, Hashable {
        public internal(set) var name: String = ""
        public internal(set) var sourceFile: String = ""
        public internal(set) var channel: String?
        
        /// Flag determining if clip was online (true) or offline (false)
        public internal(set) var online: Bool = true
    }
}

extension ProTools.SessionInfo.Clip: Sendable { }
