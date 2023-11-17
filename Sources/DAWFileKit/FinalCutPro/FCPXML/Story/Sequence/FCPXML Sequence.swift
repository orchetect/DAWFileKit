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
        public let startTimecode: Timecode? // (absolute `tcStart` timecode, not relative `start`)
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
            startTimecode: Timecode?,
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
            self.startTimecode = startTimecode
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
        startTimecode = timelineAttributes.startTimecode
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

extension FinalCutPro.FCPXML.Sequence: FCPXMLStoryElement {
    public var storyElementType: FinalCutPro.FCPXML.StoryElementType { .sequence }
    
    public func asAnyStoryElement() -> FinalCutPro.FCPXML.AnyStoryElement {
        .sequence(self)
    }
}

extension FinalCutPro.FCPXML.Sequence: FCPXMLExtractable {
    // (`sequence` does not contain a relative `start`)
    public var start: TimecodeKit.Timecode? {
        nil
    }
    
    public var name: String? {
        nil
    }
}

extension FinalCutPro.FCPXML.Sequence: FCPXMLMarkersExtractable {
    /// Always returns an empty array since a sequence cannot directly contain markers.
    public var markers: [FinalCutPro.FCPXML.Marker] {
        []
    }
    
    public func extractMarkers(
        settings: FCPXMLExtractionSettings,
        ancestorsOfParent: [FinalCutPro.FCPXML.AnyStoryElement]
    ) -> [FinalCutPro.FCPXML.ExtractedMarker] {
        let childAncestors = ancestorsOfParent + [self.asAnyStoryElement()]
        return spine.extractMarkers(settings: settings, ancestorsOfParent: childAncestors)
    }
}
#endif
