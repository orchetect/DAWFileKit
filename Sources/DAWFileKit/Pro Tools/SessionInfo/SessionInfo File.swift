//
//  SessionInfo File.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//

import Foundation

extension ProTools.SessionInfo {
    /// Represents a file used in the session
    public struct File {
        var filename: String = ""
        var path: String = ""
        
        /// Flag determining if file was online (true) or offline (false)
        var online: Bool = true
    }
}
