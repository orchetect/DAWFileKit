//
//  FCPXMLRole.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import SwiftExtensions

public protocol FCPXMLRole where Self: RawRepresentable, RawValue == String, Self: Sendable {
    /// Returns the role type enum case.
    var roleType: FinalCutPro.FCPXML.RoleType { get }
    
    /// Returns the annotation as ``FinalCutPro/FCPXML/AnyRole``.
    func asAnyRole() -> FinalCutPro.FCPXML.AnyRole
    
    /// Returns the role with its string lowercased.
    ///
    /// - Parameters:
    ///   - derivedOnly: Determines if the operation should only affect roles which have a sub-role
    ///     that is derived from its main role.
    func lowercased(derivedOnly: Bool) -> Self
    
    /// Returns the role with its string title-cased.
    /// 
    /// - Parameters:
    ///   - derivedOnly: Determines if the operation should only affect roles which have a sub-role
    ///     that is derived from its main role.
    func titleCased(derivedOnly: Bool) -> Self
    
    /// Returns the role with its string title-cased if it is a default role.
    ///
    /// Final Cut Pro typically writes default role names as lowercase in FCPXML.
    /// ie: `music.music-1` or `dialogue.dialogue-1`.
    ///
    /// User-defined roles are always written verbatim to the FCPXML.
    ///
    /// - Parameters:
    ///   - derivedOnly: Determines if the operation should only affect roles which have a sub-role
    ///     that is derived from its main role.
    func titleCasedDefaultRole(derivedOnly: Bool) -> Self
    
    /// Returns `true` if the role is a built-in role in Final Cut Pro (and not a user-defined
    /// role).
    var isMainRoleBuiltIn: Bool { get }
}

// MARK: - Equatable

extension FCPXMLRole {
    func isEqual(to other: some FCPXMLRole) -> Bool {
        self.asAnyRole() == other.asAnyRole()
    }
}

// MARK: - Collection Methods

extension Sequence<FinalCutPro.FCPXML.AnyRole> {
    @_disfavoredOverload
    public func contains(_ element: any FCPXMLRole) -> Bool {
        contains(where: { $0.wrapped.isEqual(to: element) })
    }
}

extension Dictionary where Value == FinalCutPro.FCPXML.AnyRole {
    public func contains(value element: any FCPXMLRole) -> Bool {
        values.contains(element)
    }
}

extension Sequence where Element: FCPXMLRole {
    @_disfavoredOverload
    public func contains(_ element: FinalCutPro.FCPXML.AnyRole) -> Bool {
        contains(where: { $0.asAnyRole() == element })
    }
}

extension Dictionary where Value: FCPXMLRole {
    public func contains(value element: FinalCutPro.FCPXML.AnyRole) -> Bool {
        values.contains(where: { $0.asAnyRole() == element })
    }
}

// MARK: - Collection Contains

extension Sequence where Element: FCPXMLRole {
    public var containsAudioRoles: Bool {
        contains(where: { $0.isAudio })
    }
    
    public var containsVideoRoles: Bool {
        contains(where: { $0.isVideo })
    }
    
    public var containsCaptionRoles: Bool {
        contains(where: { $0.isCaption })
    }
}

// MARK: - Collection Filtering

extension Sequence where Element: FCPXMLRole {
    public func filter(roleTypes: Set<FinalCutPro.FCPXML.RoleType>) -> [Element] {
        filter { roleTypes.contains($0.roleType) }
    }
}

extension Sequence where Element: FCPXMLRole {
    public func audioRoles() -> [Element] {
        filter(\.isAudio)
    }
    
    public func videoRoles() -> [Element] {
        filter(\.isVideo)
    }
    
    public func captionRoles() -> [Element] {
        filter(\.isCaption)
    }
}

// MARK: - Collection Transforms

extension Sequence where Element: FCPXMLRole {
    public func collapsingSubRoles() -> [Element] {
        map { $0.collapsingSubRole() }
    }
}

// MARK: - Collection Sorting

extension Sequence where Element: FCPXMLRole {
    /// Returns the sequence sorted by role name.
    public func sortedByName() -> [Element] {
        sorted { lhs, rhs in
            lhs.rawValue.localizedStandardCompare(rhs.rawValue) == .orderedAscending
        }
    }
    
    /// Returns the sequence sorted by role type: video, then audio, then caption.
    /// Role order is otherwise maintained and roles are not sorted alphabetically.
    public func sortedByRoleType() -> [Element] {
        videoRoles()
            + audioRoles()
            + captionRoles()
    }
    
    /// Returns the sequence first sorted by role type (video, then audio, then caption)
    /// then sorted alphabetically within each type.
    public func sortedByRoleTypeThenByName() -> [Element] {
        videoRoles().sortedByName()
            + audioRoles().sortedByName()
            + captionRoles().sortedByName()
    }
}

// MARK: - Nested Type Erasure

