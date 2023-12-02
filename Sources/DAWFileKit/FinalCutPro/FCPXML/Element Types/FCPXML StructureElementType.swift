//
//  FCPXML StructureElementType.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    /// Structure element types.
    public enum StructureElementType: String, CaseIterable {
        /// Library element.
        case library
        
        /// Event element.
        case event
        
        /// Project element.
        case project
    }
}

extension FinalCutPro.FCPXML.StructureElementType: FCPXMLElementTypeProtocol {
    public var elementType: FinalCutPro.FCPXML.ElementType {
        .structure(self)
    }
}

#endif
