//
//  FCPXML MarkerType.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    /// Marker element types.
    public enum MarkerType: String, CaseIterable {
        /// Marker. 
        /// Used for both standard and to-do markers.
        case marker
        
        /// Chapter marker.
        case chapterMarker = "chapter-marker"
        
        // TODO: add `analysis-marker`?
    }
}

extension FinalCutPro.FCPXML.MarkerType: FCPXMLElementTypeProtocol {
    public var elementType: FinalCutPro.FCPXML.ElementType {
        .story(.annotation(.marker(self)))
    }
}

#endif
