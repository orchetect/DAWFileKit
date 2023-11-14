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
        public var xml: XMLElement // TODO: placeholder. finish building this.
        
        public var clips: [AnyClip]
        public var markers: [FinalCutPro.FCPXML.Marker] // TODO: refactor as attributes
        
        public init(
            clips: [AnyClip],
            markers: [FinalCutPro.FCPXML.Marker]
        ) {
            xml = XMLElement() // TODO: temporary
            
            self.clips = clips
            self.markers = markers
        }
    }
}

extension FinalCutPro.FCPXML.Audio {
    init(
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) {
        xml = xmlLeaf
        clips = FinalCutPro.FCPXML.parseClips(in: xmlLeaf, resources: resources)
        markers = FinalCutPro.FCPXML.parseMarkers(in: xmlLeaf, resources: resources)
    }
}

#endif
