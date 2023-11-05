//
//  FCPXML Marker MarkerNodeType.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML.Marker {
    public enum MarkerNodeType: String {
        case marker
        case chapterMarker = "chapter-marker"
    }
}

#endif
