//
//  FCPXML AnnotationType.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    // TODO: will likely factor this out, as it does not align with the DTD's structure.
    
    /// Items within clips.
    public enum AnnotationType: String, CaseIterable {
        /// Marker. Includes standard and to-do markers.
        case marker
        
        /// Chapter Marker.
        case chapterMarker = "chapter-marker"
        
        // TODO: add additional clip items
    }
}

#endif
