//
//  SessionInfo OrphanData.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation

extension ProTools.SessionInfo {
    public struct OrphanData: Equatable, Hashable {
        public let heading: String
        public let content: [String]
    }
}
