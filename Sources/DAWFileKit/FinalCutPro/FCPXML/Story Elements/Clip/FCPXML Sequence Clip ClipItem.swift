//
//  FCPXML Sequence ClipItem.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML.Clip {
    /// Items within clips.
    public enum ClipItem: String {
        case marker // includes standard and to-do markers
        case chapterMarker = "chapter-marker"
        
        // TODO: add additional clip items
    }
}

#endif
