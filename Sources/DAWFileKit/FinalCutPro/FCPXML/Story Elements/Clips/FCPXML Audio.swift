//
//  FCPXML Audio.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    /// Audio element.
    ///
    /// > Final Cut Pro FCPXML 1.11 Reference:
    /// >
    /// > References audio data from an `asset` or `effect` element.
    public struct Audio: FCPXMLStoryElement {
        public var xml: XMLElement
        
        // TODO: placeholder. finish building this.
        
        public init(
            xml: XMLElement
        ) {
            self.xml = xml
        }
    }
}

extension FinalCutPro.FCPXML.Audio {
    init(
        from xmlLeaf: XMLElement
    ) {
        xml = xmlLeaf
    }
}

#endif
