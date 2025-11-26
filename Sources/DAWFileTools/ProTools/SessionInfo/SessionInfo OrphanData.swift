//
//  SessionInfo OrphanData.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation

extension ProTools.SessionInfo {
    public struct OrphanData: Equatable, Hashable {
        public internal(set) var heading: String
        public internal(set) var content: [String]
    }
}

extension ProTools.SessionInfo.OrphanData: Sendable { }
