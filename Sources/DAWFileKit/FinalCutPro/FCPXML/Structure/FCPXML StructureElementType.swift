//
//  FCPXML StructureElementType.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    public enum StructureElementType: String, CaseIterable {
        /// Library.
        case library
        
        /// Event.
        case event
        
        /// Project.
        case project
    }
}

#endif
