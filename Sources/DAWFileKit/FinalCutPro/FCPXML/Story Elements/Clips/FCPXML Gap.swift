//
//  FCPXML Gap.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    /// Gap element.
    ///
    /// > Final Cut Pro FCPXML 1.11 Reference:
    /// >
    /// > Defines a placeholder element that has no intrinsic audio or video data.
    public struct Gap: FCPXMLStoryElement {
        public var xml: XMLElement
        
        // TODO: placeholder. finish building this.
        
        public init(
            xml: XMLElement
        ) {
            self.xml = xml
        }
    }
}

extension FinalCutPro.FCPXML.Gap {
    init(
        from xmlLeaf: XMLElement
    ) {
        xml = xmlLeaf
    }
}

#endif
