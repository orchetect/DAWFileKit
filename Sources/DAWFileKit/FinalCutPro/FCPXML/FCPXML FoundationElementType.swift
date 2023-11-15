//
//  FCPXML FoundationElementType.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    public enum FoundationElementType: String {
        /// Root-level XML element.
        case fcpxml
        
        /// Library.
        case library
        
        /// Contains descriptions of media assets and other resources.
        case resources
    }
}

#endif
