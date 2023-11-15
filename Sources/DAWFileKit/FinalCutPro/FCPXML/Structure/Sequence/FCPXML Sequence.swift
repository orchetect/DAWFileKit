//
//  FCPXML Sequence.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import CoreMedia
@_implementationOnly import OTCore

extension FinalCutPro.FCPXML {
    /// A container that represents the top-level sequence for a Final Cut Pro project or compound
    /// clip.
    public struct Sequence {
        // FCPXMLTimelineAttributes
        public let format: String
        public let start: Timecode?
        public let duration: Timecode?
        
        public let audioLayout: AudioLayout?
        public let audioRate: AudioRate?
        public let renderFormat: String?
        public let note: String?
        public let keywords: String?
        public let spine: Spine
        
        // TODO: add metadata
        
        public init?(
            // FCPXMLTimelineAttributes
            format: String,
            start: Timecode?,
            duration: Timecode?,
            // sequence attributes
            audioLayout: AudioLayout?,
            audioRate: AudioRate?,
            renderFormat: String?,
            note: String?,
            keywords: String?,
            spine: Spine
        ) {
            // FCPXMLTimelineAttributes
            self.format = format
            self.start = start
            self.duration = duration
            
            // sequence attributes
            self.audioLayout = audioLayout
            self.audioRate = audioRate
            self.renderFormat = renderFormat
            self.note = note
            self.keywords = keywords
            self.spine = spine
        }
    }
}

extension FinalCutPro.FCPXML.Sequence: FCPXMLTimelineAttributes {
    init?(
        from xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) {
        // parses `format`, `tcStart`, `tcFormat`, `duration`
        guard let timelineAttributes = Self.parseTimelineAttributes(
            from: xmlLeaf,
            resources: resources
        ) else { return nil }
        
        format = timelineAttributes.format
        start = timelineAttributes.start
        duration = timelineAttributes.duration
        
        audioLayout = FinalCutPro.FCPXML.AudioLayout(
            rawValue: xmlLeaf.attributeStringValue(forName: Attributes.audioLayout.rawValue) ?? ""
        )
        
        audioRate = FinalCutPro.FCPXML.AudioRate(
            rawValue: xmlLeaf.attributeStringValue(forName: Attributes.audioRate.rawValue) ?? ""
        )
        
        renderFormat = xmlLeaf.attributeStringValue(forName: Attributes.renderFormat.rawValue)
        note = xmlLeaf.attributeStringValue(forName: Attributes.note.rawValue)
        keywords = xmlLeaf.attributeStringValue(forName: Attributes.keywords.rawValue)
        
        // spine
        guard let spineLeaf = Self.parseSpine(from: xmlLeaf) else { return nil }
        spine = FinalCutPro.FCPXML.Spine(from: spineLeaf, resources: resources)
    }
    
    static func parseSpine(
        from xmlLeaf: XMLElement
    ) -> XMLElement? {
        let spines = xmlLeaf.children?.lazy
            .filter { $0.name == "spine" }
            .compactMap { $0 as? XMLElement } ?? []
        guard let spine = spines.first else {
            print("Expected one spine within sequence but found none.")
            return nil
        }
        if spines.count != 1 {
            print("Expected one spine within sequence but found \(spines.count)")
        }
        return spine
    }
}

extension FinalCutPro.FCPXML.Sequence: FCPXMLMarkersExtractable {
    /// Convenience to return the enclosed spine's markers.
    public var markers: [FinalCutPro.FCPXML.Marker] {
        spine.markers
    }
    
    public func extractMarkers(
        settings: FCPXMLMarkersExtractionSettings
    ) -> [FinalCutPro.FCPXML.ExtractedMarker] {
        spine.extractMarkers(settings: settings)
    }
}
#endif
