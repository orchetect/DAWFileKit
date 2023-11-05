//
//  FCPXML AnyStoryElement Attributes.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import CoreMedia
@_implementationOnly import OTCore

extension FinalCutPro.FCPXML.AnyStoryElement {
    // TODO: factor out Attributes; replace with protocols
    
    /// Clip XML Attributes.
    public enum Attributes: String {
        case ref // resource ID
        case name
        
        // case offset // handled with FCPXMLTimingAttributes
        // case start // handled with FCPXMLTimingAttributes
        // case duration // handled with FCPXMLTimingAttributes
        
        case audioRole
        case role // TODO: video role; change name to `videoRole`?
    }
}

#endif
