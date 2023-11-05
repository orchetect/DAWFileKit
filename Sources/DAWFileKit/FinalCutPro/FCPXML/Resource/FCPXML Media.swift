//
//  FCPXML Media.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    // TODO: xml variable is temporary; finish parsing the xml
    
    /// Media shared resource.
    public struct Media: Equatable, Hashable {
        public let xml: XMLElement
        
        // internal init(
        //     // ...
        // ) {
        //     // ...
        // }
        
        init(from xmlLeaf: XMLElement) {
            xml = xmlLeaf
        }
    }
}

extension FinalCutPro.FCPXML.Media {
    // public enum Attributes: String {
    //     // ...
    // }
}

#endif
