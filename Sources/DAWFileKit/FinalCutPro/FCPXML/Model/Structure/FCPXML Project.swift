//
//  FCPXML Project.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import CoreMedia
import Foundation

extension FinalCutPro.FCPXML {
    /// Project element.
    public enum Project { }
}

extension FinalCutPro.FCPXML.Project {
    public var structureElementType: FinalCutPro.FCPXML.StructureElementType {
        .project
    }
    
    public enum Attributes: String, XMLParsableAttributesKey {
        case name
        case id
        case uid
        case modDate
        case sequence
    }
}

#endif
