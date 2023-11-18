//
//  FCPXML AnnotationType.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    // TODO: add `analysis-marker`?
    
    /// Items within clips.
    public enum AnnotationType: String, CaseIterable {
        /// Closed caption.
        case caption
        
        /// Keyword.
        case keyword
        
        /// Marker. Includes standard and to-do markers.
        case marker
        
        /// Chapter Marker.
        case chapterMarker = "chapter-marker"
    }
}

#endif
