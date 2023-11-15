//
//  FCPXML StructureElementType.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    public enum StructureElementType: String {
        /// Event.
        case event
        
        /// Root-level XML element.
        case fcpxml
        
        /// Library.
        case library
        
        /// Project.
        case project
        
        /// Contains descriptions of media assets and other resources.
        case resources
        
        /// A container that represents the top-level sequence for a Final Cut Pro project or
        /// compound clip.
        case sequence
    }
}

#endif
