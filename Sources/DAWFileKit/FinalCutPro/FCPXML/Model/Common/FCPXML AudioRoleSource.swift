//
//  FCPXML AudioRoleSource.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    /// FCPXML 1.11 DTD:
    /// "An `audio-role-source` element adjusts playback settings for a single role-based audio
    /// component in a clip."
    public struct AudioRoleSource: Equatable, Hashable {
        /// Role the audio component is associated with.
        public var role: FinalCutPro.FCPXML.AudioRole
        
        /// Active state of the audio role source.
        public var active: Bool
        
        public var contents: [XMLElement]
        
        public init(
            role: FinalCutPro.FCPXML.AudioRole,
            active: Bool,
            contents: [XMLElement] = []
        ) {
            self.role = role
            self.active = active
            self.contents = contents
        }
    }
}

extension FinalCutPro.FCPXML.AudioRoleSource {
    public enum Element: String {
        case name = "audio-role-source"
    }
    
    /// Attributes unique to ``AudioRoleSource``.
    public enum Attributes: String, XMLParsableAttributesKey {
        case role
        case active
    }
    
    init?(from xmlLeaf: XMLElement) {
        // validate element name
        guard xmlLeaf.name == Element.name.rawValue else { return nil }
        
        let rawValues = xmlLeaf.parseRawAttributeValues(key: Attributes.self)
        
        guard let audioRole = FinalCutPro.FCPXML.AudioRole(rawValue: rawValues[.role] ?? "")
        else { return nil }
        role = audioRole
        
        active = rawValues[.active] ?? "1" == "1"
        
        contents = xmlLeaf.children?.compactMap { $0 as? XMLElement } ?? []
    }
}

extension FinalCutPro.FCPXML {
    static func parseAudioRoleSources(from xmlLeaf: XMLElement) -> [AudioRoleSource] {
        let elements = (xmlLeaf.children ?? [])
            .filter { $0.name == AudioRoleSource.Element.name.rawValue }
            .compactMap { $0 as? XMLElement }
        
        return elements.compactMap {
            AudioRoleSource(from: $0)
        }
    }
}

// MARK: - Collection Methods

extension [FinalCutPro.FCPXML.AudioRoleSource] {
    /// Convert and wrap the audio role source as ``FinalCutPro/FCPXML/AnyRole``
    public func asAnyRoles() -> [FinalCutPro.FCPXML.AnyRole] {
        map { $0.role }
            .compactMap { FinalCutPro.FCPXML.AnyRole.audio($0) }
    }
}

#endif
