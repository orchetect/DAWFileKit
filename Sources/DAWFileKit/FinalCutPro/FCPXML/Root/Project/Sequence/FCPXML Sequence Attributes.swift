//
//  FCPXML Sequence Attributes.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML.Sequence {
    /// Sequence XML Attributes.
    public enum Attributes: String {
        case format // resource ID
        case duration
        case tcStart
        case tcFormat
        case audioLayout
        case audioRate
    }
}

#endif
