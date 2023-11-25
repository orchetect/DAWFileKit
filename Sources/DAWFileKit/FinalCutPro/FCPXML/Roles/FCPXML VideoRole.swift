//
//  FCPXML VideoRole.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    /// Video role.
    /// Contains a main role name with an optional sub-role.
    ///
    /// > Note:
    /// >
    /// > Role names cannot include a dot (`.`) or a question mark (`?`).
    /// > This is enforced by Final Cut Pro because they are reserved characters for encoding the
    /// > string in FCPXML.
    /// > This is how Final Cut Pro separates role and sub-role.
    /// > Otherwise, any other Unicode character is valid, including accented characters and emojis.
    public struct VideoRole: Equatable, Hashable {
        public let role: String
        public let subRole: String?
        
        public init(role: String, subRole: String? = nil) {
            self.role = role
            self.subRole = subRole
        }
    }
}

extension FinalCutPro.FCPXML.VideoRole: FCPXMLRole {
    public var rawValue: String {
        var rawRole = role
        if let subRole = subRole {
            rawRole += "." + subRole
        }
        return rawRole
    }
    
    public init?(rawValue: String) {
        guard let parsed = try? parseRawStandardRole(rawValue: rawValue)
        else { return nil }
        
        role = parsed.role
        subRole = parsed.subRole
    }
}

extension FinalCutPro.FCPXML.VideoRole: CustomDebugStringConvertible {
    public var debugDescription: String {
        "video(\(rawValue.quoted))"
    }
}

#endif
