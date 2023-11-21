//
//  FCPXML MCClip.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    /// References a multicam media.
    ///
    /// > Final Cut Pro FCPXML 1.11 Reference:
    /// >
    /// > Use an `mc-clip` element to describe a timeline sequence created from a multicam media. To
    /// > use multicam media as a clip, see [Using Multicam Media](
    /// > https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/story_elements/mc-clip
    /// > ). To specify the timing of the edit,
    /// > use the [Timing Attributes](
    /// > https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/story_elements/mc-clip
    /// > ).
    public struct MCClip: FCPXMLClipAttributes {
        public var ref: String // resource ID, required
        
        @EquatableAndHashableExempt
        public var refMedia: Media
        @EquatableAndHashableExempt
        public var mediaType: FinalCutPro.FCPXML.Media.MediaType
        
        public var contents: [AnyStoryElement]
        
        // FCPXMLAnchorableAttributes
        public var lane: Int?
        public var offset: Timecode?
        
        // FCPXMLClipAttributes
        public var name: String?
        public var start: Timecode?
        public var duration: Timecode?
        public var enabled: Bool
        
        // TODO: add missing attributes and protocols
        
        // FCPXMLElementContext
        @EquatableAndHashableExempt
        public var context: FinalCutPro.FCPXML.ElementContext
        
        public init(
            ref: String,
            refMedia: Media,
            mediaType: FinalCutPro.FCPXML.Media.MediaType,
            contents: [AnyStoryElement],
            // FCPXMLAnchorableAttributes
            lane: Int?,
            offset: Timecode?,
            // FCPXMLClipAttributes
            name: String?,
            start: Timecode?,
            duration: Timecode?,
            enabled: Bool,
            // FCPXMLElementContext
            context: FinalCutPro.FCPXML.ElementContext = .init()
        ) {
            self.ref = ref
            self.refMedia = refMedia
            self.mediaType = mediaType
            self.contents = contents
            
            // FCPXMLAnchorableAttributes
            self.lane = lane
            self.offset = offset
            
            // FCPXMLClipAttributes
            self.name = name
            self.start = start
            self.duration = duration
            self.enabled = enabled
            
            // FCPXMLElementContext
            self.context = context
        }
    }
}

extension FinalCutPro.FCPXML.MCClip: FCPXMLClip {
    /// Attributes unique to ``MCClip`` clip.
    public enum Attributes: String, XMLParsableAttributesKey {
        case ref // resource ID
    }
    
    // no role
    public init?(
        from xmlLeaf: XMLElement,
        breadcrumbs: [XMLElement],
        resources: [String: FinalCutPro.FCPXML.AnyResource],
        contextBuilder: FCPXMLElementContextBuilder
    ) {
        let rawValues = xmlLeaf.parseRawAttributeValues(key: Attributes.self)
        
        guard let ref = rawValues[.ref] else { return nil }
        self.ref = ref
        
        // AFAIK `media` is the only resource type usable by a `mc-clip`
        guard case let .media(refMedia) = resources[ref] else { return nil }
        self.refMedia = refMedia
        
        guard let mediaType = refMedia.generateMediaType(
            breadcrumbs: breadcrumbs + [xmlLeaf],
            resources: resources,
            contextBuilder: contextBuilder
        ) else { return nil }
        self.mediaType = mediaType
        
        contents = FinalCutPro.FCPXML.storyElements( // adds xmlLeaf as breadcrumb
            in: xmlLeaf,
            breadcrumbs: breadcrumbs,
            resources: resources,
            contextBuilder: contextBuilder
        )
        
        let clipAttributes = Self.parseClipAttributes(
            from: xmlLeaf,
            resources: resources
        )
        
        // FCPXMLAnchorableAttributes
        lane = clipAttributes.lane
        offset = clipAttributes.offset
        
        // FCPXMLClipAttributes
        name = clipAttributes.name
        start = clipAttributes.start
        duration = clipAttributes.duration
        enabled = clipAttributes.enabled
        
        // FCPXMLElementContext
        context = contextBuilder.buildContext(from: xmlLeaf, breadcrumbs: breadcrumbs, resources: resources)
        
        // validate element name
        // (we have to do this last, after all properties are initialized in order to access self)
        guard xmlLeaf.name == clipType.rawValue else { return nil }
    }
    
    public var clipType: FinalCutPro.FCPXML.ClipType { .mcClip }
    public func asAnyClip() -> FinalCutPro.FCPXML.AnyClip { .mcClip(self) }
}

extension FinalCutPro.FCPXML.MCClip: FCPXMLExtractable {
    public func extractableElements() -> [FinalCutPro.FCPXML.AnyElement] {
        []
    }
    
    public func extractElements(
        settings: FinalCutPro.FCPXML.ExtractionSettings,
        ancestorsOfParent: [FinalCutPro.FCPXML.AnyElement],
        matching predicate: (_ element: FinalCutPro.FCPXML.AnyElement) -> Bool
    ) -> [FinalCutPro.FCPXML.AnyElement] {
        // resource may contain story elements
        let mediaRefElements = mediaType.extractElements(
            settings: settings,
            ancestorsOfParent: ancestorsOfParent,
            matching: predicate
        )
        
        return extractElements(
            settings: settings,
            ancestorsOfParent: ancestorsOfParent,
            contents: mediaRefElements + contents.asAnyElements(),
            matching: predicate
        )
    }
}

#endif
