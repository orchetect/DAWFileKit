//
//  FCPXML Marker Attributes.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML.Marker {
    /// Marker XML Attributes.
    public enum Attributes: String {
        // XML Attributes all Markers have in common.
        case start
        case duration
        case value // marker name
        case note
        
        // Chapter Marker only
        case posterOffset
        
        // To Do Marker only
        case completed
    }
}

#endif
