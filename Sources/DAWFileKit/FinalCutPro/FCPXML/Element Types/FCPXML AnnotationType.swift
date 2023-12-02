//
//  FCPXML AnnotationType.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    /// Annotation element types.
    public enum AnnotationType: String, CaseIterable {
        /// Closed caption.
        case caption
        
        /// Keyword.
        case keyword
        
        /// Marker. Includes standard and to-do markers.
        case marker
        
        /// Chapter Marker.
        case chapterMarker = "chapter-marker"
        
        // TODO: add `analysis-marker`?
    }
}

extension FinalCutPro.FCPXML.AnnotationType: FCPXMLElementTypeProtocol {
    public var elementType: FinalCutPro.FCPXML.ElementType {
        .story(.annotation(self))
    }
}

#endif
