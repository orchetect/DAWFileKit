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
    public struct Sequence: FCPXMLTimelineAttributes {
        // FCPXMLTimelineAttributes
        public var formatID: String
        public var startTimecode: Timecode? // (absolute `tcStart` timecode, not relative `start`)
        public var duration: Timecode?
        
        // FCPXMLElementContext
        @EquatableAndHashableExempt
        public var context: FinalCutPro.FCPXML.ElementContext
        
        public var audioLayout: AudioLayout?
        public var audioRate: AudioRate?
        public var renderFormat: String?
        public var note: String?
        public var keywords: String?
        public var spine: Spine
        
        // TODO: add metadata
        
        public init?(
            // FCPXMLTimelineAttributes
            formatID: String,
            startTimecode: Timecode?,
            duration: Timecode?,
            // sequence attributes
            audioLayout: AudioLayout?,
            audioRate: AudioRate?,
            renderFormat: String?,
            note: String?,
            keywords: String?,
            spine: Spine,
            // FCPXMLElementContext
            context: FinalCutPro.FCPXML.ElementContext = .init()
        ) {
            // FCPXMLTimelineAttributes
            self.formatID = formatID
            self.startTimecode = startTimecode
            self.duration = duration
            
            // sequence attributes
            self.audioLayout = audioLayout
            self.audioRate = audioRate
            self.renderFormat = renderFormat
            self.note = note
            self.keywords = keywords
            self.spine = spine
            
            // FCPXMLElementContext
            self.context = context
        }
    }
}

extension FinalCutPro.FCPXML.Sequence: FCPXMLStoryElement {
    /// Attributes unique to ``Sequence``.
    public enum Attributes: String, XMLParsableAttributesKey {
        case audioLayout
        case audioRate
        case note
        case renderFormat
        case keywords
        case spine
        
        case metadata
    }
    
    // no role
    public init?(
        from xmlLeaf: XMLElement,
        breadcrumbs: [XMLElement],
        resources: [String: FinalCutPro.FCPXML.AnyResource],
        contextBuilder: FCPXMLElementContextBuilder
    ) {
        let rawValues = xmlLeaf.parseRawAttributeValues(key: Attributes.self)
        
        // parses `format`, `tcStart`, `tcFormat`, `duration`
        guard let timelineAttributes = Self.parseTimelineAttributes(
            from: xmlLeaf,
            resources: resources
        ) else { return nil }
        
        formatID = timelineAttributes.format
        startTimecode = timelineAttributes.startTimecode
        duration = timelineAttributes.duration
        
        audioLayout = FinalCutPro.FCPXML.AudioLayout(rawValue: rawValues[.audioLayout] ?? "")
        audioRate = FinalCutPro.FCPXML.AudioRate(rawValue: rawValues[.audioRate] ?? "")
        
        renderFormat = rawValues[.renderFormat]
        note = rawValues[.note]
        keywords = rawValues[.keywords]
        
        // FCPXMLElementContext
        context = contextBuilder.buildContext(from: xmlLeaf, breadcrumbs: breadcrumbs, resources: resources)
        
        // spine
        guard let spineLeaf = Self.parseSpine(from: xmlLeaf),
              let spine = FinalCutPro.FCPXML.Spine(
                  from: spineLeaf,
                  breadcrumbs: breadcrumbs + [xmlLeaf],
                  resources: resources,
                  contextBuilder: contextBuilder
              )
        else { return nil }
        self.spine = spine
        
        // validate element name
        // (we have to do this last, after all properties are initialized in order to access self)
        guard xmlLeaf.name == storyElementType.rawValue else { return nil }
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
    
    public var storyElementType: FinalCutPro.FCPXML.StoryElementType { .sequence }
    public func asAnyStoryElement() -> FinalCutPro.FCPXML.AnyStoryElement { .sequence(self) }
}

extension FinalCutPro.FCPXML.Sequence: FCPXMLExtractable {
    public func extractableElements() -> [FinalCutPro.FCPXML.AnyElement] {
        [] // not found in sequence, they're in the inner spine instead
    }
    
    public func extractElements(
        settings: FinalCutPro.FCPXML.ExtractionSettings,
        ancestorsOfParent: [FinalCutPro.FCPXML.AnyElement],
        matching predicate: (_ element: FinalCutPro.FCPXML.AnyElement) -> Bool
    ) -> [FinalCutPro.FCPXML.AnyElement] {
        extractElements(
            settings: settings,
            ancestorsOfParent: ancestorsOfParent,
            contents: [spine.asAnyElement()],
            matching: predicate
        )
    }
}

#endif
