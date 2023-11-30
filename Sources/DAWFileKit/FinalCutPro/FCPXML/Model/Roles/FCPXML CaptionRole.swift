//
//  FCPXML CaptionRole.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
@_implementationOnly import OTCore

extension FinalCutPro.FCPXML {
    /// Caption role.
    /// Contains a main role name and a caption format/language code.
    ///
    /// > Example raw role string encodings:
    /// > - `Dialogue` is a main video or audio role without a sub-role.
    /// > - `Dialogue.Dialogue-1` has main video or audio role of `Dialogue` with sub-role
    /// >   `Dialogue-1`.
    /// > - `iTT?captionFormat=ITT.en` is a closed caption role. `iTT` is the customizable name of
    /// >   the role which users may rename. `ITT.en` is the format and language code, which Final
    /// >   Cut Pro will display as the language name in its Roles list (ie: `ITT.en` would show as
    /// >   `English` in the Roles list and `English (iTT)` in the timeline captions ruler).
    ///
    /// > Note:
    /// >
    /// > Role names cannot include a dot (`.`) or a question mark (`?`).
    /// > This is enforced by Final Cut Pro because they are reserved characters for encoding the
    /// > string in FCPXML.
    /// > This is how Final Cut Pro separates role and sub-role.
    /// > Otherwise, any other Unicode character is valid, including accented characters and emojis.
    public struct CaptionRole: Equatable, Hashable {
        public let role: String
        public let captionFormat: String
        
        public init(role: String, captionFormat: String) {
            self.role = role
            self.captionFormat = captionFormat
        }
    }
}

extension FinalCutPro.FCPXML.CaptionRole: FCPXMLRole {
    public var roleType: FinalCutPro.FCPXML.RoleType { .caption }
    public func asAnyRole() -> FinalCutPro.FCPXML.AnyRole { .caption(self) }
    
    public func lowercased(derivedOnly: Bool) -> Self {
        // derivedOnly has no effect for caption roles
        
        let role = role.lowercased()
        // caption format case shouldn't be modified
        
        return Self(role: role, captionFormat: captionFormat)
    }
    
    public func titleCased(derivedOnly: Bool) -> Self {
        // derivedOnly has no effect for caption roles
        
        let role = role.titleCased
        // caption format case shouldn't be modified
        
        return Self(role: role, captionFormat: captionFormat)
    }
    
    public var isMainRoleBuiltIn: Bool {
        let builtInRoles = [
            "iTT", "SRT", "CEA-608"
        ]
        
        return builtInRoles.contains(role)
    }
}

extension FinalCutPro.FCPXML.CaptionRole: RawRepresentable {
    public var rawValue: String {
        role + "?captionFormat=" + captionFormat
    }
    
    public init?(rawValue: String) {
        guard let parsed = try? parseRawCaptionRole(rawValue: rawValue)
        else { return nil }
        
        role = parsed.role
        captionFormat = parsed.captionFormat
    }
}

extension FinalCutPro.FCPXML.CaptionRole: CustomDebugStringConvertible {
    public var debugDescription: String {
        "caption(\(rawValue.quoted))"
    }
}

#endif
