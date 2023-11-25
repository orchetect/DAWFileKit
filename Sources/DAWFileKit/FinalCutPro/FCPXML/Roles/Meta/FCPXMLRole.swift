//
//  FCPXMLRole.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
@_implementationOnly import OTCore

public protocol FCPXMLRole where Self: RawRepresentable, RawValue == String { }

extension FCPXMLRole {
    /// Parses raw audio or video role string and returns role and optional sub-role.
    static func parseRawStandardRole(
        rawValue: String
    ) throws -> (role: String, subRole: String?) {
        let roleWithOptionalSubRolePattern = #"^([^?.\n\t]+)(\.([^?.\n\t]+)){0,1}$"#
        let roleAndSubrole = rawValue.regexMatches(
            captureGroupsFromPattern: roleWithOptionalSubRolePattern
        )
        
        guard roleAndSubrole.count == 4, // we burn a capture group for the period (.)
              let mainRole = roleAndSubrole[1]
        else {
            throw FinalCutPro.FCPXML.ParseError.general(
                "Malformed role encountered: \(rawValue.quoted)."
            )
        }
        
        return (role: mainRole, subRole: roleAndSubrole[3])
    }
    
    /// Parses raw caption role string and returns role and format/language code.
    static func parseRawCaptionRole(
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
        
        return (role: mainRole, captionFormat: format)
    }
}

#endif
