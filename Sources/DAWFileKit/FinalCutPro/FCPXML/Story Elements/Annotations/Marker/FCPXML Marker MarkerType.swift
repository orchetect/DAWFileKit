//
//  FCPXML Marker MarkerType.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML.Marker {
    // TODO: add support for `analysis-marker`?
    public enum MarkerType: String, CaseIterable {
        case standard = "Standard"
        case chapter = "Chapter"
        case toDo = "To Do"
    }
}

#endif
