//
//  FCPXML SyncClip.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    /// Contains a clip with its contained and anchored items synchronized.
    ///
    /// > Final Cut Pro FCPXML 1.11 Reference:
    /// >
    /// > Use the `sync-source` element to describe the audio components of a synchronized clip.
    public struct SyncClip: FCPXMLStoryElement {
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

extension FinalCutPro.FCPXML.SyncClip {
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
