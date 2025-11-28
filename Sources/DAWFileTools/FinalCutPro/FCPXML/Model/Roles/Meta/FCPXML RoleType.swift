//
//  FCPXML RoleType.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import SwiftTimecodeCore

extension FinalCutPro.FCPXML {
    /// Role type/classification.
    public enum RoleType: String, Equatable, Hashable, CaseIterable, Sendable {
        /// Audio role.
        case audio
        
        /// Video role.
        case video
        
        /// Closed caption role.
        case caption
    }
}

extension Set<FinalCutPro.FCPXML.RoleType> {
    public static let allCases: Self = Set(Element.allCases)
}

#endif
