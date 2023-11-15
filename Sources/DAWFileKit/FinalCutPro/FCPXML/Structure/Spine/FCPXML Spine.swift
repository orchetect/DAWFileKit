//
//  FCPXML Spine.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    /// Contains elements ordered sequentially in time.
    public struct Spine: FCPXMLStoryElement, FCPXMLAnchorableAttributes {
        public var name: String?
        public var elements: [FinalCutPro.FCPXML.AnyStoryElement]
        
        // FCPXMLAnchorableAttributes
        public var lane: Int?
        public var offset: Timecode?
        
        // TODO: add missing attributes and protocols
        
        public init(
            name: String?,
            elements: [FinalCutPro.FCPXML.AnyStoryElement],
            // FCPXMLAnchorableAttributes
            lane: Int?,
            offset: Timecode?
        ) {
            self.name = name
            self.elements = elements
            
            // FCPXMLAnchorableAttributes
            self.lane = lane
            self.offset = offset
        }
    }
}

extension FinalCutPro.FCPXML.Spine {
    // no start
    init(
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) {
        name = FinalCutPro.FCPXML.getNameAttribute(from: xmlLeaf)
        elements = FinalCutPro.FCPXML.parseStoryElements(
            in: xmlLeaf,
            resources: resources
        )
        
        let anchorableAttributes = Self.parseAnchorableAttributes(
            from: xmlLeaf,
            resources: resources
        )
        
        // FCPXMLAnchorableAttributes
        lane = anchorableAttributes.lane
        offset = anchorableAttributes.offset
    }
}

extension FinalCutPro.FCPXML.Spine: FCPXMLMarkersExtractable {
    public var markers: [FinalCutPro.FCPXML.Marker] {
        elements.flatMap { $0.markers }
    }
    
    public func extractMarkers(
        settings: FCPXMLMarkersExtractionSettings
    ) -> [FinalCutPro.FCPXML.ExtractedMarker] {
        elements.flatMap { $0.extractMarkers(settings: settings) }
    }
}

#endif
