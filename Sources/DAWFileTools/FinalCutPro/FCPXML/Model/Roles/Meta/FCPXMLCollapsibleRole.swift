//
//  FCPXMLRole.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

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
