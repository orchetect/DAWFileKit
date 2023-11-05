//
//  FCPXML Sequence Clip Attributes.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import CoreMedia
@_implementationOnly import OTCore

extension FinalCutPro.FCPXML.Clip {
    /// Clip XML Attributes.
    public enum Attributes: String {
        case ref // resource ID
        case name
        
        case offset // TODO: handle with FCPXMLTimingAttributes
        case start // TODO: handle with FCPXMLTimingAttributes
        case duration // TODO: handle with FCPXMLTimingAttributes
        
        case audioRole
        case role // TODO: video role; change name to `videoRole`?
    }
}

#endif
