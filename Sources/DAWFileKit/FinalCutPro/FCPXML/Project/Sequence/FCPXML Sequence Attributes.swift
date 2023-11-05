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
        // case format // resource ID // handled by FCPXMLTimelineAttributes
        
        // case duration // handled by FCPXMLClipAttributes
        // case tcStart // handled by FCPXMLClipAttributes
        // case tcFormat // handled by FCPXMLClipAttributes
        
        case audioLayout
        case audioRate
        
        case note
        case renderFormat
        case keywords
        case metadata
    }
}

#endif
