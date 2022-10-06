//
//  SessionInfo Plugin.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation

extension ProTools.SessionInfo {
    /// Represents a plug-in used in the session
    public struct Plugin: Equatable, Hashable {
        var manufacturer: String = ""
        var name: String = ""
        var version: String = ""
        var format: String = ""
        var stems: String = ""
        var numberOfInstances: String = ""
    }
}
