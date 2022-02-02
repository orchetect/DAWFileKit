//
//  TrackArchive Init.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
@_implementationOnly import OTCore
import TimecodeKit

// MARK: - Init

extension Cubase.TrackArchive {
    
    /// Parse Track Archive XML file contents exported from Cubase.
    public init?(data: Data) {
        
        guard let xmlDocument = try? XMLDocument(data: data) else { return nil }
        
        guard let parsed = Self.parse(xml: xmlDocument) else { return nil }
        
        self = parsed
        
    }
    
    /// Parse Track Archive XML file contents exported from Cubase.
    public init?(xml: XMLDocument) {
        
        guard let parsed = Self.parse(xml: xml) else { return nil }
        
        self = parsed
        
    }
    
    /// Parse Track Archive XML file contents exported from Cubase.
    public init(xml root: XMLElement) {
        
        let parsed = Self.parse(xml: root)
        
        self = parsed
        
    }
    
}

#endif
