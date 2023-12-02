//
//  FCPXML Event.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    /// Represent a single event in a library.
    ///
    /// > Final Cut Pro FCPXML 1.11 Reference:
    /// >
    /// > An event may contain clips as story elements and projects, along with keyword collections
    /// > and smart collections. The keyword-collection and smart-collection elements organize clips
    /// > by keywords and other matching criteria listed under the Smart Collection Match Elements.
    public enum Event { }
}

extension FinalCutPro.FCPXML.Event {
    public var structureElementType: FinalCutPro.FCPXML.StructureElementType {
        .event
    }
    
    public enum Attributes: String, XMLParsableAttributesKey {
        case name
        case uid
    }
    
    // contains projects
    // contains clips
    // contains collection folders
    // contains keyword collections
    // contains smart collections
}

#endif
