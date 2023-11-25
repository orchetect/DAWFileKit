//
//  FCPXML RefClip.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    /// References a compound clip media.
    ///
    /// > Final Cut Pro FCPXML 1.11 Reference:
    /// >
    /// > Use a `ref-clip` element to describe a timeline sequence created from a
    /// > [Compound Clip Media](
    /// > https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/story_elements/ref-clip
    /// > ).
    /// > The edit uses the entire set of media components in the compound clip media. Specify the
    /// > timing of the edit through the [Timing Attributes](
    /// > https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/story_elements/timing_attributes
    /// > ).
    /// >
    /// > You can also use a ref-clip element as an immediate child element of an event element to
    /// > represent a browser clip. In this case, use the [Timeline Attributes](
    /// > https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/story_elements/ref-clip
    /// > ) to specify its format and other attributes.
    public struct RefClip: FCPXMLClipAttributes {
        public var ref: String // resource ID, required
        public var useAudioSubroles: Bool
        public var audioRoleSources: [AudioRoleSource]
        
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
            useAudioSubroles: Bool,
            audioRoleSources: [AudioRoleSource],
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
            self.useAudioSubroles = useAudioSubroles
            self.audioRoleSources = audioRoleSources
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

extension FinalCutPro.FCPXML.RefClip: FCPXMLClip {
    /// Attributes unique to ``RefClip`` clip.
    public enum Attributes: String, XMLParsableAttributesKey {
        case ref // resource ID
        case role
        case useAudioSubroles
    }
    
    /// Children of ``RefClip`` clip.
    public enum Children: String {
        case audioRoleSource = "audio-role-source"
    }
    
    public init?(
        from xmlLeaf: XMLElement,
        breadcrumbs: [XMLElement],
        resources: [String: FinalCutPro.FCPXML.AnyResource],
        contextBuilder: FCPXMLElementContextBuilder
    ) {
        let rawValues = xmlLeaf.parseRawAttributeValues(key: Attributes.self)
        
        guard let ref = rawValues[.ref] else { return nil }
        self.ref = ref
        
        // AFAIK `media` is the only resource type usable by a `ref-clip`
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
        
        useAudioSubroles = rawValues[.useAudioSubroles] == "1"
        // TODO: parse audioRoleSources
        audioRoleSources = Self.parseAudioRoleSources(from: xmlLeaf)
        
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
    
    public var clipType: FinalCutPro.FCPXML.ClipType { .refClip }
    public func asAnyClip() -> FinalCutPro.FCPXML.AnyClip { .refClip(self) }
}

extension FinalCutPro.FCPXML.RefClip: FCPXMLExtractable {
    public func extractableElements() -> [FinalCutPro.FCPXML.AnyElement] {
        []
    }
    
    public func extractableChildren() -> [FinalCutPro.FCPXML.AnyElement] {
        // resource may contain story elements
        let mtElements = mediaType.extractableElements()
        let mtChildren = mediaType.extractableChildren()
        
        return contents.asAnyElements() + mtElements + mtChildren
    }
}

extension FinalCutPro.FCPXML.RefClip {
    public struct AudioRoleSource: Equatable, Hashable {
        public var role: FinalCutPro.FCPXML.AudioRole
        public var contents: [XMLElement]
        
        /// Attributes unique to ``AudioRoleSource``.
        public enum Attributes: String, XMLParsableAttributesKey {
            case role
        }
    }
    
    static func parseAudioRoleSources(from xmlLeaf: XMLElement) -> [AudioRoleSource] {
        let elements = (xmlLeaf.children ?? [])
            .filter { $0.name == Children.audioRoleSource.rawValue }
            .compactMap { $0 as? XMLElement }
        
        return elements.compactMap {
            let rawValues = $0.parseRawAttributeValues(key: AudioRoleSource.Attributes.self)
            let children = $0.children?.compactMap { $0 as? XMLElement } ?? []
            
            guard let audioRole = FinalCutPro.FCPXML.AudioRole(rawValue: rawValues[.role] ?? "")
            else { return nil }
            
            return AudioRoleSource(role: audioRole, contents: children)
        }
    }
}

#endif
