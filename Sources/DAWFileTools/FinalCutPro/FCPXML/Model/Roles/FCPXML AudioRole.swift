//
//  FCPXML AudioRole.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import SwiftExtensions

extension FinalCutPro.FCPXML {
    /// Audio role.
    /// Contains a main role name with an optional sub-role.
    ///
    /// > Note:
    /// >
    /// > Role names cannot include a dot (`.`) or a question mark (`?`).
    /// > This is enforced by Final Cut Pro because they are reserved characters for encoding the
    /// > string in FCPXML.
    /// > This is how Final Cut Pro separates role and sub-role.
    /// > Otherwise, any other Unicode character is valid, including accented characters and emojis.
    public struct AudioRole: Equatable, Hashable, Sendable {
        public let role: String
        public let subRole: String?
        
        public init(role: String, subRole: String? = nil) {
            self.role = role
            self.subRole = subRole
        }
    }
}

extension FinalCutPro.FCPXML.AudioRole: FCPXMLRole {
    public var roleType: FinalCutPro.FCPXML.RoleType { .audio }
    public func asAnyRole() -> FinalCutPro.FCPXML.AnyRole { .audio(self) }
    
    public func lowercased(derivedOnly: Bool) -> Self {
        let newRole: String = role.lowercased()
        var newSubRole: String?
        
        if derivedOnly, !isSubRoleDerivedFromMainRole {
            newSubRole = subRole
        } else {
            newSubRole = subRole?.lowercased()
        }
        
        return Self(role: newRole, subRole: newSubRole)
    }
    
    public func titleCased(derivedOnly: Bool) -> Self {
        let newRole: String = role.titleCased
        var newSubRole: String?
        
        if derivedOnly, !isSubRoleDerivedFromMainRole {
            newSubRole = subRole
        } else {
            newSubRole = subRole?.titleCased
        }
        
        return Self(role: newRole, subRole: newSubRole)
    }
    
    public func titleCasedDefaultRole(derivedOnly: Bool) -> Self {
        isMainRoleBuiltIn
            ? titleCased(derivedOnly: derivedOnly)
            : self
    }
    
    public var isMainRoleBuiltIn: Bool {
        let builtInMainRoles = [
            "dialogue", "Dialogue",
            "effects", "Effects",
            "music", "Music"
        ]
        
        return builtInMainRoles.contains(role)
    }
    
    public var isSubRoleDerivedFromMainRole: Bool {
        FinalCutPro.FCPXML._isSubRole(subRole, derivedFromMainRole: role)
    }
}

extension FinalCutPro.FCPXML.AudioRole: RawRepresentable {
    public var rawValue: String {
        var rawRole = role
        if let subRole = subRole {
            rawRole += "." + subRole
        }
        return rawRole
    }
    
    public init?(rawValue: String) {
        guard let parsed = try? FinalCutPro.FCPXML._parseRawStandardRole(rawValue: rawValue)
        else { return nil }
        
        role = parsed.role
        subRole = parsed.subRole
    }
}

extension FinalCutPro.FCPXML.AudioRole: CustomDebugStringConvertible {
    public var debugDescription: String {
        "audio(\(rawValue.quoted))"
    }
}

extension FinalCutPro.FCPXML.AudioRole: FCPXMLCollapsibleRole {
    public func collapsingSubRole() -> Self {
        let collapsedValues = FinalCutPro.FCPXML._collapseStandardSubRole(
            role: role,
            subRole: subRole
        )
        return Self(role: collapsedValues.role, subRole: collapsedValues.subRole)
    }
}

#endif
