//
//  FCPXML Sequence Attributes.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML.Sequence {
    // TODO: factor out Attributes; replace with protocols
    
    /// Attributes unique to Sequence.
    public enum Attributes: String {
        case audioLayout
        case audioRate
        case note
        case renderFormat
        case keywords
        case spine
        
        case metadata
    }
}

#endif
