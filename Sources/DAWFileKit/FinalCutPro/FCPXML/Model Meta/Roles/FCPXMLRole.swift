//
//  FCPXMLRole.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
@_implementationOnly import OTCore

public protocol FCPXMLRole where Self: RawRepresentable, RawValue == String {
    /// Returns the role type enum case.
    var roleType: FinalCutPro.FCPXML.RoleType { get }
    
    /// Returns the annotation as ``FinalCutPro/FCPXML/AnyRole``.
    func asAnyRole() -> FinalCutPro.FCPXML.AnyRole
    
    /// Returns the role with its string lowercased.
    func lowercased() -> Self
    
    /// Returns the role with its string title-cased.
    func titleCased() -> Self
    
    /// Returns `true` if the role is a built-in role in Final Cut Pro (and not a user-defined
    /// role).
    var isBuiltIn: Bool { get }
}

// MARK: - Equatable

extension FCPXMLRole {
    func isEqual(to other: some FCPXMLRole) -> Bool {
        self.asAnyRole() == other.asAnyRole()
    }
}

// MARK: - Collection Methods

extension Collection<FinalCutPro.FCPXML.AnyRole> {
    public func contains(_ element: any FCPXMLRole) -> Bool {
        contains(where: { $0.wrapped.isEqual(to: element) })
    }
}

extension Dictionary where Value == FinalCutPro.FCPXML.AnyRole {
    public func contains(value element: any FCPXMLRole) -> Bool {
        values.contains(element)
    }
}

extension Collection where Element: FCPXMLRole {
    public func contains(_ element: FinalCutPro.FCPXML.AnyRole) -> Bool {
        contains(where: { $0.asAnyRole() == element })
    }
}

extension Dictionary where Value: FCPXMLRole {
    public func contains(value element: FinalCutPro.FCPXML.AnyRole) -> Bool {
        values.contains(where: { $0.asAnyRole() == element })
    }
}

// MARK: - Nested Type Erasure

extension Collection where Element: FCPXMLRole {
    public func asAnyRoles() -> [FinalCutPro.FCPXML.AnyRole] {
        map { $0.asAnyRole() }
    }
}

extension Collection<FinalCutPro.FCPXML.AnyRole> {
    public func asAnyRoles() -> [FinalCutPro.FCPXML.AnyRole] {
        map { $0.asAnyRole() }
    }
}

// MARK: - Utilities

/// Parses raw audio or video role string and returns role and optional sub-role.
func parseRawStandardRole(
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
    
/// Parses raw caption role string and returns role and format/language code.
func parseRawCaptionRole(
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

/// Strip off subrole if subrole is redundantly generated by FCP.
/// ie: A role of "Role.Role-1" would return "Role"
func collapseStandardSubRole(
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
    
    guard inputSubRole.starts(with: inputRole) else {
        return input
    }
    
    let subRoleSuffix = inputSubRole.dropFirst(inputRole.count) // "-1", "-2", etc.
    let pattern = #"^\-([\d]+)$"#
    let suffixMatches = subRoleSuffix.regexMatches(pattern: pattern)
    
    // just ensure the suffix matches the expected pattern, we don't care about its actual contents
    guard suffixMatches.count == 1 else {
        return input
    }
    
    return (role: input.role, subRole: nil)
}

public protocol FCPXMLCollapsibleRole: FCPXMLRole {
    /// Returns the role with a collapsed sub-role, if the sub-role is derivative of the main role.
    /// Only applies to audio and video roles.
    /// Has no effect on closed caption roles since they do not contain sub-roles.
    ///
    /// The sub-role is considered collapsible if it is identical to the main role with a trailing
    /// dash and number.
    ///
    /// For example:
    ///
    /// - The raw role string `Role` has no sub-role, and is therefore already collapsed.
    /// - The raw role string `Role.Role-1` is considered collapsible and would return
    ///   just the main `Role`, removing the sub-role.
    /// - The raw role string `Role.SubRole` is not considered collapsible since the sub-role is not
    ///   derived from the main role. The main and sub-role would be returned unchanged.
    ///
    /// > Note:
    /// >
    /// > This is provided merely as a convenience for representing simplified role names to the
    /// > user. It does not play a direct role in encoding or decoding FCPXML.
    func collapsingSubRole() -> Self
}

#endif
