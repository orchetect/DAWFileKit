//
//  FCPXML Metadata.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    public struct Metadata: Equatable, Hashable {
        public var xml: [XMLElement]
        
        // TODO: parse xml and convert into strong typed structs
        
        public init(
            xml: [XMLElement]
        ) {
            self.xml = xml
        }
    }
}

extension FinalCutPro.FCPXML.Metadata {
    public init(fromMetadataElement xmlLeaf: XMLElement) {
        xml = (xmlLeaf.children ?? [])
            .compactMap { $0 as? XMLElement }
    }
    
     public init(from metadataChildren: [XMLElement]) {
         xml = metadataChildren
     }
}

#endif
