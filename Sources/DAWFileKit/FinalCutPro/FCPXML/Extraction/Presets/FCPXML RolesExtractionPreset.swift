//
//  FCPXML RolesExtractionPreset.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import OTCore

extension FinalCutPro.FCPXML {
    /// FCPXML extraction preset that extracts roles within a specified scope.
    public struct RolesExtractionPreset: FCPXMLExtractionPreset {
        var roleTypes: Set<RoleType>
        
        public init(
            roleTypes: Set<RoleType>
        ) {
            self.roleTypes = roleTypes
        }
        
        public func perform(
            on extractable: XMLElement,
            scope: FinalCutPro.FCPXML.ExtractionScope
        ) async -> [FinalCutPro.FCPXML.AnyRole] {
            let extracted = await extractable.fcpExtract(scope: scope) { element in
                element
                    .value(forContext: .inheritedRoles)
                    .filter(roleTypes: roleTypes)
                    .map(\.wrapped)
            }
            
            let output = extracted
                .flatMap { $0 }
                .removingDuplicates()
                .sortedByRoleTypeThenByName()
            
            return output
        }
    }
}

extension FCPXMLExtractionPreset where Self == FinalCutPro.FCPXML.RolesExtractionPreset {
    /// FCPXML extraction preset that extracts roles within a specified scope.
    public static func roles(
        roleTypes: Set<FinalCutPro.FCPXML.RoleType> = .allCases
    ) -> FinalCutPro.FCPXML.RolesExtractionPreset {
        FinalCutPro.FCPXML.RolesExtractionPreset(
            roleTypes: roleTypes
        )
    }
}

#endif