extension Sequence where Element: FCPXMLRole {
    public func asAnyRoles() -> [FinalCutPro.FCPXML.AnyRole] {
        map { $0.asAnyRole() }
    }
}

extension Sequence<FinalCutPro.FCPXML.AnyRole> {
    public func asAnyRoles() -> [FinalCutPro.FCPXML.AnyRole] {
        map { $0.asAnyRole() }
    }
}

// MARK: - Methods

extension FCPXMLRole where Self: FCPXMLCollapsibleRole {
    public func collapsingSubRole() -> Self {
        collapsingSubRole()
    }
}

extension FCPXMLRole {
    @_disfavoredOverload
    public func collapsingSubRole() -> Self {
        self
    }
}

// MARK: - Properties

extension FCPXMLRole {
    /// Returns `true` if the role is an audio role.
    public var isAudio: Bool {
        roleType == .audio
    }
    
    /// Returns `true` if the role is a video role.
    public var isVideo: Bool {
        roleType == .video
    }
    
    /// Returns `true` if the role is a caption role.
    public var isCaption: Bool {
        roleType == .caption
    }
}

// MARK: - Utilities

extension FinalCutPro.FCPXML {
    /// Utility:
    /// Parses raw audio or video role string and returns role and optional sub-role.
    static func _parseRawStandardRole(
        rawValue: String
    ) throws -> (role: String, subRole: String?) {
        let roleWithOptionalSubRolePattern = #"^([^?.\n\t]+)(\.([^?.\n\t]+)){0,1}$"#
        let roleAndSubrole = rawValue.regexMatches(
            captureGroupsFromPattern: roleWithOptionalSubRolePattern,
            options: [.useUnicodeWordBoundaries]
        )
        
        guard roleAndSubrole.count == 4, // we burn a capture group for the period (.)
              let mainRole = roleAndSubrole[1]
        else {
            throw FinalCutPro.FCPXML.ParseError.general(
                "Malformed role encountered: \(rawValue.quoted)."
            )
        }
        
        // re-cast Substrings as Strings
        let mainRoleString = String(mainRole)
        let subRoleString = roleAndSubrole[3] != nil ? String(roleAndSubrole[3]!) : nil
        
        return (role: mainRoleString, subRole: subRoleString)
    }
    
    /// Utility:
    /// Parses raw caption role string and returns role and format/language code.
    static func _parseRawCaptionRole(
        rawValue: String
    ) throws -> (role: String, captionFormat: String) {
        let captionRolePattern = #"^([^?.\n\t]+)\?captionFormat=([^?\n\t]+)$"#
        let roleAndSubrole = rawValue.regexMatches(
            captureGroupsFromPattern: captionRolePattern
        )
        
        guard roleAndSubrole.count == 3,
              let mainRole = roleAndSubrole[1],
              let format = roleAndSubrole[2]
        else {
            throw FinalCutPro.FCPXML.ParseError.general(
                "Malformed caption role encountered: \(rawValue.quoted)."
            )
        }
        
        // re-cast Substrings as Strings
        let mainRoleString = String(mainRole)
        let formatString = String(format)
        
        return (role: mainRoleString, captionFormat: formatString)
    }
    
    /// Utility:
    /// Strip off subrole if subrole is redundantly generated by FCP.
    /// ie: A role of `Role.Role-1` would return `Role`.
    static func _collapseStandardSubRole(
        role inputRole: String,
        subRole inputSubRole: String?
    ) -> (role: String, subRole: String?) {
        let input = (role: inputRole, subRole: inputSubRole)
        
        guard let inputSubRole = inputSubRole else {
            return input
        }
        
        // interpret an empty sub-role string or whitespace-only sub-role as being nil
        guard !inputSubRole.trimmed.isEmpty else {
            return (role: inputRole, subRole: nil)
        }
        
        guard _isSubRole(inputSubRole, derivedFromMainRole: input.role) else {
            return input
        }
        
        return (role: input.role, subRole: nil)
    }
    
    /// Utility:
    /// Returns `true` if the given sub-role is derived from the main role.
    ///
    /// - `Dialogue.Dialogue` or `Dialogue.Dialogue-1` are considered derivative.
    /// - `Dialogue.CustomRole` is not considered derivative.
    static func _isSubRole(_ subRole: String?, derivedFromMainRole mainRole: String) -> Bool {
        guard let subRole = subRole,
              subRole.starts(with: mainRole)
        else { return false }
        
        if mainRole == subRole { return true }
        
        // just ensure the suffix matches the expected pattern, we don't care about its actual contents
        // since we already confirmed main role starts with the sub-role
        let subRoleSuffix = subRole.dropFirst(mainRole.count) // "-1", "-2", etc.
        let pattern = #"^\-([\d]+)$"#
        let suffixMatches = subRoleSuffix.regexMatches(pattern: pattern)
        
        return suffixMatches.count == 1
    }
}

#endif
