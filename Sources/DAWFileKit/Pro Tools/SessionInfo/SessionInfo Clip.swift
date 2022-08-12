//
//  SessionInfo Clip.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//

import Foundation

extension ProTools.SessionInfo {
    /// Represents a clip used in the session.
    public struct Clip {
        var name: String = ""
        var sourceFile: String = ""
        var channel: String?
        
        /// Flag determining if clip was online (true) or offline (false)
        var online: Bool = true
    }
}
